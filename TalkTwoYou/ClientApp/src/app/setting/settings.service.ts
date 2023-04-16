import { Injectable } from '@angular/core';
import { UserUpdatedDetails } from '../Models/User';
import { HttpClient } from '@angular/common/http';
import { Constants } from '../Models/Constants';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { take } from 'rxjs';
import { get, getDatabase, push, ref, update } from '@angular/fire/database';
import { DataService } from '../Data/data.service';
import {getBlob, getStorage, ref as r, ref as storageRef, uploadBytes, uploadString} from '@angular/fire/storage';


@Injectable({
  providedIn: 'root'
})
export class SettingsService {


  constructor(private http: HttpClient, private firebaseAuth: AngularFireAuth, private dataService: DataService) { }


  updateUserDetails(updatedUserDetails: UserUpdatedDetails) {

    this.http.post<any>(Constants.API_URL + 'user/updateUserDetails', updatedUserDetails,  {observe: 'response'}).subscribe(response => {
      const status = response.status;
      if(status === 200){
        if(updatedUserDetails.NewPassword != ""){
          this.firebaseAuth.user.pipe(take(1)).subscribe(async loggedInUser => {
            loggedInUser?.updatePassword(updatedUserDetails.NewPassword);
            loggedInUser?.updateEmail(updatedUserDetails.Email);

            await this.firebaseAuth.signInWithEmailAndPassword(updatedUserDetails.Email, updatedUserDetails.NewPassword);
            var userDetailsForUpdating = {
              "FirstName": updatedUserDetails.FirstName,
              "LastName": updatedUserDetails.LastName,
              "Email": updatedUserDetails.Email
            }
            const db = getDatabase();
            const userRef = ref(db, loggedInUser?.uid);

            update(userRef, userDetailsForUpdating);
            if(loggedInUser != null){
              this.dataService.startGettingloggedInUserDetails(loggedInUser?.uid);
            }
          });
        } else {
          this.firebaseAuth.user.pipe(take(1)).subscribe(async loggedInUser => {
            var userDetailsForUpdating = {
              "FirstName": updatedUserDetails.FirstName,
              "LastName": updatedUserDetails.LastName,
              "Email": updatedUserDetails.Email
            }
            const db = getDatabase();
            const userRef = ref(db, loggedInUser?.uid);

            update(userRef, userDetailsForUpdating);
            if(loggedInUser != null){
              this.dataService.startGettingloggedInUserDetails(loggedInUser?.uid);
            }
          });
        }
      }
    })
  }

  async uploadImage(result:any, firebaseId: string) {
    if(result){
      const storage = getStorage();
      const userStoreRef = storageRef(storage, firebaseId);

     await uploadBytes(userStoreRef, result);

     //notify other users of new profile picture
     this.dataService.getUserProfileImage(firebaseId).then(finished => {
       this.dataService.startGettingloggedInUserDetails(firebaseId);

     });

     //update reference user ref to say they have a profile picture
     const userRef = ref(getDatabase(), firebaseId);

     var updateData = {
      "hasProfilePicture": true
     }

     update(userRef, updateData)
     //get logged in user friend list
     const db = getDatabase();
     const userFriendsRef = ref(db, `${firebaseId}/friends/`);
     get(userFriendsRef).then(dataSnapshot => {
      if(dataSnapshot.exists()){
        dataSnapshot.forEach(friend => {
          if(friend.child('FirebaseId').val() != null){
            //set value for friend to download new profile picture
            const otherUserRef = ref(db, `${friend.child('FirebaseId').val()}/updatedProfilePictures`)
            push(otherUserRef, {
              'FirebaseId': firebaseId
            });
          }
        })
      }
     })
    }
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

}
