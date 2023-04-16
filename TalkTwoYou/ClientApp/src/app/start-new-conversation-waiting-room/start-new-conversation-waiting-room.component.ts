import {Component, EventEmitter, OnInit, Output} from '@angular/core';
import {DataService} from "../Data/data.service";
import {RandomConversationDao} from "../Models/User";
import { MatDialog } from '@angular/material/dialog';
import { StartNewConversationPopUpComponent } from '../startNewConversationPopup/start-new-conversation-pop-up/start-new-conversation-pop-up.component';

@Component({
  selector: 'app-start-new-conversation-waiting-room',
  templateUrl: './start-new-conversation-waiting-room.component.html',
  styleUrls: ['./start-new-conversation-waiting-room.component.css']
})
export class StartNewConversationWaitingRoomComponent implements OnInit {

  @Output() foundUserForConversation = new EventEmitter<RandomConversationDao>();

  constructor(private dataService: DataService, public dialog: MatDialog) { }

  ngOnInit(): void {


  }

  ngAfterViewInit(): void {

    this.dataService.data$.subscribe(data => {
      //if this is updated then a new conversation can be started
      if(data.Name != "" && data.FirebaseUid != ""){
        this.foundUserForConversation.emit(data);
      }
    })
  }

}
