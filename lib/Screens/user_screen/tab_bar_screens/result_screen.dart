import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';

class ResultScreen extends StatefulWidget {
  final String userDistrict; // User's district passed here

  const ResultScreen({super.key, required this.userDistrict});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _searchQuery = '';
  String _selectedRole = 'Minister Of National Assembly'; // Role dropdown state
  String _selectedProvince = 'Khyber Pakhtunkhwa'; // Province dropdown state

  final List<String> roles = [
    'Minister Of National Assembly',
    'Minister Of Provincial Assembly',
  ];

  final List<String> provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
  ];

  // Fetch votes for a given province and role
  Future<Map<String, int>> _fetchProvinceVotes(
      String candidateRole, String province) async {
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
            candidateSnapshot['province'].toString().toLowerCase() ==
                province.toLowerCase()) {
          final party = candidateSnapshot['party'];
          voteCount[party] = (voteCount[party] ?? 0) + 1;
        }
      }
      return voteCount;
    } catch (e) {
      print('Error fetching votes: $e');
      return {};
    }
  }

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

  Future<Map<String, int>> _fetchOverallPakistanVotes() async {
    try {
      final votesSnapshot =
          await FirebaseFirestore.instance.collection('votes').get();

      final voteCount = <String, int>{};

      for (var doc in votesSnapshot.docs) {
        final candidateId = doc['candidateId'];
        final candidateSnapshot = await FirebaseFirestore.instance
            .collection('Candidates')
            .doc(candidateId)
            .get();

        if (candidateSnapshot.exists) {
          final party = candidateSnapshot['party'];
          voteCount[party] = (voteCount[party] ?? 0) + 1;
        }
      }

      // Sort the voteCount map to get the top parties
      final sortedVotes = Map.fromEntries(
        voteCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      return sortedVotes;
    } catch (e) {
      print('Error fetching overall Pakistan votes: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  String? profileImageUrl;
  Future<void> loadUserData() async {
    final userServices = Provider.of<AuthServices>(context);
    try {
      final userData = await userServices.getCurrentUserData();
      if (userData != null && userData['image'] != null) {
        setState(() {
          profileImageUrl = userData['image'];
        });
      } else {
        log("No profile image found.");
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    }
  }

  TextEditingController districtController = TextEditingController();
  String? districtName;
  String? mnaWinnerName;
  String? mpaWinnerName;

  Future<Map<String, String>> fetchWinners(String districtName) async {
    // Step 1: Fetch all candidates to map candidateId to district and name
    final candidatesSnapshot =
        await FirebaseFirestore.instance.collection('Candidates').get();
    Map<String, Map<String, String>> candidatesMap = {};

    for (var doc in candidatesSnapshot.docs) {
      final data = doc.data();
      candidatesMap[doc.id] = {
        'district': data['district'],
        'name': data['fullName'], // Correct field for name
        'role': data['candidateRole'],
      };
      print(
          "Candidate ID: ${doc.id}, District: ${data['district']}, Role: ${data['candidateRole']}, Name: ${data['fullName']}");
    }

    // Step 2: Fetch all votes and filter by district
    final votesSnapshot =
        await FirebaseFirestore.instance.collection('votes').get();
    Map<String, int> mnaVotes = {};
    Map<String, int> mpaVotes = {};

    for (var doc in votesSnapshot.docs) {
      final data = doc.data();
      String candidateId = data['candidateId'];
      String candidateRole = data['candidateRole'];

      // Check if candidate belongs to the given district
      print(
          "Vote for candidate: $candidateId, Role: $candidateRole, District: ${candidatesMap[candidateId]?['district']}");

      if (candidatesMap[candidateId]?['district'] == districtName) {
        print("Matching district for candidate ID: $candidateId");

        if (candidateRole == "Minister Of National Assembly") {
          mnaVotes[candidateId] = (mnaVotes[candidateId] ?? 0) + 1;
          print("MNA Vote counted for candidate ID: $candidateId");
        } else if (candidateRole == "Minister Of Provincial Assembly") {
          mpaVotes[candidateId] = (mpaVotes[candidateId] ?? 0) + 1;
          print("MPA Vote counted for candidate ID: $candidateId");
        }
      }
    }

    // Step 3: Find winners
    String? mnaWinnerId = mnaVotes.entries.isNotEmpty
        ? mnaVotes.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;
    String? mpaWinnerId = mpaVotes.entries.isNotEmpty
        ? mpaVotes.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    // Map winner IDs to names (using fullName)
    String mnaWinnerName =
        mnaWinnerId != null && candidatesMap[mnaWinnerId] != null
            ? candidatesMap[mnaWinnerId]!['name'] ?? "No Winner"
            : "No Winner";
    String mpaWinnerName =
        mpaWinnerId != null && candidatesMap[mpaWinnerId] != null
            ? candidatesMap[mpaWinnerId]!['name'] ?? "No Winner"
            : "No Winner";

    print("MNA Winner: $mnaWinnerName");
    print("MPA Winner: $mpaWinnerName");

    return {
      'MNA': mnaWinnerName,
      'MPA': mpaWinnerName,
    };
  }

  void searchDistrict() async {
    String districtName = districtController.text.trim();
    if (districtName.isNotEmpty) {
      Map<String, String> winners = await fetchWinners(districtName);
      setState(() {
        mnaWinnerName = winners['MNA']!;
        mpaWinnerName = winners['MPA']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.notifications_none),
        actions: [
          CircleAvatar(
            child: profileImageUrl != null
                ? Image.network(profileImageUrl!)
                : const Icon(Icons.person),
          ),
        ],
        title: const Text('Votify'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: TextField(
                controller: districtController,
                decoration: InputDecoration(
                  labelText: "Enter District Name",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: searchDistrict,
                  ),
                ),
              ),
            ),
            SizedBox(height: 22.h),
            if (mnaWinnerName != null && mpaWinnerName != null)
              Column(
                children: [
                  Text(
                    "Winners",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text("MNA Winner: $mnaWinnerName",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  Text("MPA Winner: $mpaWinnerName",
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                ],
              )
            else
              Padding(
                padding: REdgeInsets.symmetric(horizontal: 8.0),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "District result",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Provisional result",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(8.0),
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
              child: Column(children: [
                LayoutBuilder(builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: constraints.maxWidth * 0.6,
                        child: _buildDropdown(
                          label: '',
                          value: _selectedRole,
                          items: roles,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      // SizedBox(
                      //   width: 5.w,
                      // ),

                      // Dropdown for Province
                      Container(
                        width: constraints.maxWidth * 0.3,
                        child: _buildDropdown(
                          label: '',
                          value: _selectedProvince,
                          items: provinces,
                          onChanged: (value) {
                            setState(() {
                              _selectedProvince = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }),
                FutureBuilder<Map<String, int>>(
                  future: _fetchProvinceVotes(_selectedRole, _selectedProvince),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text('Error fetching votes');
                    }
                    if (snapshot.data!.isEmpty) {
                      return const Text('No one got a vote in this province.');
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: [
                          // Display the color containers for province results
                          differentColorContainers(
                              snapshot.data!), // Reuse the same method
                          const SizedBox(
                              width: 16), // Add spacing between widgets

                          // Display the province pie chart
                          Expanded(
                            child: _buildPieChartProvince(
                                'Province Results', snapshot.data!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]),
            ),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 8.0),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overall Pakistan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: FutureBuilder<Map<String, int>>(
                future: _fetchOverallPakistanVotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Error fetching overall Pakistan votes');
                  }
                  if (snapshot.data!.isEmpty) {
                    return const Text('No votes found across Pakistan.');
                  }
                  return _buildPieChartPakistan(
                      'Overall Pakistan Results', snapshot.data!);
                },
              ),
            ),
          ],
        ),
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

  Widget _buildPieChartPakistan(String title, Map<String, int> votes) {
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
                        centerSpaceRadius: 50.r,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(),
    );
  }

  Widget _buildPieChartProvince(String title, Map<String, int> votes) {
    final totalVotes = votes.values.fold(0, (a, b) => a + b);

    return Container(
      height: 200,
      width: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40.r,
          sections: votes.entries.map((entry) {
            final percentage = (entry.value / totalVotes) * 100;
            final partyName = extractPartyNameFromBrackets(entry.key);
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
