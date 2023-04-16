import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/Dao/login.dart';
import 'package:talk_now_app/chat/chat_home.dart';
import 'package:talk_now_app/interceptor/DioInterceptor.dart';
import 'package:talk_now_app/register/regiser_screen.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:talk_now_app/constants/constants.dart' as Constants;
import 'package:talk_now_app/verify/verify_screen.dart';

class LoginHome extends StatefulWidget {
  const LoginHome({super.key});

  @override
  State<LoginHome> createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  bool userDetailsNotFound = false;
  Future<void> loginUser(String email, String password) async {
    //try login firebase user
    final prefs = await SharedPreferences.getInstance();

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;
      if (user != null) {
        Login loginDto = Login(email, password);
        var body = jsonEncode(loginDto.toJson());

        var dioInterceptor = DioInterceptor();

        String url = Platform.isAndroid
            ? Constants.ANDROID_API_URL
            : Constants.IOS_API_URL;

        var response = await http.post(Uri.parse("$url/api/user/login"),
            body: body, headers: {"Content-Type": "application/json"});

        if (response.statusCode == 401) {
          //user needs to verify their email
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyScreem(
                      loginDto: loginDto,
                    )),
            (Route<dynamic> route) => false,
          );
          //redirect to verify page
        } else if (response.statusCode == 404) {
          //inccorect login details / not found
          setState(() {
            userDetailsNotFound = true;
          });
        } else {
          var tokens = jsonDecode(response.body);
          prefs.setString(Constants.JWT, tokens["jwtToken"]);
          prefs.setString(Constants.REFRESH_TOKEN, tokens["refreshToken"]);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ChatAppHome()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        setState(() {
          userDetailsNotFound = true;
        });
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          userDetailsNotFound = true;
        });
      } else {
        setState(() {
          userDetailsNotFound = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height * 0.17,
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: height * 0.05),
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.02),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextFormField(
                            controller: emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              alignLabelWithHint: true,
                              hintText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.blue,
                              ),
                            ),
                            onChanged: (String value) {
                            },
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter email'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextFormField(
                            controller: passwordEditingController,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                alignLabelWithHint: true,
                                hintText: "Password",
                                prefixIcon: Icon(
                                  Icons.key,
                                  color: Colors.blue,
                                ),
                                iconColor: Colors.blue),
                            onChanged: (String value) {
                            },
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter password'
                                  : null;
                            },
                          ),
                        ),
                        userDetailsNotFound
                            ? Column(
                                children: [
                                  SizedBox(height: height * 0.03),
                                  Text(
                                    "Incorrect email or password",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(height: height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minWidth: double.infinity,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(emailEditingController.text,
                                    passwordEditingController.text);
                              }
                            },
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: const Text("Login"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member? "),
                    InkWell(
                      onTap: () {
                        // Navigator.of(context).push(
                        //     MaterialPageRoute(builder: ((BuildContext context) {
                        //   return const Register();
                        // })));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ));
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
