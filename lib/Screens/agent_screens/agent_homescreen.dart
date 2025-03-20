import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/reusable_widgets/date_of_birth_form_field.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class VoteThroughAgentUser extends StatefulWidget {
  const VoteThroughAgentUser({super.key});

  @override
  State<VoteThroughAgentUser> createState() => _VoteThroughAgentUserState();
}

class _VoteThroughAgentUserState extends State<VoteThroughAgentUser> {
  File? profileImage;
  String? selectedProvince;
  String? selectedDistrict;
  bool isLoading = false;

  late TextEditingController nameController;
  late TextEditingController numberController;
  late TextEditingController cnicController;
  late TextEditingController dateOfBirthController;
  late String fullNumber;

  @override
  void initState() {
    nameController = TextEditingController();
    numberController = TextEditingController();
    cnicController = TextEditingController();
    dateOfBirthController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    numberController.dispose();
    nameController.dispose();
    cnicController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  String? provinceAndCountry;
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context);

    if (selectedProvince != null) {
      provinceAndCountry = ",$selectedProvince,Pakistan";
    } else {
      provinceAndCountry = ",Unknown Province, Pakistan"; // Provide a default
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Vote Through Agent!"),
        actions: [
          IconButton(
            onPressed: () {
              CandidateServices().signOut(context);
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: REdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() {});
                      profileImage = await authService.captureProfileImage();
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        profileImage == null
                            ? SizedBox(
                                height: 120,
                                width: 120,
                                child: CircleAvatar(
                                  radius: 40.r,
                                  backgroundImage:
                                      const AssetImage("assets/nopic.png"),
                                ),
                              )
                            : SizedBox(
                                height: 120,
                                width: 120,
                                child: CircleAvatar(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.amberAccent,
                                  radius: 40.r,
                                  child: ClipOval(
                                    child: Image.file(
                                      profileImage!,
                                      width: MediaQuery.of(context).size.width *
                                          0.9.w,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                        CircleAvatar(
                          radius: 15.r,
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MyTextFormField(
                    controller: nameController,
                    hintText: "Enter your full name",
                    prefixIcon: Icons.person,
                    labelText: "Full Name",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Name cannot be null";
                      }
                      return null;
                    },
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
                    hintText: "Enter your CNIC number without '-'",
                    prefixIcon: Icons.perm_identity,
                    onChanged: (value) {
                      String formattedValue =
                          value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (formattedValue.length > 5) {
                        formattedValue = formattedValue.substring(0, 5) +
                            '-' +
                            formattedValue.substring(5, formattedValue.length);
                      }
                      if (formattedValue.length > 13) {
                        formattedValue = formattedValue.substring(0, 13) +
                            '-' +
                            formattedValue.substring(13, formattedValue.length);
                      }
                      cnicController.value = cnicController.value.copyWith(
                        text: formattedValue,
                        selection: TextSelection.collapsed(
                            offset: formattedValue.length),
                      );
                      return "";
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 13.0),
                      child: DropdownButtonFormField<String>(
                        focusColor: const Color(0xff2D8BBA),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),
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
                                null; // Reset district when province changes
                          });
                        },
                        items: provinceDistricts.keys
                            .map<DropdownMenuItem<String>>((String value) {
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
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 13.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15))),
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
                                .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  alignment: Alignment.center,
                                  child: Text(value),
                                );
                              }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a district';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  DateOfBirthFormField(
                    controller: dateOfBirthController,
                    validator: (value) {
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 48.h,
                  ),
                  isLoading
                      ? SpinKitCircle(
                          color: darkGreenColor,
                        )
                      : MyButton(
                          buttonText: "Vote!",
                          buttonFunction: () async {
                            if (_formKey.currentState!.validate()) {
                              fullNumber = countryCode + numberController.text;
                              String fullAddress =
                                  selectedDistrict! + provinceAndCountry!;
                              log(fullNumber +
                                  cnicController.text +
                                  fullAddress);
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
