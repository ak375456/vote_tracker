import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authServices = Provider.of<AuthServices>(context, listen: false);
    log("Home Screen");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home screen"),
          actions: [
            IconButton(
              onPressed: () {
                authServices.signOut(context);
              },
              icon: const Icon(
                Icons.logout,
              ),
            ),
          ],
        ),
        body: const Column(
          children: [],
        ),
      ),
    );
  }
}
