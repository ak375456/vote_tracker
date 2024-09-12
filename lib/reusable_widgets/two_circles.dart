import 'package:flutter/material.dart';

class TwoCircles extends StatelessWidget {
  const TwoCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Image.asset(
        "assets/circle.png",
      ),
    );
  }
}
