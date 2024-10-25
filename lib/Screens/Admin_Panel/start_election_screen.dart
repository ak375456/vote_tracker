import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vote_tracker/models/election_model.dart';
import 'package:vote_tracker/reusable_widgets/animated_container.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class StartElectionScreen extends StatefulWidget {
  const StartElectionScreen({super.key});

  @override
  State<StartElectionScreen> createState() => _StartElectionScreenState();
}

class _StartElectionScreenState extends State<StartElectionScreen> {
  Future<Duration?> _showDurationDialog() async {
    int? selectedValue;
    return showDialog<Duration>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Election Duration'),
          content: DropdownButton<int>(
            items: const [
              DropdownMenuItem(value: 15, child: Text('15 Minutes')),
              DropdownMenuItem(value: 60, child: Text('1 Hour')),
              DropdownMenuItem(value: 1440, child: Text('1 Day')),
            ],
            onChanged: (value) {
              selectedValue = value;
            },
            hint: const Text('Select duration'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedValue != null) {
                  Navigator.pop(context, Duration(minutes: selectedValue!));
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  final CandidateServices _candidateService = CandidateServices();
  Future<List<Map<String, dynamic>>> _fetchAllCandidates() {
    return _candidateService.fetchAllCandidates();
  }

  final GlobalKey<FancyContainerState> _fancyContainerKey = GlobalKey();
  Future<void> _startElection() async {
    _fancyContainerKey.currentState?.startAnimation();
    final electionId = 'election_${DateTime.now().millisecondsSinceEpoch}';
    final startTime = DateTime.now();
    final Duration? duration = await _showDurationDialog();

    if (duration == null) {
      return; // User canceled the dialog
    }

    final endTime = startTime.add(duration);

    // Fetch candidates and group by district
    final candidates = await _fetchAllCandidates();
    final Map<String, List<Map<String, dynamic>>> candidatesByDistrict = {};

    for (var candidate in candidates) {
      final district = candidate['district'];
      if (!candidatesByDistrict.containsKey(district)) {
        candidatesByDistrict[district] = [];
      }
      candidatesByDistrict[district]!.add(candidate);
    }

    final election = Election(
      id: electionId,
      startTime: startTime,
      endTime: endTime,
      candidatesByDistrict: candidatesByDistrict,
    );

    // Store election in Firestore
    await FirebaseFirestore.instance
        .collection('elections')
        .doc(electionId)
        .set(election.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Election started successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Votifiy"),
        centerTitle: true,
      ),
      body: Center(
        child: InkWell(
          onTap: _startElection,
          child: FancyContainer(
            key: _fancyContainerKey, // Set the key to access FancyContainer
            size: const Size(250, 250),
            cycle: const Duration(seconds: 2),
            colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
          ),
        ),
      ),
    );
  }
}
