import 'dart:developer';
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

class CandidateServices with ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  File? candidateProfileImage;

  storeDataOfCandidateOnFirestore(
      {required String email,
      required String password,
      required String fullName,
      required dateOfBirth,
      required File? image,
      required gender,
      required number,
      required website,
      required twitter,
      required occupation,
      required cnic,
      required fullAddress,
      required province,
      required partyAffiliation,
      required party,
      required String candidateRole,
      required String district}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      String imageUrl = '';
      if (image != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child("candidates/${firebaseAuth.currentUser?.uid}");
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
      log("${firebaseAuth.currentUser!.uid} null");
      firestore
          .collection("Candidates")
          .doc(firebaseAuth.currentUser!.uid)
          .set({
        'uid': firebaseAuth.currentUser!.uid,
        'fullName': fullName,
        'image': imageUrl,
        'gender': gender,
        'DOB': dateOfBirth,
        'age': age, // Store the calculated age
        'voteRemaining': 1,
        'isCandidate': true,
        'totalVotes': 0,
        'number': number,
        'website': website,
        'twitter': twitter,
        'occupation': occupation,
        'cnic': cnic,
        'fullAddress': fullAddress,
        'province': province,
        'partyAffiliation': partyAffiliation,
        'party': party,
        'candidateRole': candidateRole,
        'district': district
      });
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log(e.code);
      throw Exception(e.code);
    }
  }

  Future<File?> pickProfileImage() async {
    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      File pickedFile = File(imageFile.path);

      // Resize the image before returning
      File resizedImage = await resizeImage(pickedFile);

      candidateProfileImage = resizedImage;
      notifyListeners();
      return candidateProfileImage;
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

  signOut(context) async {
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

  Future<Map<String, dynamic>?> fetchCandidateData(String uid) async {
    try {
      final candidateDoc =
          await firestore.collection('Candidates').doc(uid).get();
      if (candidateDoc.exists) {
        return candidateDoc.data();
      }
    } catch (e) {
      print('Error fetching candidate data: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchAllCandidates() async {
    try {
      final querySnapshot = await firestore
          .collection('Candidates')
          .where('isCandidate', isEqualTo: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching candidates data: $e');
      return [];
    }
  }

  Future<void> deleteCandidateAccount(BuildContext context,
      {required String uid}) async {
    try {
      // 1. Show Confirmation Dialog (Optional but recommended)
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete your account?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (!confirmDelete) {
        return; // User cancelled the deletion
      }

      // 3. Delete User Data from Firestore
      await FirebaseFirestore.instance
          .collection('Candidates')
          .doc(uid)
          .delete();

      // 4. Delete Image from Firebase Storage (if applicable)
      FirebaseStorage.instance.ref().child("candidates/$uid").delete();
      // 5. Delete Auth Account
      // await currentUser.delete();
    } catch (e) {
      // Handle errors (e.g., show a SnackBar or dialog)
      print('Error deleting user: $e');
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      fetchDistrictsAndCandidates() async {
    final snapshot = await firestore.collection('candidates').get();
    final allCandidates = snapshot.docs.map((doc) => doc.data()).toList();

    final Map<String, List<Map<String, dynamic>>> districts = {};
    for (var candidate in allCandidates) {
      final district = candidate['district'];
      if (!districts.containsKey(district)) {
        districts[district] = [];
      }
      districts[district]!.add(candidate);
    }
    return districts;
  }
}
