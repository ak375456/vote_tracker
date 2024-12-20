import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        actions: [
          IconButton(
            onPressed: () {
              CandidateServices().signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
              onPressed: () {
                _endElection();
              },
              icon: const Icon(Icons.stop)),
        ],
        title: const Text("Votifiy"),
        centerTitle: true,
      ),
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(),
            Center(
              child: InkWell(
                onTap: _startElection,
                child: FancyContainer(
                  key:
                      _fancyContainerKey, // Set the key to access FancyContainer
                  size: const Size(250, 250),
                  cycle: const Duration(seconds: 2),
                  colors: const [
                    Colors.cyan,
                    Colors.blue,
                    Colors.blueAccent,
                    Colors.lightBlueAccent,
                    Colors.cyanAccent
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50.h,
            ),
            Text(
              "Press the ”Start” button to start the Election !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                decoration: TextDecoration.underline,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _endElection() async {
    try {
      // Fetch the active election
      final activeElectionSnapshot = await FirebaseFirestore.instance
          .collection('elections')
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (activeElectionSnapshot.docs.isEmpty) {
        log('No active election found');
        return;
      }

      final activeElection = activeElectionSnapshot.docs.first;

      // Fetch the votes for the active election
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('electionId', isEqualTo: activeElection.id)
          .get();

      if (votesSnapshot.docs.isEmpty) {
        log('No votes found for the active election');
        return;
      }

      final votes = votesSnapshot.docs.map((doc) => doc.data()).toList();

      // Initialize results structure
      final results = <String, Map<String, Map<String, Map<String, int>>>>{};

      for (var vote in votes) {
        // Check and extract required fields from the vote
        final candidateId = vote['candidateId'] as String?;
        final candidateRole = vote['candidateRole'] as String?;

        if (candidateId == null || candidateRole == null) {
          log('Invalid vote data: $vote');
          continue;
        }

        // Fetch the candidate document from Firestore
        final candidateDoc = await FirebaseFirestore.instance
            .collection('Candidates')
            .doc(candidateId)
            .get();

        final candidateData = candidateDoc.data();
        if (candidateData == null) {
          log('No candidate found for candidateId: $candidateId');
          continue;
        }

        final district = candidateData['district'] as String?;
        final province = candidateData['province'] as String?;

        if (district == null || province == null) {
          log('Missing district or province for candidateId: $candidateId');
          continue;
        }

        // Safely initialize nested map structures
        results.putIfAbsent(province, () => {});
        results[province]!.putIfAbsent(
            district,
            () => {
                  'Minister Of Province Assembly': {},
                  'Minister Of National Assembly': {}
                });

        // Increment vote count
        // final roleVotes = results[province]![district]![candidateRole]!;
        // roleVotes[candidateId] = (roleVotes[candidateId] ?? 0) + 1;
      }

      // Calculate the election winners for each district and province
      final electionResults = <String, dynamic>{};

      results.forEach((province, provinceResults) {
        final provinceData = <String, dynamic>{};

        provinceResults.forEach((district, districtResults) {
          final provinceAssemblyResults =
              districtResults['Minister Of Province Assembly'];
          final nationalAssemblyResults =
              districtResults['Minister Of National Assembly'];

          // Determine the winners if votes are available
          if (provinceAssemblyResults != null &&
              provinceAssemblyResults.isNotEmpty) {
            final provinceAssemblyWinner = provinceAssemblyResults.entries
                .reduce((a, b) => a.value > b.value ? a : b);
            provinceData[district] = {
              'minister_of_province_assembly': provinceAssemblyWinner.key
            };
          }

          if (nationalAssemblyResults != null &&
              nationalAssemblyResults.isNotEmpty) {
            final nationalAssemblyWinner = nationalAssemblyResults.entries
                .reduce((a, b) => a.value > b.value ? a : b);
            provinceData[district] ??= {};
            provinceData[district]['minister_of_national_assembly'] =
                nationalAssemblyWinner.key;
          }
        });

        electionResults[province] = provinceData;
      });

      // Save the election results to Firestore
      await FirebaseFirestore.instance
          .collection('election_results')
          .doc('general_election_of_2024')
          .set({
        'results': electionResults,
        'timestamp': Timestamp.now(),
      });

      // Remove the active election
      await activeElection.reference.delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Election ended successfully! Results saved.'),
        ),
      );
    } catch (e, stacktrace) {
      log('Error: $e\nStacktrace: $stacktrace');
    }
  }
}
