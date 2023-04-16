import {Component, DoCheck, ElementRef, OnChanges, OnInit, SimpleChanges, ViewChild} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {CurrentConversationDao, FriendList, Message, PastChatRoomDao} from "../Models/Chat";
import {FormBuilder, FormControl, FormGroup, Validators} from "@angular/forms";
import {ChatService} from "./chat.service";
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {ActivatedRoute} from "@angular/router";
import {DataService} from "../Data/data.service";
import {CurrentConversationUserDetails, RandomConversationDao} from "../Models/User";
import { UserPresenceServiceService } from '../presence/user-presence-service.service';
import { filter, first, take } from 'rxjs';
import {StartNewConversationService} from "../start-new-conversation/start-new-conversation.service";


// Keyboard.setScroll({ isDisabled: true }).then(res => {
//   res
// })
@Component({
  selector: 'app-chat',
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.css']
})
export class ChatComponent implements OnInit, OnChanges {


  public currentMessages: any[] = [];
  public messagesRetrievedFromServer: Message[] = [];
  public currentMessage: string;
  public formGroup: FormGroup;

  public currentMessageForReporting: string = "";

  public fullyLoaded: boolean = false;

  //side navigation
  public pastChatRooms: boolean = true;
  public addFriendsDiv: boolean = false;
  public settings: boolean = false;
  public newConversation: boolean = false;
  public startConversationWaitingRoom: boolean = false;
  public friendConversation: boolean = false;

  public randomConversationBoolean: boolean = false;

  public friendRequestRecieved: boolean = false;

  //firebase user
  public currentUser: any = null;
  public currentUserUid: string | undefined = "";
  public firebaseProfileImageUrl = "";

  public defaultMessageUser: RandomConversationDao;

  public userOnlineState: string = "";

  public currentUserInConversation: CurrentConversationUserDetails;
  public loggedInUserDetails: CurrentConversationUserDetails;

  @ViewChild('scrollableDiv')  divRef: ElementRef;




  //random conversation dao
  public randomConversationUser: RandomConversationDao = new class implements RandomConversationDao {
    FirebaseUid: string;
    Name: string;
  }

  constructor(private http: HttpClient, private fb: FormBuilder,
              private chatService: ChatService, private auth: AngularFireAuth,
              private route: ActivatedRoute, private dataService: DataService,
              private startConversationService: StartNewConversationService, private userPresence: UserPresenceServiceService) {}


  ngOnInit(): void {

    this.auth.authState.subscribe(async user => {
      this.currentUser = user;
      this.currentUserUid = user?.uid;
      //store details on current logged in user into dataservice
      if(user != null){
        this.dataService.startGettingloggedInUserDetails(user.uid).then(finished => {
          this.dataService.$loggedInUserDetails.pipe(
            filter((x: CurrentConversationUserDetails) =>
                x.FirstName !== null
                && x.LastName !== null
                && x.DetailsFullyFetched !== undefined)).subscribe(value => {
            //TODO check here for all not null
            if(value.hasProfilePicture){
              value.userProfileUrl = localStorage.getItem(value.FirebaseId) as string;
            }
            this.loggedInUserDetails = value;
            this.chatService.getLoggedInUserDetails(this.loggedInUserDetails);

            this.createFormGroup();
            this.loadMainScreenChat();
            this.chatService.validateToken();
          })




        });



      }


    })


 }
 @ViewChild('scrollableDiv', { static: true }) scrollableDiv: ElementRef;

 ngAfterViewInit(): void {
  //Called after ngAfterContentInit when the component's view has been initialized. Applies to components only.
  //Add 'implements AfterViewInit' to the class.
  if(this.fullyLoaded){
    this.scrollDivToBottom();

  }


 }

 ngAfterViewChecked(): void {
 }
  scrollDivToBottom() {
    if(this.divRef.nativeElement != undefined && this.fullyLoaded){
      this.divRef.nativeElement.scrollTop =  this.divRef.nativeElement.scrollHeight - this.divRef.nativeElement.clientHeight;
    }
  }

