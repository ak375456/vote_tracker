import 'package:flutter/material.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class CandidateHomeScreen extends StatelessWidget {
  const CandidateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Candidate home Screen"),
        actions: [
          IconButton(
            onPressed: () {
              CandidateServices().signOut(context);
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
    );
  }
}
