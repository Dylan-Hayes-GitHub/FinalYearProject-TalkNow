import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:talk_now_app/chat/past_chat_rooms.dart';
import 'package:talk_now_app/friends/friend_requests.dart';
import 'package:talk_now_app/interceptor/DioInterceptor.dart';
import 'package:talk_now_app/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/constants/constants.dart' as Constants;


class ChatAppHome extends StatefulWidget {
  const ChatAppHome({super.key});

  @override
  State<ChatAppHome> createState() => _ChatAppHomeState();
}

class _ChatAppHomeState extends State<ChatAppHome> with WidgetsBindingObserver {
  User? user = FirebaseAuth.instance.currentUser;
  int currentPage = 1;
  bool chatHome = true;
  bool settings = false;
  bool friendRequests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: chatHome
          ? const PastChatRooms()
          : (friendRequests
              ? const FriendRequests()
              : (settings ? const Settings() : Container())),
      bottomNavigationBar: NavigationBar(
        destinations: [
          GestureDetector(
            onTap: () {
            },
            child: const NavigationDestination(
                icon: Icon(Icons.person_add), label: 'Friend Requests'),
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          const NavigationDestination(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              {
                setState(() {
                  friendRequests = true;
                  settings = false;
                  chatHome = false;
                });
              }
              break;

            case 1:
              {
                setState(() {
                  friendRequests = false;
                  settings = false;
                  chatHome = true;
                });
              }

              break;

            case 2:
              {
                setState(() {
                  friendRequests = false;
                  settings = true;
                  chatHome = false;
                });
              }
              break;
          }

          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }

  void storeUserDetailsInPreferences(String? uid) async {
    //initialize shared preferences
    final prefs = await SharedPreferences.getInstance();

    String url =
        Platform.isAndroid ? Constants.ANDROID_API_URL : Constants.IOS_API_URL;

    DioInterceptor dioInterceptor = DioInterceptor();

    //perform api call to get user data from SQL database

    var userData = await dioInterceptor.dio
        .getUri(Uri.parse('$url/api/user/GetUserDetails?firebaseId=$uid'));

    var jsonData = jsonDecode(userData.data);

    await prefs.setString(Constants.USER_FIRST_NAME, jsonData["FirstName"]);
    await prefs.setString(Constants.USER_LAST_NAME, jsonData["LastName"]);
    await prefs.setString(Constants.USER_EMAIL, jsonData["Email"]);

    final userRef = FirebaseDatabase.instance.ref(uid);

    //store details in firebase

    var userInfo = {
      "FirstName": jsonData["FirstName"],
      "LastName": jsonData["LastName"],
      "Email": jsonData["Email"]
    };
    await userRef.update(userInfo);
  }

  @override
  void initState() {
    storeUserDetailsInPreferences(user?.uid);

    getFirebaseCloudMessagePerms();
    storeNotificationToken(user?.uid);
    setUserToBeOnline(user?.uid);

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    final isBackground = state == AppLifecycleState.resumed;

    if (!isBackground) {
      setUserToBeOffline(user?.uid);
    } else {
      setUserToBeOnline(user?.uid);
    }
  }

  static Future<void> getFirebaseCloudMessagePerms() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void storeNotificationToken(String? uid) async {
    final userRef = FirebaseDatabase.instance.ref(uid);

    await FirebaseMessaging.instance.getToken().then(
      (value) {
        String? userFcmToken = value == null ? '' : value;
        var userSendToken = {"fcmSendToken": userFcmToken};
        userRef.update(userSendToken);
      },
    );
  }

  void setUserToBeOnline(String? uid) async {
    final userRef = FirebaseDatabase.instance.ref(uid);

    var updateStatus = {'status': 'online'};

    await userRef.update(updateStatus);
  }

  void setUserToBeOffline(String? uid) async {
    final userRef = FirebaseDatabase.instance.ref(uid);

    var updateStatus = {'status': 'offline'};

    await userRef.update(updateStatus);
  }
}
