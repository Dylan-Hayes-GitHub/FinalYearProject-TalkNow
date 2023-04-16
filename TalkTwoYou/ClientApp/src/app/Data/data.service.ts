import { Injectable } from '@angular/core';
import {CurrentConversationUserDetails, RandomConversationDao, UserLogin} from "../Models/User";
import {BehaviorSubject, Observable} from "rxjs";
import {CurrentConversationDao, PastChatRoomDao} from "../Models/Chat";
import { get, getDatabase, onValue, ref } from '@angular/fire/database';
import { getBlob, getDownloadURL, getStorage, ref as r} from '@angular/fire/storage';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private randomConversation: RandomConversationDao;
  private dataSubject: BehaviorSubject<RandomConversationDao> = new BehaviorSubject({
    FirebaseUid: '',
    Name: '',
  });

  private defaultUserSubject: BehaviorSubject<PastChatRoomDao> = new BehaviorSubject<PastChatRoomDao>({
    AuthorName:"",
    FirebaseUid: "",
    GroupId: "",
    HasProfilePicture: false,
    LastMessage: "",
    SendTime: "",
    ProfileUrl: "",
    Sentiment: ''
  })


  private currentConversationSubject: BehaviorSubject<CurrentConversationDao> = new BehaviorSubject<CurrentConversationDao>({
  GroupId: "",
  OtherUser: "",
  OtherUserFirebaseId: ""})

  private userOnlineSubject: BehaviorSubject<string> = new BehaviorSubject<string>('');

  private currentConversationUserDetailsSubject: BehaviorSubject<CurrentConversationUserDetails> = new BehaviorSubject<CurrentConversationUserDetails>({
    FirstName: "",
    LastName: "",
    deviceNotificationToken: "",
    hasProfilePicture: false,
    FirebaseId: "",
    Email: ""
  });

  private randomConversationUserDetailsSubject: BehaviorSubject<CurrentConversationUserDetails> = new BehaviorSubject<CurrentConversationUserDetails>({
    FirstName: "",
    LastName: "",
    deviceNotificationToken: "",
    hasProfilePicture: false,
    FirebaseId: "",
    Email: ""
  });

  private loggedInUserDetails: BehaviorSubject<CurrentConversationUserDetails> = new BehaviorSubject<CurrentConversationUserDetails>({
    FirstName: "",
    LastName: "",
    deviceNotificationToken: "",
    hasProfilePicture: false,
    FirebaseId: "",
    Email: ""
  });

  private tempUserLogin: BehaviorSubject<UserLogin> = new BehaviorSubject<UserLogin>({
    Email: "", Password: ""
  })

  private allPastChatroomsSubject: BehaviorSubject<PastChatRoomDao[]> = new BehaviorSubject<PastChatRoomDao[]>([
    {
      AuthorName: '',
      ProfileUrl: '',
      HasProfilePicture: false,
      UserDetails: {
        FirstName: '',
        LastName: '',
        deviceNotificationToken: '',
        hasProfilePicture: false,
        FirebaseId: '',
        Email: ''
      },
      FirebaseUid: '',
      GroupId: '',
      LastMessage: '',
      SendTime: '',
      Sentiment: ''
    }
  ])

  constructor() { }

  data$: Observable<RandomConversationDao> = this.dataSubject.asObservable();
  $defaultUser: Observable<PastChatRoomDao> = this.defaultUserSubject.asObservable();
  $currentConversationSubject: Observable<CurrentConversationDao> = this.currentConversationSubject.asObservable();

  $userState: Observable<string> = this.userOnlineSubject.asObservable();
  $currentConversationUserDetails: Observable<CurrentConversationUserDetails> = this.currentConversationUserDetailsSubject.asObservable();
  $andomConversationUserDetails: Observable<CurrentConversationUserDetails> = this.randomConversationUserDetailsSubject.asObservable();
  $loggedInUserDetails:Observable<CurrentConversationUserDetails> = this.loggedInUserDetails.asObservable();
  $tempUserLogin: Observable<UserLogin> = this.tempUserLogin.asObservable();

  $allPastChatRooms: Observable<PastChatRoomDao[]> = this.allPastChatroomsSubject.asObservable();

  setCurrentConversation(data: CurrentConversationDao){
    this.currentConversationSubject.next(data);
  }

  setData(data: RandomConversationDao) {
    this.dataSubject.next(data);
  }

  setDefaultUser(q: PastChatRoomDao){
    this.defaultUserSubject.next(q);
  }

  setUserOnlineState(state: string){
    this.userOnlineSubject.next(state);
  }

  setCurrentConversationUserDetails(userDetails: CurrentConversationUserDetails){
    this.currentConversationUserDetailsSubject.next(userDetails);
  }

  setRandomConversationUserDetails(randomConversationUserDetails: CurrentConversationUserDetails): void {
    this.randomConversationUserDetailsSubject.next(randomConversationUserDetails);
  }

  setLoggedInUserDetails(loggedInUserDetails: CurrentConversationUserDetails){
    this.loggedInUserDetails.next(loggedInUserDetails);
  }

  setTempUserDetails(tempUserLogin: UserLogin){
    this.tempUserLogin.next(tempUserLogin);
  }

  startGettingUserState(firebaseId: string){
    const db = getDatabase();
    const userRef = ref(db, firebaseId+'/status');
    onValue(userRef, snapshot => {
      const val = snapshot.val();

      this.setUserOnlineState(val);
    });

  }

  public setAllPastChatRooms(values: PastChatRoomDao[]){
    this.allPastChatroomsSubject.next(values);
  }

  async getUserConversationDetails(FirebaseId: string) {

    this.getUserDetails(FirebaseId).then(userDetails => {
      this.startGettingUserState(FirebaseId);
      this.setCurrentConversationUserDetails(userDetails)
    });

  }

  async startGettingloggedInUserDetails(firebaseId: string){

      this.getUserDetails(firebaseId).then(userDetails => {

        this.setLoggedInUserDetails(userDetails);
      })

  }

  async getUserProfileImage(FirebaseId: string): Promise<string> {
    const storage = getStorage();
    const userProfileRef = r(storage, FirebaseId);
    const userProfileUrl = await getBlob(userProfileRef);

    const blob = userProfileUrl;
    const reader = new FileReader();
    reader.readAsDataURL(blob);

    return new Promise<string>((resolve, reject) => {
      reader.onloadend = () => {
        const base64data = reader.result;
        if (base64data != null) {
          // Store the base64-encoded string in local storage
          localStorage.setItem(FirebaseId, String(base64data));
          // Resolve the Promise with the base64-encoded string
          resolve(String(base64data));
        }
      };

      reader.onerror = () => {
        reject("Failed to read the Blob as a data URL.");
      };
    });
  }

  public async getUserDetails(pendingFirebaseId: string): Promise<CurrentConversationUserDetails> {
    let userDetailsToReturn: CurrentConversationUserDetails = new class implements CurrentConversationUserDetails {
      Email: string;
      FirebaseId: string;
      FirstName: string;
      LastName: string;
      deviceNotificationToken: string;
      hasProfilePicture: boolean;
      userProfileUrl: string;
      FriendsAlready: boolean;
      DetailsFullyFetched: boolean;
    }
    const db = getDatabase();
    const otherUserRef = ref(db, pendingFirebaseId);
    const snapshot = await get(otherUserRef);

    if (snapshot.hasChildren()) {
      if(snapshot.hasChild('hasProfilePicture')){
        if (localStorage.getItem(pendingFirebaseId) != null) {
          //user has a profile image and store it to local storage
          userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
          userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
          userDetailsToReturn.LastName = snapshot.child('LastName').val();
          userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
          userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
          userDetailsToReturn.Email = snapshot.child('Email').val();
          userDetailsToReturn.FirebaseId = pendingFirebaseId;
          userDetailsToReturn.FriendsAlready = true;
          userDetailsToReturn.FriendRequestSent = true;
          userDetailsToReturn.DetailsFullyFetched = true;
          return userDetailsToReturn;

        } else {
          //download image and then assign
          await this.getUserProfileImage(pendingFirebaseId).then(done => {
            userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
            userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
            userDetailsToReturn.LastName = snapshot.child('LastName').val();
            userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
            userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
            userDetailsToReturn.Email = snapshot.child('Email').val();
            userDetailsToReturn.FirebaseId = pendingFirebaseId;
            userDetailsToReturn.FriendsAlready = true;
            userDetailsToReturn.FriendRequestSent = true;
            userDetailsToReturn.DetailsFullyFetched = true;
          });
          return userDetailsToReturn;

        }
      } else {
        userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
        userDetailsToReturn.LastName = snapshot.child('LastName').val();
        userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
        userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
        userDetailsToReturn.Email = snapshot.child('Email').val();
        userDetailsToReturn.FirebaseId = pendingFirebaseId;
        userDetailsToReturn.FriendsAlready = true;
        userDetailsToReturn.FriendRequestSent = true;
        userDetailsToReturn.DetailsFullyFetched = true;

      }
      return userDetailsToReturn;
    }
    return userDetailsToReturn;
  }

  public async getRandomUserDetails(pendingFirebaseId: string, firebaseId: string): Promise<CurrentConversationUserDetails> {
    let userDetailsToReturn: CurrentConversationUserDetails = new class implements CurrentConversationUserDetails {
      Email: string;
      FirebaseId: string;
      FirstName: string;
      LastName: string;
      deviceNotificationToken: string;
      hasProfilePicture: boolean;
      userProfileUrl: string;
      FriendRequestSent: boolean;
    }
    const db = getDatabase();
    const otherUserRef = ref(db, pendingFirebaseId);
    const otherUserFriendRequestsRef = ref(db, pendingFirebaseId+'/friendRequests');

    const snapshot = await get(otherUserRef);

    if (snapshot.hasChildren()) {
      if(snapshot.hasChild('hasProfilePicture')){
        if (localStorage.getItem(pendingFirebaseId) != null) {
          //user has a profile image and store it to local storage


          get(otherUserFriendRequestsRef).then(value => {
            value.forEach(child => {
              if(child.child('FirebaseId').val() == firebaseId){
                userDetailsToReturn.FriendRequestSent = true;
              }
            })
          })
          userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
          userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
          userDetailsToReturn.LastName = snapshot.child('LastName').val();
          userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
          userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
          userDetailsToReturn.Email = snapshot.child('Email').val();
          userDetailsToReturn.FirebaseId = pendingFirebaseId;
          userDetailsToReturn.FriendsAlready = false;
          userDetailsToReturn.DetailsFullyFetched = true;
          return userDetailsToReturn;

        } else {
          get(otherUserFriendRequestsRef).then(value => {
            value.forEach(child => {
              if(child.child('FirebaseId').val() == firebaseId){
                userDetailsToReturn.FriendRequestSent = true;
              }
            })
          })
          //download image and then assign
          await this.getUserProfileImage(pendingFirebaseId).then(done => {

            userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
            userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
            userDetailsToReturn.LastName = snapshot.child('LastName').val();
            userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
            userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
            userDetailsToReturn.Email = snapshot.child('Email').val();
            userDetailsToReturn.FirebaseId = pendingFirebaseId;
            userDetailsToReturn.FriendsAlready = false;
            userDetailsToReturn.FriendRequestSent = false;
            userDetailsToReturn.DetailsFullyFetched = true;
          });
          return userDetailsToReturn;

        }
      } else {
        get(otherUserFriendRequestsRef).then(value => {
          value.forEach(child => {
            if(child.child('FirebaseId').val() == firebaseId){

              userDetailsToReturn.FriendRequestSent = true;
            }
          })
        })
        userDetailsToReturn.FirstName = snapshot.child('FirstName').val();
        userDetailsToReturn.LastName = snapshot.child('LastName').val();
        userDetailsToReturn.deviceNotificationToken = snapshot.child('fcmSendToken').val();
        userDetailsToReturn.hasProfilePicture = snapshot.child('hasProfilePicture').val();
        userDetailsToReturn.Email = snapshot.child('Email').val();
        userDetailsToReturn.FirebaseId = pendingFirebaseId;
        userDetailsToReturn.FriendsAlready = false;
        userDetailsToReturn.FriendRequestSent = false;
        userDetailsToReturn.DetailsFullyFetched = true;
      }
      return userDetailsToReturn;



      // if (userDetailsToReturn.hasProfilePicture) {
      //   if (localStorage.getItem(pendingFirebaseId) != null) {
      //     //user has a profile image and store it to local storage
      //     userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
      //   } else {
      //     console.log("download image")
      //     //download image and then assign
      //     await this.getUserProfileImage(pendingFirebaseId).then(t => {
      //
      //     });
      //     userDetailsToReturn.userProfileUrl = localStorage.getItem(pendingFirebaseId) as string;
      //
      //   }
      //   userDetailsToReturn.DetailsFullyFetched = true;
      //
      //   return userDetailsToReturn;
      // }
    }
    return userDetailsToReturn;
  }

  ngOnDestroy() {
    this.dataSubject.complete();
    this.defaultUserSubject.complete();
  }
}
