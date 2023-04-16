import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/dto/newuser.dart';
import 'package:talk_now_app/interceptor/DioInterceptor.dart';
import 'package:talk_now_app/login/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:talk_now_app/constants/constants.dart' as Constants;
import 'package:talk_now_app/verify/verify_screen.dart';

import '../Dao/login.dart';
import '../chat/chat_home.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  bool emailExists = false;
  bool invalidEmailFormat = false;
  bool weakPassword = false;

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
                  "Register",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextFormField(
                            controller: firstNameTextController,
                            keyboardType: TextInputType.name,
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
                              hintText: "First Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter First Name'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextFormField(
                            controller: lastNameTextController,
                            keyboardType: TextInputType.name,
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
                              hintText: "Last Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter last name'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextFormField(
                            controller: emailTextController,
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
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter a email'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextFormField(
                            controller: passwordTextController,
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
                            ),
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter password'
                                  : null;
                            },
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        emailExists
                            ? Text(
                                "Email exists already",
                                style: TextStyle(color: Colors.red),
                              )
                            : Container(),
                        weakPassword
                            ? Text(
                                "Weak password",
                                style: TextStyle(color: Colors.red),
                              )
                            : Container(),
                        invalidEmailFormat
                            ? Text(
                                "Invalid Email format",
                                style: TextStyle(color: Colors.red),
                              )
                            : Container(),
                        SizedBox(height: height * 0.01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minWidth: double.infinity,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                registerUser(
                                    firstNameTextController.text,
                                    lastNameTextController.text,
                                    emailTextController.text,
                                    passwordTextController.text);
                              }
                            },
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: const Text("Register"),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already a member? "),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: ((BuildContext context) {
                                  return const LoginHome();
                                })));
                              },
                              child: const Text(
                                "Login",
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void registerUser(
      String firstName, String lastName, String email, String password) async {
    setState(() {
      emailExists = false;
      invalidEmailFormat = false;
      weakPassword = false;
    });
    debugPrint("register started");
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var dioInterceptor = DioInterceptor();

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = FirebaseAuth.instance.currentUser;
      String url = Platform.isAndroid
          ? Constants.ANDROID_API_URL
          : Constants.IOS_API_URL;
      if (user != null) {
        NewUser newUser =
            NewUser(firstName, lastName, email, password, user.uid);

        var body = jsonEncode(newUser.toJson());

        var response = await dioInterceptor.dio.putUri(
          Uri.parse("$url/api/user/0"),
          data: body,
          options: Options(
            headers: {"Content-Type": "application/json"},
          ),
        );

        firstNameTextController.text = "";
        lastNameTextController.text = "";
        emailTextController.text = "";
        passwordTextController.text = "";

        if (response.statusCode == 200) {
          Login loginDto = Login(email, password);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyScreem(
                      loginDto: loginDto,
                    )),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          weakPassword = true;
        });
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        setState(() {
          emailExists = true;
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          invalidEmailFormat = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
