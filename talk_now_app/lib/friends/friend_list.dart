import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../chat/chat_room.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  User? user = FirebaseAuth.instance.currentUser;

  final Query dbQuery = FirebaseDatabase.instance
      .ref("${FirebaseAuth.instance.currentUser?.uid}/friends/");

  //Friend list widget
  //Friend list widget
  Widget friendlist(double height, double width,
      {required DataSnapshot snapshotValues}) {
    String groupId = "";
    String authorName = "";

    Iterable friends = snapshotValues.children;


    friends.forEach(
      (element) {
        if (element.key == 'FirebaseId') {
          groupId = element.value;
        } else if (element.key == 'Name') {
          authorName = element.value;
        }
      },
    );

    return Row(
      children: [Text("data")],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Friend List"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Center(
            child: Row(
              children: [
                FirebaseAnimatedList(
                  query: dbQuery,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    return friendlist(height, width, snapshotValues: snapshot);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
