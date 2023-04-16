import { Injectable } from '@angular/core';
import {AngularFireAuth} from "@angular/fire/compat/auth";
import { get, getDatabase, onValue, query, ref } from '@angular/fire/database';
import { FriendList } from '../Models/Chat';
import {CurrentConversationUserDetails} from "../Models/User";
import {getBlob, getStorage, ref as r} from "@angular/fire/storage";
import {DataService} from "../Data/data.service";

@Injectable({
  providedIn: 'root'
})
export class StartConversationFromFriendListService {

  constructor(private auth: AngularFireAuth, private dataService: DataService) { }

  public getFriendList(callback: (userFriends: FriendList[]) => void): FriendList[] {

    let friendList: FriendList[] = [];

    this.auth.user.subscribe(loggedInUser => {
      const db = getDatabase();
      const friendListLocation = loggedInUser?.uid + '/friends/';
      const reference = ref(db, friendListLocation);
      //do a get request from a query
      let getFriendsQuery = query(reference);

      onValue(getFriendsQuery, userFriendList => {
        friendList = [];
        userFriendList.forEach(friend => {
          let userFriend = new class implements FriendList {
            UserDetails: CurrentConversationUserDetails;
            FirebaseId: string;
            Name: string;
          };

          userFriend.FirebaseId = friend.child('FirebaseId').val();
          userFriend.Name = friend.child('Name').val();

          this.dataService.getUserDetails(userFriend.FirebaseId).then(userDetails => {
            userFriend.UserDetails = userDetails;
            friendList.push(userFriend);
          })
        })
        callback(friendList);
      })
    })

    return friendList;
  }

}
