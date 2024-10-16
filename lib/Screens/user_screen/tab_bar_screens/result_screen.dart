import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResultScreen extends StatefulWidget {
  final String userDistrict; // User's district passed here

  const ResultScreen({super.key, required this.userDistrict});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _searchQuery = '';

  // Fetch votes based on the candidate role (MNA/MPA) and district
  Future<Map<String, int>> _fetchVotes(String candidateRole) async {
    try {
      final votesSnapshot = await FirebaseFirestore.instance
          .collection('votes')
          .where('candidateRole', isEqualTo: candidateRole)
          .get();

      final voteCount = <String, int>{};

      for (var doc in votesSnapshot.docs) {
        final candidateId = doc['candidateId'];
        final candidateSnapshot = await FirebaseFirestore.instance
            .collection('Candidates')
            .doc(candidateId)
            .get();

        if (candidateSnapshot.exists &&
            candidateSnapshot['district'].toString().toLowerCase() ==
                widget.userDistrict.toLowerCase()) {
          final party = candidateSnapshot['party'];
          voteCount[party] = (voteCount[party] ?? 0) + 1;
        }
      }
      return voteCount;
    } catch (e) {
      print('Error fetching $candidateRole votes: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.notifications_none),
        actions: const [CircleAvatar()],
        title: const Text('Search District'),
      ),
      body: Column(
        children: [
          Padding(
            padding: REdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search District',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          SizedBox(height: 22.h),
          Padding(
            padding: REdgeInsets.symmetric(horizontal: 8.0),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "District result",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Display both pie charts horizontally using Row
          Padding(
            padding: REdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, int>>(
                    future: _fetchVotes('Minister Of National Assembly'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Text('Error fetching MNA votes');
                      }
                      return _buildPieChart('MNA Results', snapshot.data!);
                    },
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: FutureBuilder<Map<String, int>>(
                    future: _fetchVotes('Minister Of Provincial Assembly'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Text('Error fetching MPA votes');
                      }
                      if (snapshot.data!.isEmpty) {
                        return const Text(
                            'No MPA votes found for this district.');
                      }
                      return _buildPieChart('MPA Results', snapshot.data!);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(String title, Map<String, int> votes) {
    final widthOfScreen = MediaQuery.of(context).size.width.w;
    final totalVotes = votes.values.fold(0, (a, b) => a + b);
    log(widthOfScreen.toString());

    if (totalVotes == 0) {
      return const Center(child: Text('No votes to display'));
    }

    return Container(
      // padding: EdgeInsets.only(right: 15),
      // margin: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(width: 0.5.w),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            offset: Offset(3, 5),
            blurRadius: 3,
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              differentColorContainers(votes),
              // const SizedBox(
              //   width: 50,
              // ),
              Expanded(
                child: Container(
                  padding: REdgeInsets.only(right: 5, bottom: 5),
                  height: 100.h,
                  child: SizedBox(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        titleSunbeamLayout: true,
                        centerSpaceRadius: 15.r,
                        sections: votes.entries.map((entry) {
                          final percentage = (entry.value / totalVotes) * 100;
                          final partyName =
                              extractPartyNameFromBrackets(entry.key);
                          return PieChartSectionData(
                            radius: 35,
                            title: '${percentage.toStringAsFixed(1)}%',
                            value: percentage,
                            color: _getColorForParty(entry.key),
                            titleStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget differentColorContainers(Map<String, int> votes) {
    // Extract unique party names from the votes
    final uniqueParties = votes.keys.toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align content to the start
      children: uniqueParties.map((party) {
        final partyName =
            extractPartyNameFromBrackets(party); // Extract party name
        final color = _getColorForParty(party); // Get corresponding color

        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 4.0, horizontal: 4.0), // Spacing between rows
          child: Row(
            mainAxisSize: MainAxisSize.max, // Keep the row compact
            children: [
              Container(
                width: 12.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle, // Circular shape
                ),
              ),
              SizedBox(width: 4.w), // Space between the dot and the party name
              Text(
                partyName,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForParty(String party) {
    switch (party) {
      case 'Pakistan Tehreek-e-Insaf (PTI)':
        return Color(0xff41B8D5);
      case 'Pakistan Muslim League-Nawaz (PML-N)':
        return Color(0xff2d8bba);
      case 'Pakistan Peoples Party (PPP)':
        return Color(0xff2f5f98);
      case 'Jamiat Ulema-e-Islam (F)':
        return Color.fromARGB(255, 97, 104, 206);
      case 'Muttahida Qaumi Movement (MQM)':
        return Colors.blue;
      case 'Awami National Party (ANP)':
        return Colors.blueAccent;
      case 'Tehreek-e-Labbaik Pakistan (TLP)':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}

String extractPartyNameFromBrackets(String text) {
  final RegExp regex = RegExp(r'\(([^)]+)\)');
  final match = regex.firstMatch(text);
  return match != null ? match.group(1) ?? '' : text;
}
