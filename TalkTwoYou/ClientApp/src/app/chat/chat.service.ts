import { Injectable } from '@angular/core';
import {HttpClient, HttpParams, HttpHeaders} from "@angular/common/http";
import {Database, getDatabase, ref, set, push, onValue, get, update} from "@angular/fire/database";
import {CurrentConversationDao, Message, PastChatRoomDao, Sentiment} from "../Models/Chat";
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {CurrentConversationUserDetails, RandomConversationDao} from "../Models/User";
import { AuthService } from '../Auth/auth.service';
import { DataService } from '../Data/data.service';
import { getBlob, getDownloadURL, getStorage, ref as r} from '@angular/fire/storage';
import {take} from "rxjs";



@Injectable({
  providedIn: 'root'
})
export class ChatService {


  constructor(private http: HttpClient, private firebaseRds: Database, private auth: AngularFireAuth, private authService: AuthService, private dataService: DataService) { }

  public sendMessage(message: Message, currentConversation: CurrentConversationUserDetails): void{


    let headersToSend = new HttpHeaders();
    headersToSend.append('Access-Control-Allow-Origin', 'http://localhost:4200');
    headersToSend.append('Access-Control-Allow-Credentials', 'true');
    let jwt = localStorage.getItem('jwt');
    const params = new HttpParams().set('message', message.Message);
    //send request first to ML REST API to get sentiment of message
    this.http.get('http://127.0.0.1:5000/predict', {params: params, headers: {"Authorization": `Bearer ${jwt}`}}).subscribe(response => {
      let sentiment: Sentiment = response as Sentiment
      let isPositive = +sentiment.sentiment > 0.65 ? 'Negative' : 'Positive'

      //perform firebase call
      const db = getDatabase();

      this.auth.user.subscribe(user => {
        //TODO need to get normal user UID here if not random convo
        const messageStorePath = user?.uid+'/'+ 'messages/'+ currentConversation.FirebaseId;

        //The saving of messages need to happen twice so both user have a reference
        const secondStorePath = currentConversation.FirebaseId+'/' + 'messages/' + user?.uid;
        push(ref(db, messageStorePath), {
          Message: message.Message,
          Author: message.Author,
          TimeStamp: message.TimeStamp,
          ReadableTime: message.ReadableTime,
          FromClient: user?.uid,
          GroupId: currentConversation.FirebaseId,
          Sentiment: isPositive
        });

        push(ref(db, secondStorePath), {
          Message: message.Message,
          Author: message.Author,
          TimeStamp: message.TimeStamp,
          ReadableTime: message.ReadableTime,
          FromClient: user?.uid,
          GroupId: user?.uid,
          Sentiment: isPositive
        });
      });

      //check to see if other user has a device token
      const otherUserDeviceToken = ref(db, currentConversation.FirebaseId);

      get(otherUserDeviceToken).then(userData => {
        if(userData.hasChild('fcmSendToken')){
          const fcmSendToken = userData.child('fcmSendToken').val();
          if (fcmSendToken) {
            const httpOptions = {
              headers: new HttpHeaders({
                'Content-Type': 'application/json',
                'Authorization': 'Bearer AAAAN2HpBHs:APA91bFIBC3sJ1hCnLwBtpTXqCAUkhBJvMSu07v6Y_fYIFvrPvOydPPngESeVZBSmt9eyll3dlhE2W-fkk0YjR-WuDT5nyUbovq-rnrhz7RGlO4n-z9Jh7B_KIgw3j0voYhoUDHnvfIs'
              })
            };
            const notificationBody = {
              to: fcmSendToken,
              notification: {
                title: 'title',
                body: message.Message
              }
            };
            this.http.post('https://fcm.googleapis.com/fcm/send', notificationBody, httpOptions)
              .subscribe(response => {
              }, error => {
              });
          }
        }
      })
    });
  }

