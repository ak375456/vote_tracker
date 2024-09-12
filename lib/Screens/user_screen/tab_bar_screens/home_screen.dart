import 'dart:developer';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log("Home Screen");
    return const SafeArea(
      child: Scaffold(
        body: Text("Home screen"),
      ),
    );
  }
}