  public sendMessage() {

    if(this.formGroup.valid) {
      let date = new Date();
      let formattedTime = this.formatAMPM(date);
      let messageToSend: Message = new class implements Message {
        Sentiment: string;
        Author: string;
        FromClient: string;
        Message: string;
        ReadableTime: string;
        TimeStamp: string;
        GroupId: string;
      };
      messageToSend.Message = this.formGroup.get('messageToSendToOtherUser')?.value;
      messageToSend.Author = localStorage.getItem('name') as string;
      messageToSend.TimeStamp = date.toString();
      messageToSend.ReadableTime = formattedTime;
      messageToSend.FromClient = '';
      messageToSend.Sentiment = '';
      messageToSend.GroupId = '';



      this.chatService.sendMessage(messageToSend, this.currentUserInConversation);

      this.formGroup.controls.messageToSendToOtherUser.setValue('');
    }


  }

  public formatAMPM(date: Date) {
    let hours = date.getHours();
    let minutes: any = date.getMinutes();
    let ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12; // the hour '0' should be '12'
    minutes = minutes < 10 ? '0'+minutes : minutes;
    return hours + ':' + minutes + ' ' + ampm;
  }

  ngOnChanges(changes: SimpleChanges): void {

    //TODO later work, when auth is added pass in the user name of the current auth user and the ID of the other firebase user
    this.scrollDivToBottom();
  }

  private createFormGroup(): void {
    this.formGroup = this.fb.group({
      messageToSendToOtherUser: new FormControl(null, Validators.required)
    },
      {updateOn: 'submit'});
  }


  public addFriend(): void{
    this.addFriendsDiv = true;
    this.pastChatRooms = false;
    this.newConversation = false;
    this.settings = false;
  }

  public sendHome(): void {
    this.pastChatRooms = true;
    this.addFriendsDiv = false;
    this.newConversation = false;
    this.settings = false;
    this.friendConversation = false;

  }

  public startNewConversation() : void {
    this.newConversation = true;
    this.pastChatRooms = false;
    this.addFriendsDiv = false;
    this.settings = false;

  }

  public userSettings(): void {
    this.settings = true;
    this.newConversation = false;
    this.pastChatRooms = false;
    this.addFriendsDiv = false;
  }

  public startConversationRoom(startConversationButtonPressed: boolean) {
    this.startConversationWaitingRoom = startConversationButtonPressed;
  }

  public startRandomUserConversation(randomMatchedUser: RandomConversationDao): void {
    this.randomConversationUser = randomMatchedUser;
    this.startConversationWaitingRoom = false;
  }

  public addRandomUser(): void {
   //hide add friend button
   this.currentUserInConversation.FriendRequestSent = true;
    let userToAdd: RandomConversationDao = new class implements RandomConversationDao {
      FirebaseUid: string;
      Name: string;
    }

    this.dataService.$currentConversationUserDetails.pipe(
      filter(x => x.FirebaseId.length > 0)
        ,take(1)
    ).subscribe(currentUserInConversation => {
      userToAdd.FirebaseUid = currentUserInConversation.FirebaseId;
      this.chatService.addUserAsFriend(userToAdd);

    })




  }


  public loadMainScreenChat(): void {

    this.dataService.$currentConversationUserDetails.subscribe(currentUserConversationDetails => {
      if(currentUserConversationDetails != null && !this.randomConversationBoolean){
        this.getDefaultChat(currentUserConversationDetails);
        this.currentUserInConversation = currentUserConversationDetails
        this.dataService.$userState.subscribe(onlineStatus => {
          this.userOnlineState = onlineStatus;
          });
      }
    })
    // this.dataService.$currentConversationUserDetails.subscribe(currentUserConversationDetails => {



    // })

  }

