import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vote_tracker/Screens/auth_screens/login_screen.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(),
          SizedBox(
            height: 268.h,
            width: 268.h,
            child: Image.asset("assets/boardingPageImage.png"),
          ),
          SizedBox(
            height: 59.h,
          ),
          const Text(
            "Welcome to Votify!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 30.h,
          ),
          Padding(
            padding: REdgeInsets.symmetric(horizontal: 39.0),
            child: const Text(
              "Vote, create and manage elections with real-time results",
              style: TextStyle(
                fontSize: 20,
                color: Color(0x58585880),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 59.h,
          ),
          MyButton(
            buttonText: "Get Started",
            buttonFunction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
