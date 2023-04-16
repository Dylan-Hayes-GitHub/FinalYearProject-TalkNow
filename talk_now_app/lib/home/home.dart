import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_now_app/Dao/login.dart';
import 'package:talk_now_app/chat/chat_home.dart';
import 'package:talk_now_app/chat/chat_room.dart';
import 'package:talk_now_app/chat/start_new_conversation.dart';
import 'package:talk_now_app/friends/friend_list.dart';
import 'package:talk_now_app/friends/friend_requests.dart';
import 'package:talk_now_app/login/login_page.dart';
import 'package:talk_now_app/register/regiser_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: LoginHome(),
      );
    }

    return const Scaffold(
      body: ChatAppHome(),
    );
  }
}
