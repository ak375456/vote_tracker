import 'dart:developer';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CandidateInfo extends StatelessWidget {
  CandidateInfo(
      {super.key,
      required this.uid,
      required this.name,
      required this.age,
      required this.cnic,
      required this.fullAddress,
      required this.gender,
      this.image,
      required this.isCandidate,
      required this.number,
      required this.occupation,
      required this.party,
      required this.partyAffiliation,
      required this.province,
      this.twitter,
      this.website});
  String uid;
  String name;
  int age;
  String cnic;
  String fullAddress;
  String gender;
  String? image;
  bool isCandidate;
  String number;
  String occupation;
  String party;
  String partyAffiliation;
  String province;
  String? twitter;
  String? website;

  @override
  Widget build(BuildContext context) {
    // final candidateServices =
    //     Provider.of<CandidateServices>(context, listen: false);
    log(uid);
    // return FutureBuilder(
    //   future: candidateServices.fetchCandidateData(uid),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(
    //         child: SpinKitCircle(
    //           color: darkGreenColor,
    //         ),
    //       );
    //     }
    //     if (snapshot.hasError) {
    //       return const Center(child: Text('Error fetching data'));
    //     }
    //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
    //       return const Center(child: Text('No candidates data found'));
    //     }
    //     final candidateData = snapshot.data!;
    return Scaffold(
      appBar: AppBar(
        title: Text(name.toUpperCase()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(),
          Text("UID: $uid"),
          Text("Full name: $name"),
          Text("age: $age"),
          Text("Full address: $fullAddress"),
          Text("Gender: $gender"),
          Text("IsCandidate: ${isCandidate ? "Yes" : "No"}"),
          Text("Mobile Number: $number"),
          Text("Occupation:$occupation"),
          Text("Party:$party"),
          Text("Party Affiliation: $partyAffiliation"),
          Text("Province: $province"),
          Text(
              "Twitter: ${twitter!.isNotEmpty ? twitter : "Link not provided"}"),
          Text(
              "Website: ${website!.isNotEmpty ? website : "Link not provided"}"),
        ],
      ),
    );
  }
}
