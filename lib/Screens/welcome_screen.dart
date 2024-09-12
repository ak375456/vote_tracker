import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/bottom_nav_bar_helper.dart';

import 'package:vote_tracker/reusable_widgets/my_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: REdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Lottie.asset("assets/welcomeA.json"),
              const Text(
                "Welcome to Votify! Your vote matters.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: MyButton(
                    buttonText: "Get Started",
                    buttonFunction: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavBarOfApp(),
                        ),
                        (route) => false, // Remove all previous routes
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
