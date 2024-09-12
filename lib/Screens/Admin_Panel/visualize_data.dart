import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vote_tracker/constants.dart';

class VisualizeData extends StatefulWidget {
  const VisualizeData({super.key});

  @override
  State<VisualizeData> createState() => _VisualizeDataState();
}

class _VisualizeDataState extends State<VisualizeData> {
  Future<Map<String, double>> fetchCandidatesPerProvince() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Candidates').get();
    Map<String, int> provinceCount = {};

    for (var doc in snapshot.docs) {
      String province = doc['province'];
      if (provinceCount.containsKey(province)) {
        provinceCount[province] = provinceCount[province]! + 1;
      } else {
        provinceCount[province] = 1;
      }
    }

    // Convert the provinceCount map to a map with double values for PieChart
    return provinceCount.map((key, value) => MapEntry(key, value.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Visualization"),
      ),
      body: Center(
        child: FutureBuilder<Map<String, double>>(
          future: fetchCandidatesPerProvince(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitChasingDots(
                color: darkGreenColor,
              );
            }
            if (snapshot.hasError) {
              return const Text('Error loading chart data');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No data available for chart');
            }
            final dataMap = snapshot.data!;
            final List<Color> colors = [
              Colors.red,
              Colors.blue,
              Colors.green,
              const Color.fromARGB(255, 89, 89, 84),
              Colors.orange,
              Colors.purple,
              Colors.brown,
              Colors.pink,
            ];

            // Define the maximum possible value (100) for normalization
            const double maxCount = 100;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Candidates/Province",
                    style: TextStyle(fontSize: 32.sp),
                  ),
                  SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: PieChart(
                      PieChartData(
                        sections: dataMap.entries.map((entry) {
                          final province = entry.key;
                          final count = entry.value;
                          final colorIndex =
                              dataMap.keys.toList().indexOf(province) %
                                  colors.length;
                          return PieChartSectionData(
                            color: colors[colorIndex],
                            value: count,
                            title: count > 5
                                ? '$province\n${count.toInt()}'
                                : '${province.substring(0, 2)}\n${count.toInt()}', // Abbreviate if the value is high
                            radius: 100,
                            titleStyle: TextStyle(
                              fontSize: count > 5 ? 10 : 12, // Adjust font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: dataMap.entries.map((entry) {
                        final province = entry.key;
                        final count = entry.value;
                        final colorIndex =
                            dataMap.keys.toList().indexOf(province) %
                                colors.length;
                        final progress = count / maxCount;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  province,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.r)),
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  color: colors[colorIndex],
                                  minHeight: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${count.toInt()}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
