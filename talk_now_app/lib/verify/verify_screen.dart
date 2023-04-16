import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/Dao/login.dart';
import 'package:talk_now_app/constants/constants.dart' as Constants;
import 'package:talk_now_app/interceptor/DioInterceptor.dart';
import '../chat/chat_home.dart';
import 'package:http/http.dart' as http;

class VerifyScreem extends StatefulWidget {
  Login? loginDto;
  VerifyScreem({super.key, required this.loginDto});

  @override
  State<VerifyScreem> createState() => _VerifyScreemState();
}

class _VerifyScreemState extends State<VerifyScreem> {
  User? user = FirebaseAuth.instance.currentUser;
  bool emailVerifyError = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          height: height * .6,
          width: width * .8,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Verify Account",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: height * .04),
                ),
                Icon(
                  Icons.verified,
                  size: ((height * 0.12) + (width * 0.12)),
                ),
                SizedBox(height: height * .02),
                Container(
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "To be able to gain full access to the application, you must verify your email address. An email has been sent you.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: height * .02),
                if (emailVerifyError)
                  Container(
                    alignment: Alignment.center,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Email is not verified",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                SizedBox(height: height * .02),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    verifyAccountStatus(user?.uid);
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text("Verify"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyAccountStatus(String? uid) async {
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();

      //perform Api Call

      var dioInterceptor = DioInterceptor();

      String url = Platform.isAndroid
          ? Constants.ANDROID_API_URL
          : Constants.IOS_API_URL;

      var response = await http.get(Uri.parse(
          '$url/api/user/verifyUserByFireId?firebaseId=${user?.uid}'));
      //       var response = await http.post(Uri.parse("$url/api/user/login"),
      // body: body, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        //login user and save jwt
        var body = jsonEncode(widget.loginDto?.toJson());
        debugPrint(widget.loginDto?.toJson().toString());
        String url = Platform.isAndroid
            ? Constants.ANDROID_API_URL
            : Constants.IOS_API_URL;

        var loginResponse = await http.post(Uri.parse("$url/api/user/login"),
            body: body, headers: {"Content-Type": "application/json"});

        var tokens = jsonDecode(loginResponse.body);
        prefs.setString(Constants.JWT, tokens["jwtToken"]);
        prefs.setString(Constants.REFRESH_TOKEN, tokens["refreshToken"]);

        //redirect to home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ChatAppHome()),
          (Route<dynamic> route) => false,
        );
      } else {
        //Set error state
        setState(() {
          emailVerifyError = true;
        });
      }
    }
  }
}
