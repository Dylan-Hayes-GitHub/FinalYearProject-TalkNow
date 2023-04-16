import {Component, EventEmitter, OnInit, Output} from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import {StartNewConversationService} from "./start-new-conversation.service";
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { StartNewConversationPopUpComponent } from '../startNewConversationPopup/start-new-conversation-pop-up/start-new-conversation-pop-up.component';
@Component({
  selector: 'app-start-new-conversation',
  templateUrl: './start-new-conversation.component.html',
  styleUrls: ['./start-new-conversation.component.css']
})
export class StartNewConversationComponent implements OnInit {

  @Output() startNewConversationPressed = new EventEmitter<boolean>();
  @Output() startFriendConversationEmitter = new EventEmitter<boolean>();

  @Output() joinedRandomConversation = new EventEmitter<boolean>();

  constructor(private startConversationService : StartNewConversationService, private auth: AngularFireAuth, public dialog: MatDialog) { }
  public dialogRef: MatDialogRef<StartNewConversationPopUpComponent>;

  ngOnInit(): void {

  }

  public startRandomConversation(): void {

    //make dialog pop up
    this.dialogRef = this.dialog.open(StartNewConversationPopUpComponent);
    this.dialogRef.afterClosed().subscribe(result => {

      this.auth.user.subscribe(user => {
        if(user != null)
        //leave the queue from here
        this.startConversationService.leaveQueue(user?.uid);
      })
    });

    this.auth.user.subscribe(user => {
      if(user != null)
      this.startConversationService.joinRandomConversation(user?.uid);
      //this.startNewConversationPressed.emit(true);
      this.startCheckingForRandomConversationState();

    })



  }

  startCheckingForRandomConversationState() {
    this.startConversationService.$joinedRandomConversationSubject.subscribe(joinedRandom => {
      this.joinedRandomConversation.emit(joinedRandom);
      if(joinedRandom){
        this.dialogRef.close();
      }
    })

  }

  public startFriendConversation(): void {
    this.startFriendConversationEmitter.emit(true);
  }

}
