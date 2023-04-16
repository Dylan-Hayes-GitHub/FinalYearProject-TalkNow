import { ChangeDetectionStrategy, Component, OnInit } from '@angular/core';
import {MatDialogRef} from "@angular/material/dialog";

@Component({
  selector: 'app-start-new-conversation-pop-up',
  templateUrl: './start-new-conversation-pop-up.component.html',
  styleUrls: ['./start-new-conversation-pop-up.component.css'],
})
export class StartNewConversationPopUpComponent {

  constructor(private dialogRef: MatDialogRef<StartNewConversationPopUpComponent>) {
  }
  leaveQueue() {
    this.dialogRef.close();
  }
}
