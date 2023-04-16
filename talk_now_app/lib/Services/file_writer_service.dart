import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileWritter {
  FileWritter();

  Future<void> writeImagesToStorage(String firebaseUid, File file) async {
    final prefs = await SharedPreferences.getInstance();

    imageCache.clear();
    Directory deviceDirectory = await getApplicationDocumentsDirectory();

    File filePath = File(path.join(deviceDirectory.path, firebaseUid));
    // Get the directory where you can store your image
    final directory = await getApplicationDocumentsDirectory();

    final bytes = await file.readAsBytes();

    prefs.setString(firebaseUid, base64Encode(bytes));

    // ByteData by = filePath.readAsBytes() as ByteData;
    // filePath.writeAsBytes(file.readAsBytes());
    //create firebase storage ref
    // await FirebaseStorage.instance.ref(firebaseUid).writeToFile(file);
  }

  Future<Image> loadImageFromStorage(String firebaseUid) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedBytes = prefs.getString(firebaseUid);

    if (encodedBytes == null) {
      // Return a blank image if no image bytes are stored in shared preferences
      return Image.memory(Uint8List(0));
    }

    try {
      Uint8List bytes = base64Decode(encodedBytes);
      if (bytes != null) {
        return Image.memory(bytes);
      }
    } catch (e) {
      // Return a blank image if the image data is invalid
      return Image.memory(Uint8List(0));
    }

    // Return a blank image if the bytes cannot be decoded
    return Image.memory(Uint8List(0));
  }

  Future<void> downloadImageFromFirebase(String firebaseUid) async {
    final storageRef = FirebaseStorage.instance.ref();
    final profileUrl = storageRef.child(firebaseUid);
    final prefs = await SharedPreferences.getInstance();

    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data = await profileUrl.getData(oneMegabyte * 10);
      prefs.setString(firebaseUid, base64Encode(data!));
      
    } on FirebaseException catch (e) {
      // Handle any errors.
    }
  }
}
