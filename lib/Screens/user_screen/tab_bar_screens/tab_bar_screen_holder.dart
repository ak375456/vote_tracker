import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/home_screen.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/result_screen.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/voting_screen.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';

class TabBarHolder extends StatefulWidget {
  const TabBarHolder({super.key});

  @override
  State<TabBarHolder> createState() => _TabBarHolderState();
}

class _TabBarHolderState extends State<TabBarHolder>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  String? userDistrict;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    );

    _fetchUserDistrict();
  }

  Future<void> _fetchUserDistrict() async {
    try {
      final authServices = Provider.of<AuthServices>(context, listen: false);
      final user = authServices.getCurrentUser();
      if (user != null) {
        log('User ID: ${user.uid}');
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userDistrict = userDoc.data()?['district'];
            isLoading = false;
          });
          log('User District: $userDistrict');
        } else {
          log('User document does not exist');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        log('No user is currently signed in');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching user district: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("Screen Holder");
    final authServices = Provider.of<AuthServices>(context, listen: false);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        bottom: TabBar(
          dividerColor: lightGreenColor,
          dividerHeight: 2,
          automaticIndicatorColorAdjustment: false,
          controller: controller,
          indicatorColor: lightGreenColor,
          labelPadding: const EdgeInsets.only(bottom: 10),
          overlayColor: WidgetStateProperty.all(Colors.grey.withOpacity(0.5)),
          unselectedLabelColor: const Color.fromARGB(255, 113, 144, 161),
          labelColor: Colors.white,
          tabs: const [
            Text(
              "Home",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Voting",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Result",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        title: const Text(
          "Votify",
          style: TextStyle(),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await authServices.signOut(context);
              // Reset the TabController's index after sign out
              controller.index = 0;
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        backgroundColor: darkGreenColor,
      ),
      body: TabBarView(
        controller: controller,
        children: [
          const HomeScreen(),
          VotingScreen(userDistrict: userDistrict ?? ''),
          const ResultScreen(),
        ],
      ),
    );
  }
}
