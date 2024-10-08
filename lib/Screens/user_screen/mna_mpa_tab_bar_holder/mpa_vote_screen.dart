import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vote_tracker/constants.dart';

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

  Future<void> _voteForCandidate(
      String candidateId, String candidateRole) async {
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
          .where('candidateRole', isEqualTo: candidateRole)
          .get();

      if (voteSnapshot.docs.isNotEmpty) {
        Fluttertoast.showToast(
            msg:
                'User has already voted for a candidate in this assembly type');
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

      final voteRef = _firestore.collection('votes').doc();
      await voteRef.set({
        'voterId': user.uid,
        'electionId': _electionId, // Ensure electionId is stored
        'candidateId': candidateId,
        'candidateRole': candidateRole,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _userVotes.add(candidateId);
        _candidatesFuture = _fetchCandidates(); // Refresh candidates list
      });

      Fluttertoast.showToast(
          msg: 'Vote recorded successfully for candidate: $candidateId');
    } catch (e) {
      log('Error voting for candidate: $e');
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
      appBar: AppBar(
        title: const Text("MPA Voting Screen"),
      ),
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
    final isFromUserDistrict = candidate['district'] == widget.userDistrict;
    final partyFlagPath = partyFlags[candidate['party']] ?? '';
    log("flag path:$partyFlagPath");

    return Card(
      margin: REdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(candidate['image']),
        ),
        title: Text(candidate['fullName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Party: ${candidate['party']}'),
            if (partyFlagPath.isNotEmpty)
              Image.asset(
                partyFlagPath,
                height: 50.h,
                width: 50.w,
              ),
            Text('Role: ${candidate['candidateRole']}'),
            Text('Province: ${candidate['province']}'),
            Text('District: ${candidate['district']}'),
            Text('Votes: ${candidate['totalVotes']}'),
          ],
        ),
        trailing: isFromUserDistrict
            ? _userVotes.contains(candidate['uid'])
                ? const Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
                    onPressed: () => _voteForCandidate(
                        candidate['uid'], candidate['candidateRole']),
                    child: const Text('Vote'),
                  )
            : null,
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
  // Add more party mappings
};
