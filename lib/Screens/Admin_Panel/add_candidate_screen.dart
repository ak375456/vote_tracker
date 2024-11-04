import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vote_tracker/Screens/Admin_Panel/edit_candidate_info.dart';
import 'package:vote_tracker/Screens/Admin_Panel/register_candidate.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  TextEditingController _controller = TextEditingController();
  final CandidateServices _candidateService = CandidateServices();

  Future<List<Map<String, dynamic>>> _fetchAllCandidates() {
    return _candidateService.fetchAllCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Votifiy"),
      ),
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Row(
              children: [
                Flexible(
                  child: MyTextFormField(
                    suffixIcon: Icons.search,
                    controller: _controller,
                    labelText: "Search Candidate",
                    validator: (string) {
                      return null;
                    },
                  ),
                ),
                IconButton.outlined(
                  tooltip: "Add Candidate",
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterCandidate(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: FutureBuilder(
                future: _fetchAllCandidates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No candidates found."));
                  }

                  final candidates = snapshot.data!;
                  return ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      final partyFlagPath =
                          partyFlags[candidate['party']] ?? '';
                      return Slidable(
                        direction: Axis.horizontal,
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                log(candidate['uid']);
                                _candidateService.deleteCandidateAccount(
                                  context,
                                  uid: candidate['uid'],
                                );
                              },
                              icon: FontAwesomeIcons.deleteLeft,
                              backgroundColor: Colors.redAccent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.r)),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditCandidateInfo(),
                              ),
                            );
                          },
                          child: Container(
                            margin: REdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                width: 1.w,
                                color: const Color.fromARGB(120, 0, 0, 0),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: Column(
                              children: [
                                Padding(
                                  padding: REdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            extractTextInBrackets(
                                              candidate['party'],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CircleAvatar(
                                                maxRadius: 25,
                                                backgroundImage: NetworkImage(
                                                  candidate['image'],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.h,
                                              ),
                                              Column(
                                                // crossAxisAlignment:
                                                // CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    candidate['fullName'],
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    candidate['fullAddress']
                                                        .toString()
                                                        .substring(
                                                            0,
                                                            candidate['fullAddress']
                                                                    .toString()
                                                                    .length -
                                                                9),
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color:
                                                            Color(0xff585858)),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(90),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    getInitials(candidate[
                                                        'candidateRole']), //-----------------------------------------------------
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment
                                              .centerRight, // Aligns the image to the right
                                          child: Container(
                                            height: 80
                                                .h, // Set a consistent height for the container
                                            child: Image.asset(
                                              partyFlagPath,
                                              fit: BoxFit
                                                  .contain, // Keeps image proportions consistent within height
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
String extractTextInBrackets(String text) {
  final RegExp regex = RegExp(r'\(([^)]+)\)');
  final match = regex.firstMatch(text);
  return match != null ? match.group(1) ?? '' : '';
}

String getInitials(String text) {
  return text
      .split(' ')
      .where((word) => word.toLowerCase() != 'of')
      .map((word) => word[0].toUpperCase())
      .join('');
}
