import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { DataService } from '../Data/data.service';
import { FriendList } from '../Models/Chat';
import { StartConversationFromFriendListService } from './start-conversation-from-friend-list.service';

@Component({
  selector: 'app-start-conversation-from-friend-list',
  templateUrl: './start-conversation-from-friend-list.component.html',
  styleUrls: ['./start-conversation-from-friend-list.component.css']
})
export class StartConversationFromFriendListComponent implements OnInit {

  public friendList: FriendList[] = [];
  @Output() friendToMessageEmitter = new EventEmitter<FriendList>();

  constructor(private startConversationService: StartConversationFromFriendListService, private dataService: DataService) { }

  ngOnInit(): void {

    this.startConversationService.getFriendList(callback => {
        this.friendList = callback;


    });
  }

  public messageFriend(friend: FriendList){
    this.friendToMessageEmitter.emit(friend);
  }

}
