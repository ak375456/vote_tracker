import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:vote_tracker/Screens/auth_screens/login_screen.dart';

class AuthServices with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  File? profileImage;

  createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  // This method will pick an image for profile
  Future<File?> pickProfileImage() async {
    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      File pickedFile = File(imageFile.path);

      // Resize the image before returning
      File resizedImage = await resizeImage(pickedFile);

      profileImage = resizedImage;
      notifyListeners();
      return profileImage;
    }
    return null;
  }

  Future<File> resizeImage(File pickedFile) async {
    final bytes = await pickedFile.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    // Resize the image to your desired dimensions
    final resizedImage =
        img.copyResize(image!, height: 1080, width: 1920, maintainAspect: true);

    // Save the resized image to a new file
    final resizedFile = File('${pickedFile.path}_resized.png');
    await resizedFile.writeAsBytes(img.encodePng(resizedImage));

    return resizedFile;
  }

  storeDataInFireStoreOfUser({
    required String fullName,
    required Timestamp dateOfBirth,
    required gender,
    required File? image,
    required String number,
    required String address,
    required String province,
    required String district,
    context,
  }) async {
    try {
      String imageUrl = '';
      if (image != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("${firebaseAuth.currentUser?.uid}");
        await ref.putFile(image);
        imageUrl = await ref.getDownloadURL();
      }
      // Calculate age from date of birth
      DateTime dob = dateOfBirth.toDate();
      DateTime now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      firestore.collection("Users").doc(firebaseAuth.currentUser!.uid).set({
        'uid': firebaseAuth.currentUser!.uid,
        'fullName': fullName,
        'image': imageUrl,
        'gender': gender,
        'DOB': dateOfBirth,
        'age': age, // Store the calculated age
        'voteRemaining': 1,
        'isCandidate': false,
        "number": number,
        "Address": address,
        'province': province,
        'district': district
      });
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Wrong password provided for that user.");
      }
      throw Exception(e.code);
    }
  }

  signOut(BuildContext context) async {
    try {
      await firebaseAuth.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Handle sign-out errors
      print('Sign-out error: $e');
    }
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}
