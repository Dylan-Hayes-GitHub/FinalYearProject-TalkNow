import { Component, OnInit } from '@angular/core';
import { PendingFriendRequests } from '../Models/Chat';
import { AddFriendService } from './add-friend.service';
import {AngularFireAuth} from "@angular/fire/compat/auth";

@Component({
  selector: 'app-add-friend',
  templateUrl: './add-friend.component.html',
  styleUrls: ['./add-friend.component.css']
})
export class AddFriendComponent implements OnInit {

  constructor(private addFriendService: AddFriendService) { }

  public currentFriendRequest: PendingFriendRequests[] = [];


  ngOnInit(): void {
    this.addFriendService.getIncomingFriendRequests(callback => {
      this.currentFriendRequest = callback;
    });
  }

  public addFriend(firebaseId: string): void {
    this.addFriendService.acceptFriendRequest(firebaseId);
  }

  public cancelFriendRequest(firebaseId: string): void {
    this.addFriendService.declineFriendRequest(firebaseId);
  }

}

