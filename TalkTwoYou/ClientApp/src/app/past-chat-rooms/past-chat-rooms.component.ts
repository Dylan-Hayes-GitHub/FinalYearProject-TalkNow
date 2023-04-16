import {Component, EventEmitter, Input, OnInit, Output} from '@angular/core';
import {PastChatRoomServiceService} from "./past-chat-room-service.service";
import {AngularFireAuth} from "@angular/fire/compat/auth";
import {PastChatRoomDao} from "../Models/Chat";
import {DataService} from "../Data/data.service";
import {take} from "rxjs";

@Component({
  selector: 'app-past-chat-rooms',
  templateUrl: './past-chat-rooms.component.html',
  styleUrls: ['./past-chat-rooms.component.css']
})
export class PastChatRoomsComponent implements OnInit {


  @Input() currentLoggedInUserUid: string | undefined;
  @Output() allPastChatRooms = new EventEmitter<PastChatRoomDao[]>();
  @Output() pastConversation = new EventEmitter<string>();
  public pastChatRooms: PastChatRoomDao[] = [];
  public fullyloaded: boolean = false;

  constructor(private pastChatRoomService: PastChatRoomServiceService, private auth: AngularFireAuth, private dataService: DataService) { }

  ngOnInit(): void {
    this.auth.authState.pipe(
      take(1)
    ).subscribe(user => {
      this.pastChatRoomService.getAllPastChatRooms(user?.uid, callback => {
        if(this.pastChatRooms.length == 0){
          this.pastChatRooms = callback;
        } else {
          this.pastChatRooms = callback;
        }
      })
    })

  }

  public pastChatRoomPressed(otherUserFirebaseId: string): void {
    this.pastConversation.emit(otherUserFirebaseId);
  }

}