  public getMessagesInGroupChat(currentConversation: CurrentConversationUserDetails,callback: (messages: Message[]) => void): void {
    let messagesToReturn: Message[] = [];
    //get user online status
    this.auth.user.subscribe(user => {
      if(user != null && currentConversation != null){
        //const messagesUrl = randomUser.Name == "" ? user?.uid+'/'+ 'messages/' : user?.uid+'/'+'messages/'+ randomUser.FirebaseUid;
        const messagesUrl = user?.uid + '/messages/' + currentConversation.FirebaseId;
        //fetch the messages from firebase
        const db = getDatabase();
        const messageRef = ref(db, messagesUrl);
        onValue(messageRef, (datasnapshot) => {
          messagesToReturn = [];
          datasnapshot.forEach(message => {
            let newMessageObject: Message = new class implements Message {
              Sentiment: string;
              Author: string;
              FromClient: string;
              Message: string;
              ReadableTime: string;
              TimeStamp: string;
              GroupId: string;
              Key: string | null;
            };
            newMessageObject.Author = message.child('Author').val();
            newMessageObject.FromClient = message.child('FromClient').val();
            newMessageObject.Message = message.child('Message').val();
            newMessageObject.ReadableTime = message.child('ReadableTime').val();
            newMessageObject.TimeStamp =message.child('TimeStamp').val();
            newMessageObject.Sentiment = message.child('Sentiment').val();
            newMessageObject.GroupId = message.child('GroupId').val();
            newMessageObject.Key = message?.key;
            //check to see if this person is
            messagesToReturn.push(newMessageObject);
  });
  callback(messagesToReturn)
});
      }

    });
  }

  public getMessageForGroupChat(): Message[]{
    let messagesToReturn: Message[] = [];
/*    this.getMessagesInGroupChat((messages: Message[]) => {
      messagesToReturn = messages;
    });*/
    return messagesToReturn;
  }

  public validateToken(): void{
    this.authService.isLoggedIn$.subscribe(res => {
    })
  }

  public addUserAsFriend(randomUser: RandomConversationDao): void{
    //place in firebase instance
    //first get current logged in user through firebase auth

    this.auth.user.subscribe(loggedInUser => {
    const friendRequestLocation = randomUser.FirebaseUid+ '/friendRequests/';

    const db = getDatabase();

    const friendRequestRef = ref(db, friendRequestLocation);

    push(friendRequestRef, {
      FirebaseId: loggedInUser?.uid,
      Name: localStorage.getItem('name') as string,
      Accepted: false,
      Declined: ""
    })
    })
  }

  // async getUserConversationDetails(FirebaseId: string) {
  //   console.log("called")
  //   const db = getDatabase();
  //   const userRef = ref(db, FirebaseId);
  //
  //   await get(userRef).then(userDetail => {
  //
  //     //create user details
  //     let userDetails: CurrentConversationUserDetails = new class implements CurrentConversationUserDetails {
  //       FirstName: string;
  //       LastName: string;
  //       deviceNotificationToken: string;
  //       hasProfilePicture: boolean;
  //       FirebaseId: string;
  //       Email: string;
  //     }
  //
  //     userDetails.FirstName = userDetail.child('FirstName').val();
  //     userDetails.LastName = userDetail.child('LastName').val();
  //     userDetails.deviceNotificationToken = userDetail.child('fcmSendToken').val();
  //     userDetails.hasProfilePicture = userDetail.child('hasProfilePicture').val();
  //     userDetails.FirebaseId = FirebaseId;
  //     userDetails.Email = userDetail.child('Email').val();
  //
  //     if(userDetails.hasProfilePicture){
  //       this.getUserProfileImage(userDetails.FirebaseId, url => {
  //         userDetails.userProfileUrl = url;
  //       })
  //     }
  //
  //
  //     this.dataService.startGettingUserState(FirebaseId);
  //     this.dataService.setCurrentConversationUserDetails(userDetails);
  //   })
  // }

  async getUserProfileImage(FirebaseId: string, arg1: (imageUrl: any) => void) {
    const storage = getStorage();

    const userProfileRef = r(storage, FirebaseId);

    await getBlob(userProfileRef).then(userProfileUrl => {
      // localStorage.setItem(FirebaseId, userProfileUrl);
      arg1(userProfileUrl);
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

  getLoggedInUserDetails(loggedInUserDetails: CurrentConversationUserDetails) {

  }

  reportMessage(message: Message) {

    this.auth.user.pipe(
      take(1)
    ).subscribe(loggedInUser => {
      const db = getDatabase();
      const loggedInUserMessageRef = ref(db, `${loggedInUser?.uid}/messages/${message.GroupId}/${message.Key}`);

      const updateData = {
        "Sentiment": "Negative"
      }

      update(loggedInUserMessageRef, updateData);
      const reportMessageRef = ref(db, 'reportedMessages');
      push(reportMessageRef, {
        'Message': message.Message,
        'Sentiment': '1'
      });
    });
  }

  startCheckingForFriendRequest(randomUserDetails: CurrentConversationUserDetails, callback: (userAdded: boolean) => void) {

    const db = getDatabase();

    this.auth.user.subscribe(user => {
      const friendRequestRef = ref(db, user?.uid+"/friendRequests");

      onValue(friendRequestRef, requests => {
        requests.forEach(child => {
          if(child.child('FirebaseId').val() == randomUserDetails.FirebaseId){
            callback(true);
          }
        });
      })
    })

  }
}
