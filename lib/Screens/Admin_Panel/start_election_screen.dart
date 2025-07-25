import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vote_tracker/models/election_model.dart';
import 'package:vote_tracker/reusable_widgets/animated_container.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';
import 'package:vote_tracker/providers/localization_provider.dart';
import 'package:vote_tracker/util/app_localizations.dart';
import 'package:vote_tracker/reusable_widgets/language_toggle.dart';
import 'package:provider/provider.dart';

class StartElectionScreen extends StatefulWidget {
  const StartElectionScreen({super.key});

  @override
  State<StartElectionScreen> createState() => _StartElectionScreenState();
}

class _StartElectionScreenState extends State<StartElectionScreen> {
  final CandidateServices _candidateService = CandidateServices();
  final GlobalKey<FancyContainerState> _fancyContainerKey = GlobalKey();
  Duration? _selectedDuration;

  Future<Duration?> _showDurationDialog() async {
    int? selectedValue;
    final localizations = AppLocalizations.of(context);

    return showDialog<Duration>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.selectElectionDuration),
              content: DropdownButton<int>(
                value: selectedValue,
                items: [
                  DropdownMenuItem<int>(
                    value: 15,
                    child: Text(localizations.minutes(15)),
                  ),
                  DropdownMenuItem<int>(
                    value: 60,
                    child: Text(localizations.hours(1)),
                  ),
                  DropdownMenuItem<int>(
                    value: 1440,
                    child: Text(localizations.days(1)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                hint: Text(localizations.selectDuration),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text(localizations.cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedValue != null) {
                      Navigator.pop(context, Duration(minutes: selectedValue!));
                    }
                  },
                  child: Text(localizations.ok),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllCandidates() {
    return _candidateService.fetchAllCandidates();
  }

  Future<void> _startElection() async {
    _fancyContainerKey.currentState?.startAnimation();
    final electionId = 'election_${DateTime.now().millisecondsSinceEpoch}';
    final startTime = DateTime.now();
    
    if (_selectedDuration == null) {
      final duration = await _showDurationDialog();
      if (duration == null) return;
      setState(() {
        _selectedDuration = duration;
      });
    }

    final endTime = startTime.add(_selectedDuration!);

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

    await FirebaseFirestore.instance
        .collection('elections')
        .doc(electionId)
        .set(election.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).electionStarted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        centerTitle: true,
        actions: [
          const LanguageToggle(),
          IconButton(
            onPressed: () {
              _candidateService.signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: _endElection,
            icon: const Icon(Icons.stop),
          ),
        ],
      ),
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: _startElection,
                child: FancyContainer(
                  key: _fancyContainerKey,
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
            SizedBox(height: 50.h),
            if (_selectedDuration != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  localizations.electionDuration(_selectedDuration!.inMinutes),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            Text(
              localizations.startElectionPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _endElection() async {
    final localizations = AppLocalizations.of(context);
    
    try {
      final activeElectionSnapshot = await FirebaseFirestore.instance
          .collection('elections')
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (activeElectionSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.noActiveElection)),
        );
        return;
      }

      final activeElection = activeElectionSnapshot.docs.first;
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('electionId', isEqualTo: activeElection.id)
          .get();

      if (votesSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.noVotesFound)),
        );
        return;
      }

      final votes = votesSnapshot.docs.map((doc) => doc.data()).toList();
      final results = <String, Map<String, Map<String, Map<String, int>>>>{};

      for (var vote in votes) {
        final candidateId = vote['candidateId'] as String?;
        final candidateRole = vote['candidateRole'] as String?;

        if (candidateId == null || candidateRole == null) continue;

        final candidateDoc = await FirebaseFirestore.instance
            .collection('Candidates')
            .doc(candidateId)
            .get();

        final candidateData = candidateDoc.data();
        if (candidateData == null) continue;

        final district = candidateData['district'] as String?;
        final province = candidateData['province'] as String?;

        if (district == null || province == null) continue;

        results.putIfAbsent(province, () => {});
        results[province]!.putIfAbsent(
            district,
            () => {
                  'Minister Of Province Assembly': {},
                  'Minister Of National Assembly': {}
                });

        final roleVotes = results[province]![district]![candidateRole]!;
        roleVotes[candidateId] = (roleVotes[candidateId] ?? 0) + 1;
      }

      final electionResults = <String, dynamic>{};
      results.forEach((province, provinceResults) {
        final provinceData = <String, dynamic>{};
        provinceResults.forEach((district, districtResults) {
          final provinceAssemblyWinner = districtResults['Minister Of Province Assembly']!.entries
              .reduce((a, b) => a.value > b.value ? a : b);
          final nationalAssemblyWinner = districtResults['Minister Of National Assembly']!.entries
              .reduce((a, b) => a.value > b.value ? a : b);

          provinceData[district] = {
            'minister_of_province_assembly': provinceAssemblyWinner.key,
            'minister_of_national_assembly': nationalAssemblyWinner.key,
          };
        });
        electionResults[province] = provinceData;
      });

      await FirebaseFirestore.instance
          .collection('election_results')
          .doc('general_election_of_2024')
          .set({
        'results': electionResults,
        'timestamp': Timestamp.now(),
      });

      await activeElection.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.electionEnded)),
      );
    } catch (e, stacktrace) {
      log('Error: $e\nStacktrace: $stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.electionEndError)),
      );
    }
  }
}