import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';

class EditCandidateInfo extends StatefulWidget {
  const EditCandidateInfo({super.key});

  @override
  State<EditCandidateInfo> createState() => _EditCandidateInfoState();
}

class _EditCandidateInfoState extends State<EditCandidateInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Column(
            children: [
              Text("CANDIDATE DETAILS"),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              height: 80.h,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(159, 0, 0, 0),
                    offset: Offset(0, -1),
                    blurRadius: 5,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w), // Add horizontal padding if needed
                child: Align(
                  alignment:
                      Alignment.centerRight, // Aligns button to the right
                  child: MyButton(
                    buttonText: "Edit",
                    buttonFunction: () {},
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
