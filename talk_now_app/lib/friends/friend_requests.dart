import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/Dao/friend.dart';
import 'package:talk_now_app/Services/file_writer_service.dart';
import 'package:talk_now_app/constants/constants.dart' as Constants;

class FriendRequests extends StatefulWidget {
  const FriendRequests({super.key});

  @override
  State<FriendRequests> createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  FileWritter fileWritter = FileWritter();
  User? user = FirebaseAuth.instance.currentUser;
  Friend friend = Friend("", "", "", false, "");
  Widget friendRequest(DataSnapshot snapshot, double height) {
    if (snapshot.exists) {
      Map friendRequests = snapshot.value as Map;

      String userName = friendRequests["Name"];

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
              future: getFriendDetails(friendRequests["FirebaseId"]!),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return friend.hasProfilePicture
                      ? Container(
                          child: FutureBuilder(
                            future: fileWritter.loadImageFromStorage(
                                friendRequests["FirebaseId"]),
                            builder: (BuildContext context,
                                AsyncSnapshot<Image> snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                  child: CircleAvatar(
                                    radius: height * 0.04,
                                    backgroundImage: snapshot.data?.image,
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
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
                        );
                } else {
                  return Container();
                }
              }),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    acceptFriendRequest(
                        friendRequests["FirebaseId"], user?.uid);
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text("Accept"),
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    declineFriendRequest(
                        friendRequests["FirebaseId"], user?.uid);
                  },
                  color: customColor,
                  textColor: Colors.white,
                  child: const Text("Decline"),
                )
              ],
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Color customColor = const Color.fromRGBO(5, 24, 46, 1);
  Color bright = const Color.fromRGBO(24, 115, 216, 1);

  @override
  Widget build(BuildContext context) {
    Query pendingFriendRequests =
        FirebaseDatabase.instance.ref('${user?.uid}/friendRequests');

    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          child: Column(
            children: [
              const Text(
                "Friend Requests",
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Expanded(
                child: FirebaseAnimatedList(
                  query: pendingFriendRequests,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: friendRequest(snapshot, height),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  void acceptFriendRequest(String friendRequest, String? uid) async {
    final prefs = await SharedPreferences.getInstance();

    final String? name = prefs.getString('FirstName');
    //create ref string
    String loggedInUserFriendRequestRef = '$uid/friendRequests/';
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child(loggedInUserFriendRequestRef).get();
    if (snapshot.exists) {
      //loop through all friend requests until the matching one is found
      Map friendRequests = snapshot.value as Map;

      friendRequests.forEach((key, value) async {
        if (value["FirebaseId"] == friendRequest) {
          //update

          //create db ref for both user
          String loggedInUserFriendList = '$uid/friends/';

          String otheUserFriendList = '$friendRequest/friends/';

          DatabaseReference loggedInUserFriendListRef =
              FirebaseDatabase.instance.ref(loggedInUserFriendList);

          DatabaseReference otheUserFriendListRef =
              FirebaseDatabase.instance.ref(otheUserFriendList);

          await loggedInUserFriendListRef.push().set(
            {"Name": value["Name"], "FirebaseId": value["FirebaseId"]},
          );

//TODO store user name in shared pref
          await otheUserFriendListRef.push().set({
            "Name": prefs.getString(Constants.USER_FIRST_NAME),
            "FirebaseId": uid
          });

          String pendingFriendRequestToRemove = '$uid/friendRequests/$key';

          DatabaseReference pendingFriendRequestToRemoveRef = FirebaseDatabase
              .instance
              .ref()
              .child(pendingFriendRequestToRemove);
          await pendingFriendRequestToRemoveRef.remove();
        }
      });
    }
  }

  Future<void> getFriendDetails(String friendFirebaseId) async {
    final friendRef = FirebaseDatabase.instance.ref(friendFirebaseId);

    final DataSnapshot = await friendRef.get();
    Map friendData = DataSnapshot.value as Map;

    friend.firstName = friendData["FirstName"];
    friend.lastName = friendData["LastName"];
    friend.deviceSendToken = friendData["fcmSendToken"];
    if (friendData["hasProfilePicture"] == null) {
      friend.hasProfilePicture = false;
    } else {
      friend.hasProfilePicture = true;
    }
  }

  void declineFriendRequest(friendRequest, String? uid) async {
    //TODO for later
    final prefs = await SharedPreferences.getInstance();

    final String? name = prefs.getString('FirstName');
    //create ref string
    String loggedInUserFriendRequestRef = '$uid/friendRequests/';
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child(loggedInUserFriendRequestRef).get();
    if (snapshot.exists) {
      //loop through all friend requests until the matching one is found
      Map friendRequests = snapshot.value as Map;

      friendRequests.forEach((key, value) async {
        if (value["FirebaseId"] == friendRequest) {
          String pendingFriendRequestToRemove = '$uid/friendRequests/$key';

// Remove child with key
          await FirebaseDatabase.instance
              .ref()
              .child('$uid/friendRequests/$key')
              .remove();

          return;
        }
      });
    } else {
      print('No data available.');
    }
  }
}
