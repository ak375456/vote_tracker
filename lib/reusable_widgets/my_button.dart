import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vote_tracker/constants.dart';

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  MyButton({super.key, required this.buttonText, required this.buttonFunction});
  String buttonText;
  Function()? buttonFunction;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: buttonFunction,
      style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Color(0xff2D8BBA),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)))),
      child: Text(
        buttonText,
        style: TextStyle(
          letterSpacing: 2.0,
          fontSize: 18.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
