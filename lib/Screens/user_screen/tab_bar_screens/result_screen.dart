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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
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
            SizedBox(height: 22.h),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "District result",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Display both pie charts horizontally using Row
            Row(
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
                SizedBox(width: 16.w), // Space between charts
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
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title, Map<String, int> votes) {
    final totalVotes = votes.values.fold(0, (a, b) => a + b);

    if (totalVotes == 0) {
      return const Center(child: Text('No votes to display'));
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: votes.entries.map((entry) {
                final percentage = (entry.value / totalVotes) * 100;
                return PieChartSectionData(
                  title: '${entry.key}: ${percentage.toStringAsFixed(1)}%',
                  value: percentage,
                  color: _getColorForParty(entry.key),
                  titleStyle: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Assign colors based on party name
  Color _getColorForParty(String party) {
    switch (party) {
      case 'Pakistan Tehreek-e-Insaf (PTI)':
        return Color(0xff41B8D5);
      case 'Pakistan Muslim League-Nawaz (PML-N)':
        return Color(0xff2d8bba);
      case 'Pakistan Peoples Party (PPP)':
        return Color(0xff2f5f98);
      case 'Jamiat Ulema-e-Islam (F)':
        return Color(0xff31356e);
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
