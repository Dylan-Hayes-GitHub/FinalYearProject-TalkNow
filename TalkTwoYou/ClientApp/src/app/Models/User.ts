export interface NewUser {
  FirstName: string,
  LastName: string,
  Email: string,
  Password: string,
  FirebaseUid: string
}

export interface UserLogin {
  Email: string,
  Password: string
}

export interface UserDetails {
  UserId: string,
  Name: string
}

export interface RandomConversationDao {
  Name: string,
  FirebaseUid: string
}

export interface CurrentConversationUserDetails {
  FirstName: string;
  LastName: string;
  deviceNotificationToken: string;
  hasProfilePicture: boolean;
  FirebaseId: string;
  userProfileUrl?: string;
  Email: string;
  FriendRequestSent?: boolean;
  FriendsAlready?: boolean;
  DetailsFullyFetched? :boolean;
}

export interface UserUpdatedDetails {
  FirstName: string;
  LastName: string;
  Email: string;
  OldPassword: string;
  NewPassword: string;
}

export interface UserVerficationDao {
  FirebaseId: string;
}
