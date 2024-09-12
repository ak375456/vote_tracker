import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Future<Map<String, dynamic>> _fetchVotesData() async {
    final votesSnapshot =
        await FirebaseFirestore.instance.collection('votes').get();

    return Map.fromEntries(votesSnapshot.docs.map(
      (doc) => MapEntry(doc.id, doc.data()),
    ));
  }

  Future<Map<String, dynamic>> _fetchCandidatesData() async {
    final candidatesSnapshot =
        await FirebaseFirestore.instance.collection('Candidates').get();

    return Map.fromEntries(candidatesSnapshot.docs.map(
      (doc) => MapEntry(doc.id, doc.data()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Election Results')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchVotesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching votes data'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No votes data found'));
          }

          final votesData = snapshot.data!;

          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchCandidatesData(),
            builder: (context, candidateSnapshot) {
              if (candidateSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (candidateSnapshot.hasError) {
                return const Center(child: Text('Error fetching candidates'));
              }
              if (!candidateSnapshot.hasData ||
                  candidateSnapshot.data!.isEmpty) {
                return const Center(child: Text('No candidates data found'));
              }

              final candidatesData = candidateSnapshot.data!;
              final districtResults = <String, Map<String, Map<String, int>>>{};

              // Aggregate votes by district and seat type
              votesData.forEach((voteId, vote) {
                final candidateId = vote['candidateId'];
                final candidate = candidatesData[candidateId];
                final district = candidate['district'];
                final party = candidate['party'];
                final seatType = vote['candidateRole']; // 'MNA' or 'MPA'

                // Initialize if district is not in map
                districtResults[district] ??= {
                  'Minister Of National Assembly': <String, int>{},
                  'Minister Of Province Assembly': <String, int>{},
                };

                // Add votes for the seat type (MNA or MPA)
                if (seatType == 'Minister Of National Assembly') {
                  districtResults[district]!['Minister Of National Assembly']![
                      party] = (districtResults[district]![
                              'Minister Of National Assembly']![party] ??
                          0) +
                      1;
                } else {
                  districtResults[district]!['Minister Of Province Assembly']![
                      party] = (districtResults[district]![
                              'Minister Of Province Assembly']![party] ??
                          0) +
                      1;
                }
              });

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: districtResults.keys.length,
                  itemBuilder: (context, index) {
                    final district = districtResults.keys.elementAt(index);
                    final mnaVotes = districtResults[district]![
                        'Minister Of National Assembly']!;
                    final mpaVotes = districtResults[district]![
                        'Minister Of Province Assembly']!;

                    return Column(
                      children: [
                        ExpansionTile(
                          title: Text('District: $district'),
                          children: [
                            _buildPieChart(
                                'Party Votes for MNA in $district', mnaVotes),
                            const Divider(),
                            _buildPieChart(
                                'Party Votes for MPA in $district', mpaVotes),
                            const Divider(),
                            _buildWinnerInfo(
                                mnaVotes, 'Minister Of National Assembly'),
                            _buildWinnerInfo(
                                mpaVotes, 'Minister Of Province Assembly'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
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
                // Limit the length of the party name for better alignment
                final shortPartyName = entry.key.length > 12
                    ? entry.key.substring(0, 12) + '...'
                    : entry.key;
                return PieChartSectionData(
                  title: '$shortPartyName: ${percentage.toStringAsFixed(1)}%',
                  value: percentage,
                  color: _getColorForParty(entry.key),
                  titleStyle: const TextStyle(fontSize: 12), // Adjust text size
                  titlePositionPercentageOffset:
                      0.6, // Offset for better alignment
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Function to get the winner for a seat
  Widget _buildWinnerInfo(Map<String, int> votes, String seatType) {
    if (votes.isEmpty) {
      return const Text('No winner for this seat.');
    }

    final winnerParty =
        votes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return Text('Winner for $seatType: $winnerParty',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  // Utility function to assign colors to parties
  Color _getColorForParty(String party) {
    switch (party) {
      case 'PTI':
        return Colors.green;
      case 'PMLN':
        return Colors.red;
      case 'PPP':
        return Colors.blue;
      // Add more cases for other parties
      default:
        return Colors.grey;
    }
  }
}
