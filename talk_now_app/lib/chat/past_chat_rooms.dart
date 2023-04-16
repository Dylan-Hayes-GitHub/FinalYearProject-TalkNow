import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:talk_now_app/Dao/friend.dart';
import 'package:talk_now_app/Services/file_writer_service.dart';
import 'package:talk_now_app/chat/start_new_conversation.dart';

import 'chat_room.dart';

class PastChatRooms extends StatefulWidget {
  const PastChatRooms({super.key});

  @override
  State<PastChatRooms> createState() => _PastChatRoomsState();
}

class _PastChatRoomsState extends State<PastChatRooms> {
  User? user = FirebaseAuth.instance.currentUser;
  Friend friendList = Friend("", "", "", false, "Offline");
  FileWritter fileWritter = FileWritter();
  Friend friend = Friend("", "", "", false, "Offline");

  final Query dbQuery = FirebaseDatabase.instance
      .ref("${FirebaseAuth.instance.currentUser?.uid}/messages/");

  final ScrollController _scrollController = ScrollController();

  Widget PastChat(String? key, double height, double width) {
    //create query for individual chat and retreive last message

    Future _getFriendFuture;
    if (key != null) {
      _getFriendFuture = getFriendDetails(key);
    } else {
      _getFriendFuture = Future.value();
    }

    final lastMessage = FirebaseDatabase.instance
        .ref()
        .child("${user?.uid}/messages/$key")
        .limitToLast(1);

    return FutureBuilder(
      future: _getFriendFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while data is being fetched
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show error message if there's an error
        } else if (snapshot.hasData) {
          Friend retrievedFriendData = Friend("", "", "", false, "");
          retrievedFriendData = snapshot.data;
          return retrievedFriendData.firstName != ''
              ? StreamBuilder(
                  stream: lastMessage.onValue,
                  builder: (BuildContext context,
                      AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while data is being fetched
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Show error message if there's an error
                    } else if (snapshot.hasData) {
                      Iterable children =
                          snapshot.data?.snapshot.children as Iterable;
                      String authorName = "";
                      String lastMessage = "";
                      String readableTime = "";
                      String groupId = "";
                      bool sentiment = false;
                      for (var element in children) {
                        //authorName = element.value["Author"].toString();
                        lastMessage = element.value["Message"].toString();
                        readableTime = element.value["ReadableTime"].toString();
                        groupId = element.value["GroupId"];
                        sentiment = element.value['Sentiment'] == 'Positive'
                            ? true
                            : false;
                      }

                      if (friend.hasProfilePicture) {
                        //write to local device for instant load
                        //fileWritter.writeImagesToStorage(groupId);
                      }

                      return InkWell(
                        onTap: () {
                          //navigate to chat room screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatHome(
                                user: user,
                                groupId: groupId,
                                friend: retrievedFriendData,
                                randomConversation: false,
                              ),
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: double.infinity,
                            minHeight: 70,
                          ),
                          child: Row(
                            children: [
                              friend.hasProfilePicture
                                  ? Container(
                                      child: StreamBuilder<Object>(
                                        stream: null,
                                        builder: (context, snapshot) {
                                          return FutureBuilder(
                                            future: fileWritter
                                                .loadImageFromStorage(groupId),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<Image> snapshot) {
                                              if (snapshot.hasData) {
                                                return Container(
                                                  child: CircleAvatar(
                                                    radius: height * 0.04,
                                                    backgroundImage:
                                                        snapshot.data?.image,
                                                  ),
                                                );
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: height * 0.03,
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.person,
                                        size: height * 0.03,
                                        color: Colors.white,
                                      ),
                                    ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(retrievedFriendData.firstName
                                        .toString()),
                                    !sentiment
                                        ? Opacity(
                                            opacity: sentiment ? 1.0 : 0.2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.circular(
                                                    10), // Adjust the radius value for desired roundness
                                              ),
                                              child: Text(
                                                lastMessage,
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            lastMessage,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(readableTime),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                )
              : Container();
        }

        // if (friend.firstName != '') {

        // }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0, left: 10),
                  child: Text(
                    "Conversations",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0, right: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StartNewConversation()));
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: height * 0.04,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: FirebaseAnimatedList(
                query: dbQuery,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  return PastChat(snapshot.key, height, width);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> getFriendDetails(String otherUserFireId) async {
  //   final loggedInUserFriends = FirebaseDatabase.instance.ref();
  //   final friends =
  //       await loggedInUserFriends.child("${user?.uid}/friends").get();
  //   Friend newFriend = Friend("", "", "", false, "");

  //   if (friends.value != null) {
  //     Map friendList = friends.value as Map;

  //     for (var friendData in friendList.values) {
  //       if (friendData['FirebaseId'] == otherUserFireId) {
  //         final friendRef = FirebaseDatabase.instance.ref(otherUserFireId);
  //         final DataSnapshot dataSnapshot = await friendRef.get();

  //         if (dataSnapshot.exists) {
  //           Map friendData = dataSnapshot.value as Map;
  //           friend.firstName = friendData["FirstName"];
  //           friend.lastName = friendData["LastName"];
  //           friend.deviceSendToken = friendData["fcmSendToken"];

  //           if (friendData["status"] != null) {
  //             friend.userStatus = friendData["status"];
  //           }
  //           if (friendData["hasProfilePicture"] == null) {
  //             friend.hasProfilePicture = false;
  //           } else {
  //             friend.hasProfilePicture = true;
  //           }
  //           break;
  //         }
  //       }
  //     }
  //   }
  // }

  Future<Friend> getFriendDetails(String friendFirebaseId) async {
    final loggedInUserFriendList =
        FirebaseDatabase.instance.ref().child('${user?.uid}/friends/');

    final userFriendList = await loggedInUserFriendList.get();

    if (userFriendList.exists) {
      Map listOfFriends = userFriendList.value as Map;

      for (var key in listOfFriends.keys) {
        if (listOfFriends[key]['FirebaseId'] == friendFirebaseId) {
          final friendRef = FirebaseDatabase.instance.ref(friendFirebaseId);

          final DataSnapshot dataSnapshot = await friendRef.get();

          if (dataSnapshot.exists) {
            Map friendData = dataSnapshot.value as Map;
            Friend friendDetails = Friend("", "", "", false, "");
            friendDetails.firstName = friendData["FirstName"];
            friendDetails.lastName = friendData["LastName"];
            friendDetails.deviceSendToken = friendData["fcmSendToken"];

            if (friendData["status"] != null) {
              friendDetails.userStatus = friendData["status"];
            }
            if (friendData['hasProfilePicture'] != null &&
                friendData["hasProfilePicture"]) {
              friendDetails.hasProfilePicture = true;
            } else {
              friendDetails.hasProfilePicture = false;
            }

            return friendDetails;
          } else {
            return Friend("", "", "", false,
                ""); // Return null if friend data doesn't exist
          }
        }
      }
    }

    return Friend("", "", "", false, ""); // Return default Friend object
  }
}
