import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/Dao/friend.dart';
import 'package:talk_now_app/Services/file_writer_service.dart';
import 'package:talk_now_app/constants/constants.dart' as Constants;
import 'package:http/http.dart' as normalHttp;

import '../interceptor/DioInterceptor.dart';

class ChatHome extends StatefulWidget {
  User? user;
  Friend friend;
  String groupId = "";
  String userStatus = "";
  bool randomConversation = false;
  ChatHome(
      {super.key,
      this.user,
      required this.groupId,
      required this.friend,
      required this.randomConversation});
  @override
  State<ChatHome> createState() =>
      _ChatHomeState(user, groupId, friend, randomConversation);
}

class _ChatHomeState extends State<ChatHome> {
  User? user;
  String groupId;
  Friend friend;
  FileWritter fileWritter = FileWritter();
  bool randomConversation;
  bool userAdded = false;
  bool screenLoaded = false;
  String timeStamp = "";
  bool isExpanded = false;

  _ChatHomeState(this.user, this.groupId, this.friend, this.randomConversation);

  Color customColor = const Color.fromRGBO(5, 24, 46, 1);
  Color bright = const Color.fromRGBO(24, 115, 216, 1);

  final ScrollController _scrollController = ScrollController();

  Widget messageList(double height, double width,
      {DataSnapshot? snapshotValues}) {
    Iterable messageData = snapshotValues?.children as Iterable;
    String? key = snapshotValues?.key;
    String firebaseId = "";
    String message = "";
    String timeSent = "";
    String currentMessageTimeStamp = "";
    bool sentiment = false;
    for (var element in messageData) {
      if (element.key == 'Message') {
        message = element.value;
      } else if (element.key == 'FromClient') {
        firebaseId = element.value;
      } else if (element.key == 'Sentiment') {
        sentiment = element.value == 'Positive' ? true : false;
      } else if (element.key == 'ReadableTime') {
        timeSent = element.value;
      } else if (element.key == 'TimeStamp') {
        currentMessageTimeStamp = element.value;
      }
    }
    if (firebaseId.isNotEmpty && message.isNotEmpty) {
      return Column(
        children: [
          Container(
            // alignment: firebaseId == user?.uid
            //     ? Alignment.centerRight
            //     : Alignment.centerLeft,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      firebaseId == user?.uid
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: bright,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          message,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    firebaseId != user?.uid && !sentiment
                                        ? InkWell(
                                            child: Icon(
                                              Icons.keyboard_arrow_down_sharp,
                                              color: Colors.black,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (isExpanded &&
                                                    currentMessageTimeStamp ==
                                                        timeStamp) {
                                                  timeStamp = "";
                                                  isExpanded = false;
                                                } else {
                                                  timeStamp =
                                                      currentMessageTimeStamp;
                                                  isExpanded = true;
                                                }
                                              });
                                            },
                                          )
                                        : Container()
                                  ],
                                ),
                                if (isExpanded &&
                                    currentMessageTimeStamp == timeStamp)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.0,
                                              horizontal: 1,
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: MaterialButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            content: SizedBox(
                                                              height: 80,
                                                              child: Column(
                                                                children: [
                                                                  CircularProgressIndicator(),
                                                                  SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20),
                                                                  Text(
                                                                      "Reporting message, please wait..."),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                      reportMessage(
                                                              message,
                                                              user?.uid,
                                                              key,
                                                              groupId)
                                                          .then((value) {
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();

                                                          setState(() {
                                                            timeStamp = "";
                                                            isExpanded = false;
                                                          });
                                                        });
                                                      });
                                                      ;
                                                    },
                                                    color: bright,
                                                    textColor: Colors.white,
                                                    child: const Text(
                                                        "Report Message"),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.report,
                                                  color: Colors.red,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    sentiment
                                        ? Container()
                                        : Text(
                                            "This message contained bullying or unwanted content",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Opacity(
                                      opacity: sentiment ? 1.0 : 0.1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: customColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16),
                                          child: Opacity(
                                            opacity: sentiment ? 1.0 : 0.1,
                                            child: Text(
                                              message,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    firebaseId != user?.uid && sentiment
                                        ? InkWell(
                                            child: Icon(
                                              Icons.keyboard_arrow_down_sharp,
                                              color: Colors.black,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (isExpanded &&
                                                    currentMessageTimeStamp ==
                                                        timeStamp) {
                                                  timeStamp = "";
                                                  isExpanded = false;
                                                } else {
                                                  timeStamp =
                                                      currentMessageTimeStamp;
                                                  isExpanded = true;
                                                }
                                              });
                                            },
                                          )
                                        : Container()
                                  ],
                                ),
                                if (isExpanded &&
                                    currentMessageTimeStamp == timeStamp)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.0,
                                              horizontal: 1,
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: MaterialButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            content: SizedBox(
                                                              height: 80,
                                                              child: Column(
                                                                children: [
                                                                  CircularProgressIndicator(),
                                                                  SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20),
                                                                  Text(
                                                                      "Reporting message, please wait..."),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                      reportMessage(
                                                              message,
                                                              user?.uid,
                                                              key,
                                                              groupId)
                                                          .then((value) {
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .pop();

                                                          setState(() {
                                                            timeStamp = "";
                                                            isExpanded = false;
                                                          });
                                                        });
                                                      });
                                                    },
                                                    color: bright,
                                                    textColor: Colors.white,
                                                    child: const Text(
                                                        "Report Message"),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.report,
                                                  color: Colors.red,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    sentiment
                                        ? Container()
                                        : Text(
                                            "This message contained bullying or unwanted content",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: firebaseId == user?.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(timeSent),
            ),
          )
        ],
      );
    }

    return Container();
  }

  Widget userOnlineState() {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref(groupId).child('status').onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.snapshot.value);
        } else {
          return Text(friend.userStatus.toString());
        }
      },
    );
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    getFriendRequestState(groupId, randomConversation);
    TextEditingController messageEditController = TextEditingController();

    void sendMessage(User? loggedInUser, String groupId) async {
      String messageToPredict = messageEditController.text;

      messageEditController.text = "";
      final prefs = await SharedPreferences.getInstance();
      DateTime date = DateTime.now();
      String readableTime = formatAMPM(date);
      //use create two different refs as we need to store messages for both users
      //respectively

      DatabaseReference loggedInUserRef = FirebaseDatabase.instance
          .ref('${loggedInUser?.uid}/messages/$groupId');
      DatabaseReference otherUserRef = FirebaseDatabase.instance
          .ref('$groupId/messages/${loggedInUser?.uid}');

      //get sentiment of message frist
      DioInterceptor dioInterceptor = DioInterceptor();

      String url = Platform.isAndroid
          ? Constants.ANDROID_PREDICT_URL
          : Constants.IOS_PREDICT_URL;

      var response = await dioInterceptor.dio
          .get('$url/predict', queryParameters: {'message': messageToPredict});

      String isPositive = "";
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.data);
        data.forEach((key, value) {
          List<dynamic> sentimentValue = value[0];
          sentimentValue.forEach((element) {
            isPositive = (element as double) > 0.65 ? 'Negative' : 'Positive';
          });
        });

        await loggedInUserRef.push().set({
          "Author": prefs.getString(Constants.USER_FIRST_NAME),
          "FromClient": loggedInUser?.uid,
          "GroupId": groupId,
          "Message": messageToPredict,
          "Sentiment": isPositive,
          "TimeStamp": date.toString(),
          'ReadableTime': readableTime
        });

        await otherUserRef.push().set({
          "Author": prefs.getString(Constants.USER_FIRST_NAME),
          "FromClient": loggedInUser?.uid,
          "GroupId": loggedInUser?.uid,
          "Message": messageToPredict,
          "Sentiment": isPositive,
          "TimeStamp": date.toString(),
          'ReadableTime': readableTime
        });

        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + height * 0.25,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
    }

    final Query dbQuery =
        FirebaseDatabase.instance.ref().child('${user?.uid}/messages/$groupId');

    final Query userOnleStatus =
        FirebaseDatabase.instance.ref().child('$groupId/status');

    DatabaseReference otherUserRef =
        FirebaseDatabase.instance.ref(groupId).child('status');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Row(
              children: [
                friend.hasProfilePicture
                    ? Container(
                        child: FutureBuilder(
                          future: fileWritter.loadImageFromStorage(groupId),
                          builder: (BuildContext context,
                              AsyncSnapshot<Image> snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                child: CircleAvatar(
                                  radius: height * 0.03,
                                  backgroundImage: snapshot.data?.image,
                                ),
                              );
                            } else {
                              return Center(
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
                      ),
                SizedBox(width: width * 0.1),
                Column(
                  children: [
                    Text(friend.firstName.toString()),
                    userOnlineState()
                  ],
                ),
                SizedBox(
                  width: width * 0.2,
                ),
                randomConversation && !userAdded
                    ? InkWell(
                        child: Icon(Icons.person_add_alt_1),
                        onTap: () {
                          addUserAsFriend(groupId);
                        },
                      )
                    : Container()
              ],
            )),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FirebaseAnimatedList(
                controller: _scrollController,
                query: dbQuery,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  if (!screenLoaded) {
                    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                      _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent + 0.25,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOut);
                    });
                  }

                  screenLoaded = true;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: messageList(height, width, snapshotValues: snapshot),
                  );
                },
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      controller: messageEditController,
                      onSubmitted: (value) {
                        sendMessage(user, groupId);
                      },
                      decoration: const InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.send,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      sendMessage(user, groupId);
                    },
                  ),
                  SizedBox(
                    width: 15,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ChatHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 1000 * 0.25,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut);
  }

  void addUserAsFriend(String groupId) async {
    final prefs = await SharedPreferences.getInstance();

    final randomUser =
        FirebaseDatabase.instance.ref('$groupId/friendRequests/');

    randomUser.push().set({
      'FirebaseId': user?.uid,
      'Name': prefs.getString(Constants.USER_FIRST_NAME),
      'Accepted': false,
      'Declined': ""
    });

    setState(() {
      userAdded = true;
    });
  }

  String formatAMPM(DateTime date) {
    int hours = date.hour;
    int minutes = date.minute;
    String ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours == 0 ? 12 : hours;
    String minutesStr = minutes < 10 ? '0$minutes' : '$minutes';
    return '$hours:$minutesStr $ampm';
  }

  Future<void> reportMessage(
      String message, String? uid, String? key, String groupId) async {
    final loggedInUserMessageRef =
        FirebaseDatabase.instance.ref('$uid/messages/$groupId/$key/');

    //update client messages to say it should be filtered
    loggedInUserMessageRef.update({'Sentiment': 'Negative'});

    final database = FirebaseDatabase.instance.ref('reportedMessages');

    //report message
    database.push().set({'Message': message, 'Sentiment': '1'});
  }

  void getFriendRequestState(String groupId, bool randomConversation) {
    if (randomConversation) {
      final loggedInUserRef =
          FirebaseDatabase.instance.ref().child('${user?.uid}/friendRequests');

      loggedInUserRef.onValue.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          //get values
          Map activeFriendRequest = event.snapshot.value as Map;

          activeFriendRequest.forEach((key, value) {
            if (value['FirebaseId'].toString() == groupId) {
              //friend request send already hiden button
              setState(() {
                userAdded = true;
              });
            }
          });
        }
      });
    }
  }
}
