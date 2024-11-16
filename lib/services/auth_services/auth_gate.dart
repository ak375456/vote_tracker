import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote_tracker/Screens/Admin_Panel/admin_screen_bottom_nav_holder.dart';
import 'package:vote_tracker/Screens/OnBoardingScreen/boarding_screen.dart';
import 'package:vote_tracker/Screens/candidate_screens/candidate_homescreen.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/bottom_nav_bar_helper.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => AuthGateState();
}

class AuthGateState extends State<AuthGate> {
  User? _user;
  bool _isCandidate =
      false; // Add a state variable to track if the user is a candidate

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      await _checkIfCandidate(); // Check if the user is a candidate
      setState(() {});
    }
  }

  Future<void> _checkIfCandidate() async {
    final candidateDoc = await FirebaseFirestore.instance
        .collection('Candidates')
        .doc(_user!.uid)
        .get();
    if (candidateDoc.exists && candidateDoc.data()?['isCandidate'] == true) {
      _isCandidate = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (_user != null) {
          if (_isCandidate) {
            return const CandidateHomeScreen();
          } else if (_user!.uid == 'SSV3VhaghwNOa8RSJDavNCZmOtW2') {
            return const BottomNavBarOfAdmin();
          } else {
            return const BottomNavBarOfApp();
          }
        } else {
          return const BoardingScreen();
        }
      },
    );
  }
}
