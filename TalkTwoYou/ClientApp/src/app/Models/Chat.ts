import {CurrentConversationUserDetails} from "./User";

export interface Message {
  Message: string,
  Author: string;
  TimeStamp: string;
  ReadableTime: string;
  FromClient: string;
  Sentiment: string;
  GroupId: string;
  Key?:  string | null;
}

export interface Sentiment {
  sentiment: string;
}

export interface PastChatRoomDao {
  AuthorName: string;
  LastMessage: string;
  SendTime: string;
  FirebaseUid: string;
  GroupId: string;
  HasProfilePicture: boolean;
  ProfileUrl?: string;
  UserDetails?: CurrentConversationUserDetails;
  Sentiment: string;
}


export interface PendingFriendRequests {
  FirebaseId: string;
  Name: string;
  Accepted: boolean;
  Declined: string;
  UserDetails: CurrentConversationUserDetails;
}

export interface FriendList {
  FirebaseId: string;
  Name: string;
  UserDetails: CurrentConversationUserDetails;
}

export interface CurrentConversationDao {
  OtherUser: String;
  OtherUserFirebaseId: string;
  GroupId: String;
}

