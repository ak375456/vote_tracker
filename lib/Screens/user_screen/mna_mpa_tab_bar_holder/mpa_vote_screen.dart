import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vote_tracker/constants.dart';
import 'dart:ui';

class MpaVoteScreen extends StatefulWidget {
  final String userDistrict;

  const MpaVoteScreen({super.key, required this.userDistrict});

  @override
  State<MpaVoteScreen> createState() => _MpaVoteScreenState();
}

class _MpaVoteScreenState extends State<MpaVoteScreen> {
  late Future<List<Map<String, dynamic>>> _candidatesFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<String>> _userVotesFuture;
  List<String> _userVotes = [];
  bool _isLoading = false;
  String? _electionId; // Add this to store the election ID

  @override
  void initState() {
    super.initState();
    _candidatesFuture = _fetchCandidates();
    _userVotesFuture = _fetchUserVotes();
  }

  Future<List<Map<String, dynamic>>> _fetchCandidates() async {
    try {
      final now = DateTime.now();
      final electionSnapshot = await _firestore
          .collection('elections')
          .where('startTime', isLessThanOrEqualTo: now)
          .where('endTime', isGreaterThanOrEqualTo: now)
          .limit(1)
          .get();

      if (electionSnapshot.docs.isEmpty) {
        log('No active election found');
        return [];
      }

      final electionData = electionSnapshot.docs.first.data();
      _electionId = electionSnapshot.docs.first.id; // Save the election ID
      final candidatesByDistrict =
          electionData['candidatesByDistrict'] as Map<String, dynamic>;

      if (!candidatesByDistrict.containsKey(widget.userDistrict)) {
        log('No candidates found for user\'s district');
        return [];
      }

      final allCandidates = List<Map<String, dynamic>>.from(
          candidatesByDistrict[widget.userDistrict]);

      return allCandidates
          .where((c) => c['candidateRole'] == 'Minister Of Province Assembly')
          .toList();
    } catch (e) {
      log('Error fetching candidates: $e');
      return [];
    }
  }

  Future<List<String>> _fetchUserVotes() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('User not logged in');
      return [];
    }

    try {
      final voteSnapshot = await _firestore
          .collection('votes')
          .where('voterId', isEqualTo: user.uid)
          .get();

      return voteSnapshot.docs
          .map((doc) => doc['candidateId'] as String)
          .toList();
    } catch (e) {
      log('Error fetching user votes: $e');
      return [];
    }
  }

  Future<void> _voteForMPACandidate(String candidateId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('User not logged in');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the user has already voted for an MPA candidate
      final voteSnapshot = await _firestore
          .collection('votes')
          .where('voterId', isEqualTo: user.uid)
          .where('electionId', isEqualTo: _electionId)
          .where('candidateRole', isEqualTo: 'Minister Of Provincial Assembly')
          .get();

      if (voteSnapshot.docs.isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'You have already voted for an MPA candidate.');
        return;
      }

      // Reference the candidate document
      final candidateRef = _firestore.collection('Candidates').doc(candidateId);

      await _firestore.runTransaction((transaction) async {
        // Get the candidate's current vote count
        final candidateSnapshot = await transaction.get(candidateRef);
        if (!candidateSnapshot.exists) {
          throw Exception('Candidate does not exist!');
        }

        // Increment the vote count
        final newVoteCount = (candidateSnapshot.data()?['totalVotes'] ?? 0) + 1;
        transaction.update(candidateRef, {'totalVotes': newVoteCount});
      });

      // Record the vote in the 'votes' collection
      await _firestore.collection('votes').add({
        'voterId': user.uid,
        'electionId': _electionId,
        'candidateId': candidateId,
        'candidateRole': 'Minister Of Provincial Assembly',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the state and refresh the UI
      setState(() {
        _userVotes.add(candidateId);
        _candidatesFuture = _fetchCandidates(); // Refresh candidates list
      });

      Fluttertoast.showToast(
          msg: 'Vote recorded successfully for MPA candidate: $candidateId');
    } catch (e) {
      log('Error voting for MPA candidate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _candidatesFuture = _fetchCandidates();
      _userVotesFuture = _fetchUserVotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _candidatesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SpinKitDualRing(color: darkGreenColor));
              }
              if (snapshot.hasError) {
                log('Error in FutureBuilder: ${snapshot.error}');
                return const Center(child: Text('Error fetching data'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                log('No candidates data found');
                return const Center(child: Text('No candidates found'));
              }

              return FutureBuilder<List<String>>(
                future: _userVotesFuture,
                builder: (context, userVotesSnapshot) {
                  if (userVotesSnapshot.hasError) {
                    log('Error in FutureBuilder: ${userVotesSnapshot.error}');
                    return const Center(child: Text('Error fetching data'));
                  }
                  if (userVotesSnapshot.hasData) {
                    _userVotes = userVotesSnapshot.data!;
                  }

                  final candidates = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView(
                      children: candidates
                          .map((candidate) => _buildCandidateCard(candidate))
                          .toList(),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        margin: REdgeInsets.symmetric(vertical: 18),
        padding: REdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 1.w,
            color: const Color.fromARGB(120, 0, 0, 0),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: REdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(159, 0, 0, 0),
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                      color: const Color.fromARGB(255, 248, 247, 247),
                    ),
                    child: Text(
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w400),
                      candidate['party'],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 84, // 80 for CircleAvatar + 2*2 for border width
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          maxRadius: 40,
                          backgroundImage: NetworkImage(candidate['image']),
                        ),
                      ),
                      SizedBox(
                        width: 5.h,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate['fullName'],
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            candidate['fullAddress'].toString().substring(0,
                                candidate['fullAddress'].toString().length - 9),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xff585858),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            SizedBox(
              width: 16.w,
            ),
            Padding(
              padding: REdgeInsets.only(right: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Stack(
                                children: [
                                  // Frosted glass effect for the background
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 5.0, sigmaY: 5.0),
                                    child: Container(
                                      color: Colors.white.withOpacity(
                                          0.2), // Slight dark overlay
                                    ),
                                  ),
                                  // Original AlertDialog
                                  AlertDialog(
                                    actionsAlignment: MainAxisAlignment.center,
                                    title: Center(
                                      child: Text(
                                        "Confirm Vote?",
                                        style: TextStyle(fontSize: 20.sp),
                                      ),
                                    ),
                                    actions: [
                                      SizedBox(
                                        width: 100.w,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: const RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16.w,
                                      ),
                                      SizedBox(
                                        width: 100.w,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Register vote and update UI
                                            _voteForMPACandidate(
                                                candidate['uid']);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff2d8bba),
                                            foregroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: const Text("Vote"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _userVotes.contains(candidate['uid'])
                              ? Colors
                                  .green // Change to a different color after voting
                              : const Color(0xff2F5F98), // Initial button color
                          foregroundColor: _userVotes.contains(candidate['uid'])
                              ? Colors.white // Change text color after voting
                              : Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.r),
                            ),
                          ),
                        ),
                        child: Text(
                          _userVotes.contains(candidate['uid'])
                              ? "Voted"
                              : "Vote",
                          style: TextStyle(
                            color: _userVotes.contains(candidate['uid'])
                                ? Colors.white
                                : Colors.white, // Optional text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String extractTextInBrackets(String text) {
    final RegExp regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(text);
    return match != null ? match.group(1) ?? '' : '';
  }
}
