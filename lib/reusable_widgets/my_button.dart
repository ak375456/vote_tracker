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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: buttonFunction,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: darkGreenColor,
              shape: BeveledRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(2)).r,
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                letterSpacing: 2.0,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
