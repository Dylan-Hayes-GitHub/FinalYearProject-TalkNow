import { Injectable } from '@angular/core';
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {getDatabase, ref, push, onValue, get, query, update, remove} from "@angular/fire/database";
import { PendingFriendRequests } from '../Models/Chat';
import {take} from "rxjs";
import {CurrentConversationUserDetails} from "../Models/User";
import {getBlob, getStorage, ref as r} from "@angular/fire/storage";

@Injectable({
  providedIn: 'root'
})
export class AddFriendService {

  constructor(private auth: AngularFireAuth) { }

  public getIncomingFriendRequests(callback: (friendRequests: PendingFriendRequests[]) => void): PendingFriendRequests[] {
    let currentPendingFriendRequests: PendingFriendRequests[] = [];
    //firstly get the logged in auth user
    this.auth.user.subscribe(loggedInUser => {
      //get db ref to friend req
      const friendReq = loggedInUser?.uid +'/friendRequests/';
      const db = getDatabase();
      const friendRequestRef = ref(db, friendReq);
      //get values
      onValue(friendRequestRef, dataSnapshot => {
        //check to see if it has children i.e friend requests
        currentPendingFriendRequests = [];
          //there is current pending friend requests
          dataSnapshot.forEach(friendReq => {
            let pendingFriendRequest: PendingFriendRequests = new class implements PendingFriendRequests {
              Declined: string;
              FirebaseId: string;
              Name: string;
              Accepted: boolean;
              UserDetails: CurrentConversationUserDetails;
            };

            pendingFriendRequest.FirebaseId = friendReq.child('FirebaseId').val();
            pendingFriendRequest.Name = friendReq.child('Name').val();
            pendingFriendRequest.Accepted = friendReq.child('Accepted').val();
            pendingFriendRequest.Declined = friendReq.child('Declined').val();


            this.getPendingFriendRequestUserDetails(pendingFriendRequest.FirebaseId).then(friendRequestDetails => {
              pendingFriendRequest.UserDetails = friendRequestDetails;
              currentPendingFriendRequests.push(pendingFriendRequest);

            })
          });
          callback(currentPendingFriendRequests);

      })
    });

    return currentPendingFriendRequests;
  }

  public async getPendingFriendRequestUserDetails(pendingFirebaseId: string): Promise<CurrentConversationUserDetails> {
    let userDetailsToReturn: CurrentConversationUserDetails = new class implements CurrentConversationUserDetails {
      Email: string;
      FirebaseId: string;
      FirstName: string;
      LastName: string;
      deviceNotificationToken: string;
      hasProfilePicture: boolean;
      userProfileUrl: string;
    }
    const db = getDatabase();
    const otherUserRef = ref(db, pendingFirebaseId);

    const snapshot = await get(otherUserRef);

    if (snapshot.hasChildren()) {
      userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
      userDetailsToReturn.LastName = snapshot.child('LastName').val();
      userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
      userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
      userDetailsToReturn.FirebaseId = pendingFirebaseId;

      if (userDetailsToReturn.hasProfilePicture) {
        if (localStorage.getItem(pendingFirebaseId) != null) {
          //user has a profile image and store it to local storage
          userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
        } else {
          //download image and then assign
          await this.getUserProfileImage(pendingFirebaseId);
          userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;

        }
      }

    }
    return userDetailsToReturn;
  }
  async getUserProfileImage(FirebaseId: string) {
    const storage = getStorage();

    const userProfileRef = r(storage, FirebaseId);

    await getBlob(userProfileRef).then(userProfileUrl => {
      // localStorage.setItem(FirebaseId, userProfileUrl);
      const blob = userProfileUrl; // the blob you want to store
      const reader = new FileReader();
      reader.readAsDataURL(blob);
      reader.onloadend = () => {
        const base64data = reader.result;
        if(base64data != null){
          localStorage.setItem(FirebaseId, String(base64data));
        }
      };
    })
  }

  public acceptFriendRequest(firebaseId: string){
    //get ref to user

    this.auth.user.subscribe(loggedInUser => {
      //get db ref to friend req
      const friendReq = loggedInUser?.uid +'/friendRequests/';
      const db = getDatabase();
      const reference = ref(db, friendReq);
      let getFriendRequests = query(reference);

      get(getFriendRequests)
      .then(currentFriendRequests => {
        currentFriendRequests.forEach(requests => {
          if(requests.child('FirebaseId').val() == firebaseId){
            //found child to update

            const clientFriendList = loggedInUser?.uid +'/friends/';
            const clientFriendListRef = ref(db, clientFriendList);

            const otherUserFriendList = requests.child('FirebaseId').val() + '/friends/';
            const otherUserFriendListRef = ref(db, otherUserFriendList);

            push(clientFriendListRef, {
              Name: requests.child('Name').val(),
              FirebaseId: requests.child('FirebaseId').val()
            })

            push(otherUserFriendListRef, {
              Name: localStorage.getItem('name') as string,
              FirebaseId: loggedInUser?.uid
            })


            remove(ref(db, friendReq+requests.key));
          }
        })
      })
    })
  }

  public declineFriendRequest(firebaseId: string){
        //get ref to user
        this.auth.user.subscribe(loggedInUser => {
          //get db ref to friend req
          const friendReq = loggedInUser?.uid +'/friendRequests/';
          const db = getDatabase();
          const reference = ref(db, friendReq);
          let getFriendRequests = query(reference);

          get(getFriendRequests)
          .then(currentFriendRequests => {
            currentFriendRequests.forEach(requests => {

              if(requests.child('FirebaseId').val() == firebaseId){
                //found child to update

                remove(ref(db, friendReq+requests.key));


              }
            })
          })
        })
  }
}
