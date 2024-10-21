import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MnaVoteScreen extends StatefulWidget {
  final String userDistrict;
  const MnaVoteScreen({super.key, required this.userDistrict});

  @override
  State<MnaVoteScreen> createState() => _MnaVoteScreenState();
}

class _MnaVoteScreenState extends State<MnaVoteScreen> {
  late Future<List<Map<String, dynamic>>> _candidatesFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _userVotes = [];
  bool _isLoading = false;
  String? _electionId;

  @override
  void initState() {
    super.initState();
    _candidatesFuture = _fetchCandidates();
    _fetchUserVotes();
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
      _electionId = electionSnapshot.docs.first.id;
      final candidatesByDistrict =
          electionData['candidatesByDistrict'] as Map<String, dynamic>;

      if (!candidatesByDistrict.containsKey(widget.userDistrict)) {
        log('No candidates found for user\'s district');
        return [];
      }

      final candidates = List<Map<String, dynamic>>.from(
          candidatesByDistrict[widget.userDistrict]);
      return candidates
          .where((candidate) =>
              candidate['candidateRole'] == 'Minister Of National Assembly')
          .toList();
    } catch (e) {
      log('Error fetching candidates: $e');
      return [];
    }
  }

  Future<void> _fetchUserVotes() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('User not logged in');
      return;
    }

    try {
      final voteSnapshot = await _firestore
          .collection('votes')
          .where('voterId', isEqualTo: user.uid)
          .get();

      setState(() {
        _userVotes = voteSnapshot.docs
            .map((doc) => doc['candidateId'] as String)
            .toList();
      });
    } catch (e) {
      log('Error fetching user votes: $e');
    }
  }

  Future<void> _voteForCandidate(String candidateId) async {
    final user = _auth.currentUser;
    if (user == null) {
      log('User not logged in');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final voteSnapshot = await _firestore
          .collection('votes')
          .where('voterId', isEqualTo: user.uid)
          .where('electionId', isEqualTo: _electionId)
          .where('candidateRole', isEqualTo: 'Minister Of National Assembly')
          .get();

      if (voteSnapshot.docs.isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'You have already voted for an MNA candidate.');
        return;
      }

      final candidateRef = _firestore.collection('Candidates').doc(candidateId);
      await _firestore.runTransaction((transaction) async {
        final candidateSnapshot = await transaction.get(candidateRef);
        if (!candidateSnapshot.exists) {
          throw Exception('Candidate does not exist!');
        }

        final newVoteCount = (candidateSnapshot.data()?['totalVotes'] ?? 0) + 1;
        transaction.update(candidateRef, {'totalVotes': newVoteCount});
      });

      await _firestore.collection('votes').add({
        'voterId': user.uid,
        'electionId': _electionId,
        'candidateId': candidateId,
        'candidateRole': 'Minister Of National Assembly',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _userVotes.add(candidateId);
      });

      Fluttertoast.showToast(
          msg: 'Vote recorded successfully for MNA candidate: $candidateId');
    } catch (e) {
      log('Error voting for candidate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final isFromUserDistrict = candidate['district'] == widget.userDistrict;
    final partyFlagPath = partyFlags[candidate['party']] ?? '';

    return Container(
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
              Container(
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
                  color: const Color.fromARGB(255, 192, 192, 192),
                ),
                child: Text(
                  candidate['party'],
                ),
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(partyFlagPath),
              )
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
                    CircleAvatar(
                      maxRadius: 40,
                      backgroundImage: NetworkImage(
                        candidate['image'],
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
                              fontSize: 12.sp, color: Color(0xff585858)),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: REdgeInsets.only(left: 0.0),
            child: Container(
              child: Row(
                children: [
                  const CircleAvatar(
                    maxRadius: 40,
                    backgroundColor: Colors.red,
                  ),
                  SizedBox(
                    width: 16.w,
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: const Center(
                      child: Text(
                        "MNA",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.w,
                  ),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: Center(
                      child: Text(
                        extractTextInBrackets(candidate['party']),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.w,
                  ),
                  Padding(
                    padding: REdgeInsets.only(left: 22),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  _userVotes.contains(candidate['uid'])
                                      ? 'assets/voteIcons/VotedCircle.png'
                                      : 'assets/voteIcons/NotVotedCircle.png',
                                ),
                                GestureDetector(
                                  onTap: !_userVotes.contains(candidate['uid'])
                                      ? () =>
                                          _voteForCandidate(candidate['uid'])
                                      : null,
                                  child: Image.asset(
                                    _userVotes.contains(candidate['uid'])
                                        ? 'assets/voteIcons/VotedIcon.png'
                                        : 'assets/voteIcons/NotVotedIcon.png',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            GestureDetector(
                              onTap: !_userVotes.contains(candidate['uid'])
                                  ? () => _voteForCandidate(candidate['uid'])
                                  : null,
                              child: Image.asset(
                                _userVotes.contains(candidate['uid'])
                                    ? 'assets/voteIcons/voted.png'
                                    : 'assets/voteIcons/Vote.png',
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
          )
        ],
      ),
    );
  }

  String extractTextInBrackets(String text) {
    final RegExp regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(text);
    return match != null ? match.group(1) ?? '' : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        //useless stack
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _candidatesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                log('Error: ${snapshot.error}');
                return const Center(child: Text('Error fetching data'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No candidates found'));
              }

              final candidates = snapshot.data!;
              return ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  return _buildCandidateCard(candidate);
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

const Map<String, String> partyFlags = {
  'Pakistan Muslim League-Nawaz (PML-N)': 'assets/partyflags/PML-N.png',
  'Pakistan Tehreek-e-Insaf (PTI)': 'assets/partyflags/PTI.png',
  "Pakistan Peoples Party (PPP)": 'assets/partyflags/PPPP.png',
  'Jamiat Ulema-e-Islam (F)': 'assets/partyflags/JUI.png',
  'Tehreek-e-Labbaik Pakistan (TLP)': 'assets/partyflags/TLP.png'
  // Add more party mappings as necessary
};
