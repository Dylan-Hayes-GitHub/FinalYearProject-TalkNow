import {Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {get, getDatabase, onValue, push, ref, remove, set, } from "@angular/fire/database";
import {CurrentConversationUserDetails, RandomConversationDao, UserDetails} from "../Models/User";
import {RefreshToken} from "../Models/Tokens";
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {NavigationExtras, Router} from "@angular/router";
import {DataService} from "../Data/data.service";
import { CurrentConversationDao, PastChatRoomDao } from '../Models/Chat';
import { BehaviorSubject, Observable } from 'rxjs';
import {getBlob, getStorage, ref as r, Storage} from "@angular/fire/storage";


@Injectable({
  providedIn: 'root'
})
export class StartNewConversationService {

  constructor(private http: HttpClient, private auth: AngularFireAuth, private router: Router, private dataService: DataService) { }
  public subscription: any;
  joinedRandomConversationSubject: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);

  $joinedRandomConversationSubject: Observable<boolean> = this.joinedRandomConversationSubject.asObservable();

  public async joinRandomConversation(firebaseId: string) {
    const db = getDatabase();

    //get reference to queue
    let queueRef = ref(db, 'queue');
     this.subscription = onValue(queueRef, snapshot => {
      if(!snapshot.exists()) {
        //set the queue value in firebase if it doesnt exist already
        set(queueRef, '');
      } else {
        let valuesExist = snapshot.val();
        if(valuesExist != ""){
          //check to see if user already exists within the queue
          let addedToQueue = false;
          snapshot.forEach(values => {
            if(values.child('firebaseId').val() === firebaseId){
              addedToQueue = true;
            }
          });

          if(!addedToQueue){
            push(queueRef, {
              'firebaseId': firebaseId
            });
          } else if(snapshot.size === 2){
            //stop listening
            this.subscription();

            let counter = 0;
            let otherUserForChatId = '';
            snapshot.forEach(value => {
              if(counter === 2){
                return;
              }
              if(value.child('firebaseId').val() !== firebaseId){
                otherUserForChatId = value.child('firebaseId').val();
              }
            });

            counter = 0;
            //perform loop to remove both users from the queue
            snapshot.forEach(value => {
              if(counter === 2){
                return;
              } else {
                remove(ref(db, 'queue/'+value.key));
                counter++;
              }
            });

            this.dataService.getRandomUserDetails(otherUserForChatId, firebaseId).then(userDetails => {
              this.dataService.startGettingUserState(firebaseId);
              this.dataService.setCurrentConversationUserDetails(userDetails);
              this.setJoinedRandomConversation(true);
            })
          }
        } else if(snapshot.size < 2) {
          push(queueRef, {
            'firebaseId': firebaseId
          });
        }
      }
    });
  }

  setJoinedRandomConversation(res: boolean){
    this.joinedRandomConversationSubject.next(res);
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


  public leaveQueue(uid: string | undefined): void {
    this.subscription();

    const db = getDatabase();

    const queueRef = ref(db, 'queue');

    get(queueRef).then(snapshot => {
      if(snapshot.hasChildren()){
        snapshot.forEach( (users) => {
          if(users.child('firebaseId').val() == uid){
            //remove the user
            const removeRef =  ref(db, `queue/${users.key}`);

            remove(removeRef).then(done => {
            });

          }
        })
      }
    })
  }
}
