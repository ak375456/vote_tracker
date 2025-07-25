import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/Admin_Panel/candidate_info.dart';
import 'package:vote_tracker/Screens/Admin_Panel/register_candidate.dart';
import 'package:vote_tracker/Screens/Admin_Panel/visualize_Data.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/models/election_model.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';
import 'package:vote_tracker/providers/localization_provider.dart';
import 'package:vote_tracker/util/app_localizations.dart';
import 'package:vote_tracker/reusable_widgets/language_toggle.dart';

class AdminFirstScreen extends StatefulWidget {
  const AdminFirstScreen({super.key});

  @override
  State<AdminFirstScreen> createState() => _AdminFirstScreenState();
}

class _AdminFirstScreenState extends State<AdminFirstScreen> {
  final CandidateServices _candidateService = CandidateServices();
  Duration? _selectedDuration; // Track selected duration

  Future<List<Map<String, dynamic>>> _fetchAllCandidates() {
    return _candidateService.fetchAllCandidates();
  }

  Future<void> _refreshCandidates() async {
    setState(() {});
  }

  Future<void> _startElection() async {
    if (_selectedDuration == null) {
      final duration = await _showDurationDialog();
      if (duration == null) return;
      setState(() {
        _selectedDuration = duration;
      });
    }

    final electionId = 'election_${DateTime.now().millisecondsSinceEpoch}';
    final startTime = DateTime.now();
    final endTime = startTime.add(_selectedDuration!);

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

    await FirebaseFirestore.instance
        .collection('elections')
        .doc(electionId)
        .set(election.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).electionStarted)),
    );
  }

  Future<void> _endElection() async {
    try {
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
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('electionId', isEqualTo: activeElection.id)
          .get();

      if (votesSnapshot.docs.isEmpty) {
        log('No votes found for the active election');
        return;
      }

      final votes = votesSnapshot.docs.map((doc) => doc.data()).toList();
      final results = <String, Map<String, Map<String, Map<String, int>>>>{};

      for (var vote in votes) {
        final candidateId = vote['candidateId'] as String?;
        final candidateRole = vote['candidateRole'] as String?;

        if (candidateId == null || candidateRole == null) {
          log('Invalid vote data: $vote');
          continue;
        }

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

        results.putIfAbsent(province, () => {});
        results[province]!.putIfAbsent(
            district,
            () => {
                  'Minister Of Province Assembly': {},
                  'Minister Of National Assembly': {}
                });

        // Increment vote count
        final roleVotes = results[province]![district]![candidateRole]!;
        roleVotes[candidateId] = (roleVotes[candidateId] ?? 0) + 1;
      }

      final electionResults = <String, dynamic>{};
      results.forEach((province, provinceResults) {
        final provinceData = <String, dynamic>{};
        provinceResults.forEach((district, districtResults) {
          final provinceAssemblyResults =
              districtResults['Minister Of Province Assembly'];
          final nationalAssemblyResults =
              districtResults['Minister Of National Assembly'];

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

      await FirebaseFirestore.instance
          .collection('election_results')
          .doc('general_election_of_2024')
          .set({
        'results': electionResults,
        'timestamp': Timestamp.now(),
      });

      await activeElection.reference.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).electionEnded)),
      );
    } catch (e, stacktrace) {
      log('Error: $e\nStacktrace: $stacktrace');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final candidateServices =
        Provider.of<CandidateServices>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.adminPanel),
        actions: [
          const LanguageToggle(),
          IconButton(
            onPressed: () {
              AuthServices().signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            MyButton(
              buttonText: localizations.registerCandidate,
              buttonFunction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterCandidate(),
                  ),
                );
              },
            ),
            const Divider(),
            MyButton(
              buttonText: localizations.visualizeData,
              buttonFunction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VisualizeData(),
                  ),
                );
              },
            ),
            const Divider(),
            MyButton(
              buttonText: localizations.startElection,
              buttonFunction: _startElection,
            ),
            const Divider(),
            MyButton(
              buttonText: localizations.endElection,
              buttonFunction: _endElection,
            ),
            if (_selectedDuration != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  localizations.electionDuration(
                    _selectedDuration!.inMinutes,
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshCandidates,
                child: FutureBuilder(
                  future: _fetchAllCandidates(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: SpinKitCircle(color: darkGreenColor));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(localizations.errorFetchingData));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text(localizations.noCandidatesFound));
                    }
                    final candidates = snapshot.data!;
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: candidates.length,
                            itemBuilder: (context, index) {
                              final candidate = candidates[index];
                              return Slidable(
                                direction: Axis.horizontal,
                                endActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (BuildContext context) {
                                        log(candidate['uid']);
                                        candidateServices
                                            .deleteCandidateAccount(
                                          context,
                                          uid: candidate['uid'],
                                        );
                                      },
                                      icon: FontAwesomeIcons.deleteLeft,
                                      backgroundColor: Colors.redAccent,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.r)),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CandidateInfo(
                                          uid: candidate["uid"],
                                          name: candidate['fullName'],
                                          age: candidate['age'],
                                          cnic: candidate['cnic'],
                                          fullAddress: candidate['fullAddress'],
                                          gender: candidate['gender'],
                                          isCandidate: candidate['isCandidate'],
                                          number: candidate['number'],
                                          occupation: candidate['occupation'],
                                          party: candidate['party'],
                                          partyAffiliation:
                                              candidate['partyAffiliation'],
                                          province: candidate['province'],
                                          image: candidate['image'],
                                          twitter: candidate["twitter"],
                                          website: candidate['website'],
                                        ),
                                      ),
                                    );
                                  },
                                  title: Text(candidate['fullName']),
                                  subtitle: Text(
                                      '${localizations.party}: ${candidate['party']}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
