import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:talk_now_app/Dao/friend.dart';
import 'package:talk_now_app/Services/file_writer_service.dart';
import 'package:talk_now_app/friends/friend_list.dart';

import 'chat_room.dart';

class StartNewConversation extends StatefulWidget {
  const StartNewConversation({super.key});

  @override
  State<StartNewConversation> createState() => _StartNewConversationState();
}

class _StartNewConversationState extends State<StartNewConversation> {
  User? user = FirebaseAuth.instance.currentUser;
  Friend friend = Friend("", "", "", true, "");
  Friend randomFriend = Friend("", "", "", true, "");
  FileWritter fileWritter = FileWritter();
  bool userIsInQueueAlready = false;
  BuildContext? dialogContext;
  var subscription;

  final Query dbQuery = FirebaseDatabase.instance
      .ref("${FirebaseAuth.instance.currentUser?.uid}/friends/");

  Widget friendlist(double height, double width,
      {required DataSnapshot snapshotValues}) {
    String groupId = "";
    String authorName = "";

    String friendFirebaseId = "";
    Iterable friends = snapshotValues.children;
    for (var element in friends) {
      if (element.key == 'FirebaseId') {
        groupId = element.value;
        friendFirebaseId = element.value;
      } else if (element.key == 'Name') {
        authorName = element.value;
      }
    }

    Future _getFriendFuture;
    if (groupId != null) {
      _getFriendFuture = getFriendDetails(groupId);
    } else {
      _getFriendFuture = Future.value();
    }

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
                ? Column(
                    children: [
                      SizedBox(height: 10),
                      InkWell(
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
                                      )));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            child: Row(
                              children: [
                                retrievedFriendData.hasProfilePicture
                                    ? Container(
                                        child: FutureBuilder(
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
                                      Text(
                                        authorName,
                                        style: TextStyle(fontSize: 20),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container();
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text("Start Conversation"),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: width * 0.75,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minWidth: double.infinity,
                    onPressed: () async {
                      //Should navigate user to a new screen like loading screen
                      showJoiningConversationDialog(context, user?.uid, width);

                      joinRandomConversation(user?.uid);
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                      child: Text(
                        "Start Conversation",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Friend List",
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: FirebaseAnimatedList(
                        query: dbQuery,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          return friendlist(height, width,
                              snapshotValues: snapshot);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  void joinRandomConversation(String? uid) async {
    final queue = FirebaseDatabase.instance.ref().child('queue');
    bool addedToQueue = false;
    String otherUserForChatId = "";

    subscription = queue.onValue.listen((DatabaseEvent event) async {
      if (!event.snapshot.exists) {
        //queue must be initialized
        FirebaseDatabase.instance.ref().child('queue').set('');
      } else {
        if (event.snapshot.value != "") {
          Map usersInQueue = event.snapshot.value as Map;

          //loop through queue and see if user exists
          usersInQueue.forEach(
            (key, value) {
              if (value['firebaseId'] == uid) {
                addedToQueue = true;
              }
            },
          );
          if (!addedToQueue) {
            queue.push().set({'firebaseId': uid});
          } else if (usersInQueue.length == 2) {
            subscription.cancel();

            //loop through and ensure the current user is at the top or second from the top
            bool inQueue = false;
            int counter = 0;

            usersInQueue.forEach((key, value) {
              if (counter == 2) {
                return;
              }
              if (value['firebaseId'].toString() == uid) {
                inQueue = true;
              } else {
                otherUserForChatId = value['firebaseId'].toString();
              }
              counter++;
            });

            //remove top 2
            int control = 0;
            usersInQueue.forEach((key, value) {
              if (control == 2) {
                return;
              }
              FirebaseDatabase.instance.ref().child('queue/$key').remove();
              control++;
            });

            await getRandomFriendDetails(otherUserForChatId).then(
              (value) {
                if (dialogContext != null) {
                  Navigator.of(dialogContext!).pop();
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatHome(
                          user: user,
                          groupId: otherUserForChatId,
                          friend: randomFriend,
                          randomConversation: true)),
                );
              },
            );
          }
        } else {
          if (!addedToQueue) {
            queue.push().set({'firebaseId': uid});
            addedToQueue = true;
          }
        }
      }
    });
  }

  Future<void> showJoiningConversationDialog(
      BuildContext context, String? uid, double width) async {
    dialogContext =
        context; // initialize dialogContext when you call showDialog

    final dialogClosedEarly = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Joining Conversation",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Please wait",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                CircularProgressIndicator(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minWidth: width * 0.05,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text("Leave"),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Check if the dialog was dismissed by pressing the button or not
    if (dialogClosedEarly == null) {
      // Dialog was dismissed by tapping outside or pressing back button
      subscription.cancel();
      removeUserFromQueue(user?.uid);
    } else if (dialogClosedEarly is bool && dialogClosedEarly) {
      // Dialog was dismissed by pressing the button
    }
  }

  Future<void> getRandomFriendDetails(String friendFirebaseId) async {
    final friendRef = FirebaseDatabase.instance.ref(friendFirebaseId);

    final DataSnapshot dataSnapshot = await friendRef.get();

    if (dataSnapshot.exists) {
      Map friendData = dataSnapshot.value as Map;

      randomFriend.firstName = friendData["FirstName"];
      randomFriend.lastName = friendData["LastName"];
      randomFriend.deviceSendToken = friendData["fcmSendToken"];

      if (friendData["status"] != null) {
        randomFriend.userStatus = friendData["status"];
      }
      if (friendData["hasProfilePicture"] == null) {
        randomFriend.hasProfilePicture = false;
      } else {
        randomFriend.hasProfilePicture = true;
        //await fileWritter.writeImagesToStorage(friendFirebaseId);
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void removeUserFromQueue(String? uid) async {
    final queue = FirebaseDatabase.instance.ref().child('queue/');
    final peopleInQueue = await queue.get();

    if (peopleInQueue.exists) {
      Map queueList = peopleInQueue.value as Map;

      queueList.forEach((key, value) async {
        if (uid == value['firebaseId'].toString()) {
          //remove from queue
          final removeUserRef =
              FirebaseDatabase.instance.ref().child('queue/$key');
          await removeUserRef.remove();
        }
      });
    }
  }
}
