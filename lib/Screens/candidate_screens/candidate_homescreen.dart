import 'package:flutter/material.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class VoteThroughAgentUser extends StatelessWidget {
  const VoteThroughAgentUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Vote Through Agent!"),
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
      body: Column(
        children: [],
      ),
    );
  }
}