  public getDefaultChat(currnetConversation: CurrentConversationUserDetails): void{

    //check to see if a user has a profile picture
    // if(currnetConversation.hasProfilePicture){
    //   //get url to image will be a callback
    //   this.chatService.getUserProfileImage(currnetConversation.FirebaseId, imageUrl => {
    //     this.firebaseProfileImageUrl = imageUrl;
    //   })
    // }

    this.dataService.$loggedInUserDetails.pipe(take(1)).subscribe(loggedInUser => {
      let userProfileUrl = localStorage.getItem(loggedInUser.FirebaseId);
      if(loggedInUser.hasProfilePicture && userProfileUrl == null){
        //download logged in user profile
        this.chatService.getUserProfileImage(loggedInUser.FirebaseId, imageUrl => {

        })
      } else {
        this.firebaseProfileImageUrl = localStorage.getItem(loggedInUser.FirebaseId) as string;
      }

    })

    this.chatService.getMessagesInGroupChat(currnetConversation, messages => {
      if ((messages.length > 0 && messages[0].Author != null) || (!currnetConversation.FriendsAlready && currnetConversation.FirstName.length > 0)) {
        this.messagesRetrievedFromServer = messages;
        setTimeout(() => {
          this.scrollDivToBottom();

        }, 0);


      }
      this.fullyLoaded = true;
    });

  }

  public startFriendConversation($event: boolean) {
    this.friendConversation = $event;
    this.randomConversationBoolean = false;

  }

  public startConversationWithFriend(friend: FriendList){
    if(this.randomConversationBoolean){
      this.randomConversationBoolean = false;
      this.startConversationService.setJoinedRandomConversation(false);
    }

    this.friendConversation = false;

    this.dataService.getUserConversationDetails(friend.FirebaseId);
    this.loadMainScreenChat();
  }

  startRandomPersonConversation(randomConversation: boolean) {
    if(randomConversation){

      this.randomConversationBoolean = true;
      this.dataService.$currentConversationUserDetails.subscribe(randomUserDetails => {
        this.chatService.startCheckingForFriendRequest(randomUserDetails, callback => {
          if(callback){
            this.friendRequestRecieved = callback;

          } else {
            this.friendRequestRecieved = false;
          }
        });

        this.currentUserInConversation = randomUserDetails;
        this.getDefaultChat(randomUserDetails);
      })
      this.dataService.startGettingUserState(this.currentUserInConversation.FirebaseId);

      //load chat first then change screen

        this.dataService.$userState.subscribe((state) => {
          this.userOnlineState = state;
        });


      this.startConversationService.setJoinedRandomConversation(false);

      this.pastChatRooms = true;
      this.addFriendsDiv = false;
      this.newConversation = false;
      this.settings = false;
      this.startConversationWaitingRoom = false;

      //reset dataserice
    }

  }

  async pastConversation(firebaseId: string) {
      await this.dataService.getUserConversationDetails(firebaseId);
    this.startConversationService.setJoinedRandomConversation(false);

    this.dataService.$currentConversationUserDetails.pipe(
      filter(((x) => (x.FirstName.length > 0 && x.FriendsAlready == true)|| x.FirebaseId == '')),
      take(1)
    ).subscribe(async userDetails => {
      await this.dataService.getUserConversationDetails(firebaseId);
      this.getDefaultChat(userDetails);

      this.dataService.$userState.subscribe(onlineStatus => {
        this.userOnlineState = onlineStatus;
      });


      this.pastChatRooms = true;
      this.addFriendsDiv = false;
      this.newConversation = false;
      this.settings = false;
      this.startConversationWaitingRoom = false;
      this.randomConversationBoolean = false;
    })


  }

  reportMessage(message: Message) {

    if(message.TimeStamp == this.currentMessageForReporting){
      this.currentMessageForReporting = "";
    } else {
      this.currentMessageForReporting = message.TimeStamp;

    }
  }

  reportSelectedMessage(message: Message) {
    this.currentMessageForReporting = "";
    this.chatService.reportMessage(message);
  }
}
