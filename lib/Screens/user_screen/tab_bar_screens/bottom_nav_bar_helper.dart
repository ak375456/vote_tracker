import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/user_screen/mna_mpa_tab_bar_holder/mna_mpa_tab_bar_holder.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/home_screen.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/result_screen.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/voting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart'; // for Firebase

class BottomNavBarOfApp extends StatefulWidget {
  const BottomNavBarOfApp({super.key});

  @override
  State<BottomNavBarOfApp> createState() => _BottomNavBarOfAppState();
}

class _BottomNavBarOfAppState extends State<BottomNavBarOfApp> {
  int _selectedIndex = 0;
  String? userDistrict;

  @override
  void initState() {
    super.initState();
    _fetchUserDistrict();
  }

  Future<void> _fetchUserDistrict() async {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    final user = authServices.getCurrentUser();
    // Assuming you're fetching userDistrict from the current user's document in Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid) // Replace with actual user id
        .get();
    log(user.uid);
    if (userDoc.exists) {
      setState(() {
        userDistrict = userDoc.data()?['district'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log(userDistrict.toString());
    if (userDistrict == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Show loading screen while fetching userDistrict
    }

    final List<Widget> screens = [
      const HomeScreen(),
      MNAMPATabBarHolder(userDistrict: userDistrict!),
      ResultScreen(
        userDistrict: userDistrict!,
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          return true;
        } else {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 5),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              currentIndex: _selectedIndex,
              items: [
                BottomNavigationBarItem(
                  icon: _selectedIndex == 0
                      ? Image.asset("assets/home.png")
                      : Image.asset("assets/unSelectedHome.png"),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 1
                      ? Image.asset("assets/selectedVoting.png")
                      : Image.asset("assets/vote.png"),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 2
                      ? Image.asset("assets/selectedResult.png")
                      : Image.asset("assets/result.png"),
                  label: "",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
