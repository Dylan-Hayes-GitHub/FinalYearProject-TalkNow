import { Injectable } from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {Database, getDatabase, ref, set, push, onValue, get, child, limitToLast, query, DataSnapshot} from "@angular/fire/database";
import {CurrentConversationDao, Message, PastChatRoomDao} from "../Models/Chat";
import {DataService} from "../Data/data.service";
import { getBlob, getDownloadURL, getStorage, ref as r } from '@angular/fire/storage';
import {filter, take} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class PastChatRoomServiceService {

  constructor(private http: HttpClient, private dataService: DataService) { }

  public getAllPastChatRooms(firebaseUid: string | undefined, callback: (messages: PastChatRoomDao[]) => void){
    const messagesUrl = firebaseUid+'/messages/';
    const db = getDatabase();
    const pastChatRoomsRef = ref(db, messagesUrl);
    let counter =0;
    let initialLoad: boolean = false;

    let pastChatRooms: PastChatRoomDao[] = [];
    //get messages from all past chat rooms and store in array
    onValue(pastChatRoomsRef, (dataSnapshot) => {
      //check to see if it has children
      pastChatRooms = [];
      counter = 0;
      if(dataSnapshot.hasChildren()){
        //get last message for each user



        //user has past chat rooms
        dataSnapshot.forEach(chatRoom => {
          const lastMessage = ref(db,messagesUrl+chatRoom.key+'/');
          const lastMessageQuery = query(lastMessage, limitToLast(1))
          get(lastMessageQuery).then(lastMessages => {
            lastMessages.forEach(lastSentMessage => {

              //first check to see if this user is friends with the logged in user as past messages should only show messages between
              //friends and not random conversations

              const friendListRef = ref(db, firebaseUid +'/friends');

              get(friendListRef).then(snapshot => {
                if(snapshot.hasChildren()){
                  snapshot.forEach(friend => {
                    //if these match that means the conversation found is between two users who are friends with each other
                   if(friend.child('FirebaseId').val() == lastSentMessage.child('GroupId').val()){
                     let pastChatRoomDao: PastChatRoomDao = new class implements PastChatRoomDao {
                       HasProfilePicture: boolean;
                       GroupId: string;
                       AuthorName: string;
                       FirebaseUid: string;
                       LastMessage: string;
                       SendTime: string;
                       ProfileUrl: string;
                       Sentiment: string;
                     }
                      //getting last sent message
                     const otherUserRef = ref(db,chatRoom.key+'/');
                     get(otherUserRef).then(async otherUser => {
                       pastChatRoomDao.AuthorName = otherUser.child('FirstName').val() + ' ' + otherUser.child('LastName').val();
                       pastChatRoomDao.FirebaseUid = lastSentMessage.child('GroupId').val();
                       pastChatRoomDao.LastMessage = lastSentMessage.child('Message').val();
                       pastChatRoomDao.SendTime = lastSentMessage.child('ReadableTime').val();
                       pastChatRoomDao.GroupId = lastSentMessage.child('GroupId').val();
                       pastChatRoomDao.Sentiment = lastSentMessage.child('Sentiment').val();
                       await get(ref(db,pastChatRoomDao.FirebaseUid)).then(async userDetails => {
                         if(userDetails.child('hasProfilePicture').val()){
                           await this.getUserProfileImage(pastChatRoomDao.GroupId).then(completed => {
                             const userBlob = localStorage.getItem(pastChatRoomDao.GroupId);
                             if(userBlob != null){
                               pastChatRoomDao.ProfileUrl = userBlob;
                               pastChatRoomDao.HasProfilePicture = userDetails.child('hasProfilePicture').val();
                             }
                           });
                         }


                       })

                       if(!initialLoad){
                         this.dataService.$currentConversationUserDetails.pipe(
                           filter(((x) => (x.FirstName.length > 0 && x.FriendsAlready == true)|| x.FirebaseId == '')),
                           take(1)
                         ).subscribe(async userDetails => {
                           await this.dataService.getUserConversationDetails(lastSentMessage.child('GroupId').val());
                         })
                        initialLoad = true;
                       }

                       let userDetails = await this.dataService.getUserDetails(pastChatRoomDao.FirebaseUid);
                       if(userDetails.FirstName.length > 0){

                         pastChatRoomDao.UserDetails = userDetails;
                         pastChatRoomDao.ProfileUrl = userDetails.userProfileUrl;
                         pastChatRoomDao.HasProfilePicture = userDetails.hasProfilePicture;
                         pastChatRooms.push(pastChatRoomDao);
                       }

                     })
                   }
                  })
                }
              })

            })

          })
        })

          callback(pastChatRooms);

      }
    })

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
