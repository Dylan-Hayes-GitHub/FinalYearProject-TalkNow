import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_now_app/Dao/user.dart';
import 'package:talk_now_app/Services/file_writer_service.dart';
import 'package:talk_now_app/constants/constants.dart' as Constants;
import 'package:talk_now_app/interceptor/DioInterceptor.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  String firstName = "";
  String lastName = "";
  String email = "";
  String avatarUrl = "";
  bool hasProfileIcon = false;

  final FileWritter fileWritter = FileWritter();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    User? user = FirebaseAuth.instance.currentUser;

    TextEditingController firstNameTextController =
        TextEditingController(text: firstName.toString());
    TextEditingController lastNameTextController =
        TextEditingController(text: lastName.toString());
    TextEditingController emailTextController =
        TextEditingController(text: email.toString());
    TextEditingController passwordTextController = TextEditingController();

    TextEditingController newPasswordTextController = TextEditingController();

    FutureBuilder<Image> avatarWidget(bool hasProfileIcon) {
      return FutureBuilder<Image>(
        future: fileWritter.loadImageFromStorage(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CircleAvatar(
              radius: 50,
              backgroundImage: snapshot.hasData ? snapshot.data!.image : null,
              backgroundColor: Theme.of(context).canvasColor,
            );
          } else {
            return CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).canvasColor,
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }

    return SafeArea(
        child: email != ''
            ? SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          "Settings",
                          style: TextStyle(fontSize: 34),
                        ),
                        alignment: Alignment.topCenter,
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      hasProfileIcon
                          ? avatarWidget(hasProfileIcon)
                          : CircleAvatar(
                              radius: height * 0.03,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                size: height * 0.03,
                                color: Colors.white,
                              ),
                            ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.3),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minWidth: double.infinity,
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: () {
                                      pickImageFromGallery(
                                          ImageSource.gallery, user?.uid);
                                    },
                                    child:
                                        const Text("Select photo from gallery"),
                                  ),
                                  MaterialButton(
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: () {
                                      pickImageFromCamera(
                                          ImageSource.camera, user?.uid);
                                    },
                                    child: const Text("Take picture"),
                                  ),
                                ],
                              ),
                            );
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: const Text("Upload photo"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: height * 0.02,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 75),
                                child: TextFormField(
                                  controller: firstNameTextController,
                                  keyboardType: TextInputType.name,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
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
                              SizedBox(height: height * 0.02),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 75),
                                child: TextFormField(
                                  controller: lastNameTextController,
                                  keyboardType: TextInputType.name,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
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
                                        ? 'Please enter Last Name'
                                        : null;
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 75),
                                child: TextFormField(
                                  controller: emailTextController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
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
                                        ? 'Please enter email'
                                        : null;
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 75),
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
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    alignLabelWithHint: true,
                                    hintText: "Old Password",
                                    prefixIcon: Icon(
                                      Icons.key,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 75),
                                child: TextFormField(
                                  controller: newPasswordTextController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    alignLabelWithHint: true,
                                    hintText: "New Password",
                                    prefixIcon: Icon(
                                      Icons.key,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  validator: (value) {
                                    return value!.isEmpty &&
                                            passwordTextController.text != ''
                                        ? 'Please enter new password'
                                        : null;
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 75),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  minWidth: double.infinity,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      updateUserDetails(
                                        firstNameTextController.text,
                                        lastNameTextController.text,
                                        emailTextController.text,
                                        passwordTextController.text,
                                        newPasswordTextController.text,
                                      );
                                    }
                                  },
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child: const Text("Update"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container());
  }

  @override
  void initState() {
    getUserDataFromSharedPref();
    super.initState();
  }

  void updateUserDetails(String firstName, String lastName, String email,
      String oldPassword, String newPassword) async {
    final sharedPref = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    var dioInterceptor = DioInterceptor();

    var url =
        Platform.isAndroid ? Constants.ANDROID_API_URL : Constants.IOS_API_URL;

    UserDetails userDetailsDto =
        UserDetails(firstName, lastName, email, oldPassword, newPassword);

    var userDetailsDtoJson = jsonEncode(userDetailsDto.toJson());
    var response = await dioInterceptor.dio.postUri(
      Uri.parse('$url/api/user/updateUserDetails'),
      data: userDetailsDtoJson,
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    if (response.statusCode == 200) {
      //update was sucessful

      if (newPassword.isNotEmpty) {
        FirebaseAuth _auth = FirebaseAuth.instance;

        AuthCredential authCredential =
            EmailAuthProvider.credential(email: email, password: oldPassword);

        await user?.reauthenticateWithCredential(authCredential);

        await user?.updatePassword(newPassword);
      }
      //Do a request for new data by fire id
      var userData = await dioInterceptor.dio.getUri(
          Uri.parse('$url/api/user/GetUserDetails?firebaseId=${user?.uid}'));

      var jsonData = jsonDecode(userData.data);

      await sharedPref.setString(
          Constants.USER_FIRST_NAME, jsonData["FirstName"]);
      await sharedPref.setString(
          Constants.USER_LAST_NAME, jsonData["LastName"]);
      await sharedPref.setString(Constants.USER_EMAIL, jsonData["Email"]);

      final userRef = FirebaseDatabase.instance.ref(user?.uid);

      //store details in firebase

      var userInfo = {
        "FirstName": jsonData["FirstName"],
        "LastName": jsonData["LastName"],
        "Email": jsonData["Email"]
      };
      await userRef.update(userInfo);

      getUserDataFromSharedPref();
    }
  }

  void getUserDataFromSharedPref() async {
    User? user = FirebaseAuth.instance.currentUser;

    //perform get query to see if user has a profile
    final friendRef = FirebaseDatabase.instance.ref(user?.uid);

    final DataSnapshot dataSnapshot = await friendRef.get();

    if (dataSnapshot.exists) {
      Map friendData = dataSnapshot.value as Map;

      if (friendData["hasProfilePicture"] != null &&
          !friendData["hasProfilePicture"]) {
      } else {
        if (user != null) {
          if (friendData["hasProfilePicture"] != null &&
              friendData["hasProfilePicture"]) {
            await fileWritter.downloadImageFromFirebase(user.uid);
            setState(() {
              hasProfileIcon = true;
            });
          }
        }
      }
    }

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        firstName = prefs.getString(Constants.USER_FIRST_NAME)!;
        lastName = prefs.getString(Constants.USER_LAST_NAME)!;
        email = prefs.getString(Constants.USER_EMAIL)!;
      });
    });
  }

  Future<void> pickImageFromCamera(ImageSource camera, String? uid) async {
    final pikedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pikedImage == null) {
      return;
    }
    final tempFile =
        await FlutterNativeImage.compressImage(pikedImage.path, quality: 80);

    await uploadImageToFirebaseStorage(tempFile, uid);
  }

  Future<void> pickImageFromGallery(ImageSource camera, String? uid) async {
    final pikedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pikedImage == null) {
      return;
    }
    final tempFile =
        await FlutterNativeImage.compressImage(pikedImage.path, quality: 80);

    await uploadImageToFirebaseStorage(tempFile, uid);
  }

  uploadImageToFirebaseStorage(File pickedImage, String? uid) async {
    final userProfileRef = FirebaseStorage.instance.ref(uid);
    final userPrefs = await SharedPreferences.getInstance();
    Directory deviceDirectory = await getApplicationDocumentsDirectory();

    //await pickedImage.saveTo('${deviceDirectory.path}$uid');
    await fileWritter.writeImagesToStorage(uid!, pickedImage);

    File file = File(pickedImage.path);

    final result = await userProfileRef.putFile(file);

    final fileUrl = await result.ref.getDownloadURL();

    userPrefs.setString(Constants.USER_PROFILE_IMAGE, fileUrl);
    userPrefs.setBool(Constants.HAS_PROFILE_ICON, true);
    //update user firebase details to say they have a profile image
    final userRef = FirebaseDatabase.instance.ref(uid);
    var updateData = {'hasProfilePicture': true};
    setState(() {
      hasProfileIcon = true;
    });
    userRef.update(updateData);
  }
}
