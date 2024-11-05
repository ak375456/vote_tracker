import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';

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

  late TextEditingController nameController;
  late TextEditingController numberController;
  late TextEditingController cnicController;
  late TextEditingController dateOfBirthController;
  late TextEditingController genderController;

  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    numberController = TextEditingController();
    cnicController = TextEditingController();
    dateOfBirthController = TextEditingController();
    genderController = TextEditingController();
    _fetchCandidateData();
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    cnicController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    super.dispose();
  }

  Future<void> _fetchCandidateData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Candidates')
          .doc(widget.candidateId)
          .get();

      var data = doc.data() as Map<String, dynamic>;
      nameController.text = data['fullName'] ?? '';
      numberController.text = data['number'] ?? '';
      cnicController.text = data['cnic'] ?? '';

      // Convert the Firestore Timestamp to DateTime
      final Timestamp? dobTimestamp = data['dateOfBirth'];
      if (dobTimestamp != null) {
        DateTime dob = dobTimestamp.toDate();
        dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(dob);
      } else {
        dateOfBirthController.text = '';
      }

      genderController.text = data['gender'] ?? 'empty';

      // Track if any changes are made to the text fields
      nameController.addListener(_checkChanges);
      numberController.addListener(_checkChanges);
      cnicController.addListener(_checkChanges);
      dateOfBirthController.addListener(_checkChanges);
      genderController.addListener(_checkChanges);
    } catch (error) {
      print("Error fetching candidate data: $error");
    }
  }

  void _checkChanges() {
    setState(() {
      _hasChanges = true;
    });
  }

  Future<void> _updateCandidateData() async {
    if (_formKey.currentState!.validate() && _hasChanges) {
      setState(() {
        isLoading = true;
      });

      try {
        // Convert date string back to Timestamp
        DateTime dob =
            DateFormat('yyyy-MM-dd').parse(dateOfBirthController.text);
        Timestamp dobTimestamp = Timestamp.fromDate(dob);

        await FirebaseFirestore.instance
            .collection('Candidates')
            .doc(widget.candidateId)
            .update({
          'fullName': nameController.text,
          'number': numberController.text,
          'cnic': cnicController.text,
          'dateOfBirth': dobTimestamp,
          'gender': genderController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Candidate information updated successfully")),
        );
        setState(() {
          isLoading = false;
          _hasChanges = false;
        });
      } catch (error) {
        print("Error updating candidate data: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating candidate data")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing changed here")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("CANDIDATE DETAILS"),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            InkWell(
                              onTap: () {
                                // Optionally add image picker functionality here
                              },
                              child: SizedBox(
                                height: 150.h,
                                width: 150.h,
                                child: profileImage == null
                                    ? const Image(
                                        image: AssetImage("assets/nopic.png"),
                                      )
                                    : Image.file(profileImage!),
                              ),
                            ),
                            Container(
                              margin: REdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 2.w),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.r),
                                ),
                              ),
                              child: const Icon(Icons.camera_alt),
                            ),
                          ],
                        ),
                        MyTextFormField(
                          labelText: "Name",
                          controller: nameController,
                          validator: (String? value) {
                            return null;
                          },
                        ),
                        MyTextFormField(
                          labelText: "Phone Number",
                          controller: numberController,
                          validator: (String? value) {
                            return null;
                          },
                        ),
                        MyTextFormField(
                          labelText: "CNIC",
                          controller: cnicController,
                          validator: (String? value) {
                            return null;
                          },
                        ),
                        MyTextFormField(
                          labelText: "Date of Birth",
                          controller: dateOfBirthController,
                          validator: (String? value) {
                            return null;
                          },
                        ),
                        MyTextFormField(
                          labelText: "Gender",
                          validator: (String? value) {
                            return null;
                          },
                          controller: genderController,
                        ),
                      ],
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
      ),
    );
  }
}
