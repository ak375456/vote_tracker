import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class EditCandidateInfo extends StatefulWidget {
  final String candidateId; // Add this to identify the candidate

  const EditCandidateInfo({super.key, required this.candidateId});

  @override
  State<EditCandidateInfo> createState() => _EditCandidateInfoState();
}

class _EditCandidateInfoState extends State<EditCandidateInfo> {
  File? profileImage;
  String? selectedProvince;
  String? selectedDistrict;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController numberController;
  late TextEditingController cnicController;

  late TextEditingController dateOfBirthController;
  late TextEditingController websiteController;
  late TextEditingController twitterController;
  late TextEditingController occupationController;
  late TextEditingController currentAddressController;

  String? fullAddress;
  String? partyAffiliation;
  String? party;
  String? candidateRole;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();

    idController = TextEditingController();

    ageController = TextEditingController();

    genderController = TextEditingController();

    numberController = TextEditingController();

    cnicController = TextEditingController();

    websiteController = TextEditingController();

    twitterController = TextEditingController();

    occupationController = TextEditingController();

    currentAddressController = TextEditingController();

    _fetchCandidateData();
  }

  @override
  void dispose() {
    nameController.dispose();

    idController.dispose();

    ageController.dispose();

    genderController.dispose();

    numberController.dispose();

    cnicController.dispose();

    websiteController.dispose();

    twitterController.dispose();

    occupationController.dispose();

    currentAddressController.dispose();

    super.dispose();
  }

  Future<void> _fetchCandidateData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Candidates')
          .doc(widget.candidateId)
          .get();

      var data = doc.data() as Map<String, dynamic>;
      String name = data['fullName'] ?? 'empty';
      String id = data['uid'] ?? 'empty';
      int age = data['age'] ?? 'empty';
      String gender = data['gender'] ?? "empty";
      String number = data['number'].toString().substring(3);
      String cnic = data['cnic'] ?? "empty";
      String province = data['province'] ?? "empty";
      String district = data['district'] ?? "empty";
      String website = data['website'] ?? 'empty';
      String twitter = data['twitter'] ?? "twitter";
      String occupation = data['occupation'] ?? "empty";
      String partyAffiliation1 = data['partyAffiliation'] ?? "empty";
      String party1 = data['party'] ?? "empty";
      String imageURL = data['image'] ?? "empty";
      String candidateRole1 = data['candidateRole'] ?? "empty";
      setState(() {
        nameController.text = name;
        idController.text = id;
        ageController.text = age.toString();
        genderController.text = gender;
        cnicController.text = cnic;
        numberController.text = number;
        selectedProvince = province;
        selectedDistrict = district;
        websiteController.text = website;
        twitterController.text = twitter;
        occupationController.text = occupation;
        partyAffiliation = partyAffiliation1;
        party = party1;
        imageUrl = imageURL;
        candidateRole = candidateRole1;
      });
    } catch (error) {
      print("Error fetching candidate data: $error");
    }
  }

  Future<void> _updateCandidateData() async {
    // Ensure changes are made
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Candidates')
          .doc(widget.candidateId)
          .update({
        'fullName': nameController.text,
        'uid': idController.text,
        'cnic': cnicController.text,
        'number': numberController.text,
        'website': websiteController.text,
        'twitter': twitterController.text,
        'occupation': occupationController.text,
        'partyAffiliation': partyAffiliation,
        'party': party,
        'candidateRole': candidateRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Candidate information updated successfully")),
      );

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print("Error updating candidate data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating candidate data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    log(imageUrl.toString());
    final candidateServices =
        Provider.of<CandidateServices>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Padding(
                    padding: REdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: REdgeInsets.only(top: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Candidate"),
                                SizedBox(
                                  height: 20.h,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    profileImage = await candidateServices
                                        .pickProfileImage();
                                    setState(() {});
                                  },
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: darkGreenColor,
                                        foregroundColor: darkGreenColor,
                                        radius: 40.r,
                                        child: ClipOval(
                                          child: Image.network(
                                            imageUrl.toString(),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9.w,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.9.h,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 15.r,
                                        backgroundColor: darkGreenColor,
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                MyTextFormField(
                                  controller: nameController,
                                  prefixIcon: Icons.person,
                                  hintText: "Enter your full name",
                                  labelText: "Full name",
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Name cannot be empty";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                MyTextFormField(
                                  textInputType: TextInputType.number,
                                  controller: numberController,
                                  hintText: "Enter your number",
                                  prefixIcon: Icons.numbers,
                                  labelText: "Mobile Number",
                                  validator: (value) {
                                    if (value != null &&
                                        !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      return "You cannot enter text here";
                                    }
                                    if (value!.length == 1) {
                                      return "Please enter your number";
                                    }
                                    return null;
                                  },
                                  prefixText: countryCode,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                MyTextFormField(
                                  maxLength: 15,
                                  textInputType: TextInputType.number,
                                  controller: cnicController,
                                  labelText: "CNIC",
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter your cnic number";
                                    }
                                    return null;
                                  },
                                  hintText:
                                      "Enter your CNIC number without '-'",
                                  prefixIcon: Icons.perm_identity,
                                  onChanged: (value) {
                                    // Remove any non-digit characters
                                    String formattedValue =
                                        value.replaceAll(RegExp(r'[^0-9]'), '');

                                    // Insert dashes after 5th and 13th characters
                                    if (formattedValue.length > 5) {
                                      // ignore: prefer_interpolation_to_compose_strings
                                      formattedValue =
                                          formattedValue.substring(0, 5) +
                                              '-' +
                                              formattedValue.substring(
                                                  5, formattedValue.length);
                                    }
                                    if (formattedValue.length > 13) {
                                      // ignore: prefer_interpolation_to_compose_strings
                                      formattedValue =
                                          formattedValue.substring(0, 13) +
                                              '-' +
                                              formattedValue.substring(
                                                  13, formattedValue.length);
                                    }
                                    // Update controller value without triggering onChanged again
                                    cnicController.value =
                                        cnicController.value.copyWith(
                                      text: formattedValue,
                                      selection: TextSelection.collapsed(
                                          offset: formattedValue.length),
                                    );
                                    return "";
                                  },
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: const Text("Province"),
                                    value: selectedProvince,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 0,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedProvince = newValue!;
                                        selectedDistrict =
                                            null; // Reset the district selection
                                      });
                                    },
                                    items: <String>[
                                      'Khyber Pakhtunkhwa',
                                      'Punjab',
                                      'Sindh',
                                      "Balouchistan",
                                      'Azad Kashmir',
                                      'Gilgit Baltistan'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a province';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: const Text("District"),
                                    value: selectedDistrict,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 0,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDistrict = newValue!;
                                      });
                                    },
                                    items: selectedProvince == null
                                        ? []
                                        : provinceDistricts[selectedProvince]!
                                            .map<DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                alignment: Alignment.center,
                                                child: Text(value),
                                              );
                                            },
                                          ).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a district';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                MyTextFormField(
                                  prefixIcon: Icons.link,
                                  controller: websiteController,
                                  labelText: "Website",
                                  hintText:
                                      "Please add your website link (if-any)",
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                MyTextFormField(
                                  prefixIcon: Icons.link,
                                  controller: twitterController,
                                  labelText: "Twitter",
                                  hintText:
                                      "Please add your twitter link (if-any)",
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                MyTextFormField(
                                  prefixIcon: Icons.work,
                                  controller: occupationController,
                                  labelText: "Occupation",
                                  hintText: "Current occupation",
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Occupation cannot be empty";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: const Text("Party Affiliation"),
                                    value: partyAffiliation,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 0,
                                    onChanged: (newValue) {
                                      setState(() {
                                        partyAffiliation = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Independent',
                                      'Dependent',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a party affiliation';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: const Text("Party"),
                                    value: party,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 0,
                                    onChanged: (newValue) {
                                      setState(() {
                                        party = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Pakistan Tehreek-e-Insaf (PTI)',
                                      'Pakistan Muslim League-Nawaz (PML-N)',
                                      'Pakistan Peoples Party (PPP)',
                                      'Muttahida Qaumi Movement (MQM)',
                                      'Awami National Party (ANP)',
                                      'Jamiat Ulema-e-Islam (F)',
                                      'Pakistan Muslim League-Quaid (PML-Q)',
                                      'Tehreek-e-Labbaik Pakistan (TLP)',
                                      'Jamaat-e-Islami (JI)',
                                      'Balochistan Awami Party (BAP)',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a party affiliation';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: const Text("Candidate Role"),
                                    value: candidateRole,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 0,
                                    onChanged: (newValue) {
                                      setState(() {
                                        candidateRole = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Minister Of National Assembly',
                                      'Minister Of Province Assembly',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a candidate Role';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                SizedBox(
                                  height: 80.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Container(
                      height: 80.h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(159, 0, 0, 0),
                            offset: Offset(0, -1),
                            blurRadius: 5,
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          topRight: Radius.circular(8.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: MyButton(
                            buttonText: "Edit",
                            buttonFunction: _updateCandidateData,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
