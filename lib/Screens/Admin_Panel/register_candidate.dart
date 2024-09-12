import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/reusable_widgets/date_of_birth_form_field.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/reusable_widgets/two_circles.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class RegisterCandidate extends StatefulWidget {
  const RegisterCandidate({super.key});

  @override
  State<RegisterCandidate> createState() => _RegisterCandidateState();
}

class _RegisterCandidateState extends State<RegisterCandidate> {
  File? profileImage;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController emaillController;
  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController dateOfBirthController;
  late TextEditingController websiteController;
  late TextEditingController twitterController;
  late TextEditingController occupationController;
  late TextEditingController numberController;
  late TextEditingController cnicController;
  late TextEditingController currentAddressController;
  String? selectedProvince;
  String? fullAddress;
  String? partyAffiliation;
  String? party;
  String? candidateRole;
  String? selectedDistrict;
  @override
  void initState() {
    emaillController = TextEditingController();
    nameController = TextEditingController();
    passwordController = TextEditingController();
    dateOfBirthController = TextEditingController();
    websiteController = TextEditingController();
    twitterController = TextEditingController();
    occupationController = TextEditingController();
    numberController = TextEditingController();
    cnicController = TextEditingController();
    currentAddressController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emaillController.dispose();
    nameController.dispose();
    passwordController.dispose();
    dateOfBirthController.dispose();
    websiteController.dispose();
    twitterController.dispose();
    occupationController.dispose();
    numberController.dispose();
    cnicController.dispose();
    currentAddressController.dispose();
    super.dispose();
  }

  bool isMaleSelected = false;
  bool isFemaleSelected = false;
  bool isLoading = false;
  String? provinceAndCountry;
  @override
  Widget build(BuildContext context) {
    final candidateServices =
        Provider.of<CandidateServices>(context, listen: false);
    final passwordProvider = Provider.of<ShowPassword>(context, listen: false);

    if (selectedProvince != null) {
      provinceAndCountry = ",$selectedProvince,Pakistan";
    } else {
      provinceAndCountry = ",Unknown Province, Pakistan"; // Provide a default
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const TwoCircles(),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            profileImage =
                                await candidateServices.pickProfileImage();
                            setState(() {});
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              profileImage == null
                                  ? CircleAvatar(
                                      radius: 40.r,
                                      backgroundImage:
                                          const AssetImage("assets/nopic.png"),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: darkGreenColor,
                                      foregroundColor: darkGreenColor,
                                      radius: 40.r,
                                      child: ClipOval(
                                        child: Image.file(
                                          profileImage!,
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
                        MyTextFormField(
                          controller: emaillController,
                          hintText: emailHelperText,
                          labelText: email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          prefixIcon: Icons.email,
                        ),
                        MyTextFormField(
                          controller: passwordController,
                          labelText: password,
                          hintText: passwordHelperText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 5) {
                              return 'Password should be greater than 5 character';
                            }
                            return null;
                          },
                          prefixIcon: Icons.password_outlined,
                          suffixIcon: passwordProvider.isObsecureText
                              ? Icons.lock
                              : Icons.lock_open_outlined,
                          onSuffixIconPressed: () {
                            passwordProvider
                                .showPassword(!passwordProvider.isObsecureText);
                          },
                          hideText: passwordProvider.isObsecureText,
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
                            // Remove any non-digit characters
                            String formattedValue =
                                value.replaceAll(RegExp(r'[^0-9]'), '');

                            // Insert dashes after 5th and 13th characters
                            if (formattedValue.length > 5) {
                              // ignore: prefer_interpolation_to_compose_strings
                              formattedValue = formattedValue.substring(0, 5) +
                                  '-' +
                                  formattedValue.substring(
                                      5, formattedValue.length);
                            }
                            if (formattedValue.length > 13) {
                              // ignore: prefer_interpolation_to_compose_strings
                              formattedValue = formattedValue.substring(0, 13) +
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
                        DateOfBirthFormField(
                          controller: dateOfBirthController,
                          validator: (value) {
                            return null;
                          },
                        ),
                        CheckboxListTile(
                          activeColor: darkGreenColor,
                          title: const Text('Male'),
                          value: isMaleSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              isMaleSelected = value!;
                              if (isMaleSelected) {
                                isFemaleSelected = false;
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          activeColor: darkGreenColor,
                          title: const Text('Female'),
                          value: isFemaleSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              isFemaleSelected = value!;
                              if (isFemaleSelected) {
                                isMaleSelected = false;
                              }
                            });
                          },
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
                              });
                            },
                            items: <String>[
                              'Khyber Pakhtunkhwa',
                              'Punjab',
                              'Sindh',
                              "Balouchistan",
                              'Azad Kashmir',
                              'Gilgit Baltistan'
                            ].map<DropdownMenuItem<String>>((String value) {
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
                                  }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a district';
                              }
                              return null;
                            },
                          ),
                        ),
                        MyTextFormField(
                          prefixIcon: Icons.link,
                          controller: websiteController,
                          labelText: "Website",
                          hintText: "Please add your website link (if-any)",
                          validator: (value) {
                            return null;
                          },
                        ),
                        MyTextFormField(
                          prefixIcon: Icons.link,
                          controller: twitterController,
                          labelText: "Twitter",
                          hintText: "Please add your twitter link (if-any)",
                          validator: (value) {
                            return null;
                          },
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
                            ].map<DropdownMenuItem<String>>((String value) {
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
                            ].map<DropdownMenuItem<String>>((String value) {
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
                            ].map<DropdownMenuItem<String>>((String value) {
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
                        isLoading
                            ? Center(
                                child: SpinKitCircle(
                                  // Using a CircularProgressIndicator for loading indication
                                  color: darkGreenColor,
                                ),
                              )
                            : MyButton(
                                buttonText: "Register Candidate",
                                buttonFunction: () async {
                                  if (_formKey.currentState!.validate()) {
                                    log("btnFunc");
                                    registerCandidate();
                                  }
                                },
                              ),
                      ],
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

  registerCandidate() async {
    log("register candidate");
    final candidateServices =
        Provider.of<CandidateServices>(context, listen: false);
    setState(() {
      isLoading = true; // Set loading state to true
    });
    try {
      log("try of register candidate");
      if (dateOfBirthController.text.isNotEmpty) {
        log("if DOB of register candidate");
        Timestamp dateOfBirthTimestamp = Timestamp.fromDate(
          DateTime.parse(dateOfBirthController.text),
        );
        await candidateServices.storeDataOfCandidateOnFirestore(
          email: emaillController.text.toString().trim(),
          password: passwordController.text.toString().trim(),
          fullName: nameController.text.toString().trim(),
          dateOfBirth: dateOfBirthTimestamp,
          image: profileImage,
          gender: isMaleSelected ? 'Male' : 'Female',
          cnic: cnicController.text.toString().trim(),
          fullAddress: selectedDistrict! + provinceAndCountry!,
          number: countryCode + numberController.text.toString().trim(),
          occupation: occupationController.text.toString().trim(),
          party: party,
          partyAffiliation: partyAffiliation,
          province: selectedProvince,
          twitter: twitterController.text.toString().trim(),
          website: websiteController.text.toString().trim(),
          candidateRole: candidateRole.toString(),
          district: selectedDistrict!,
        );
      }
      setState(() {
        isLoading = false; // Set loading state to false
      });
      Fluttertoast.showToast(msg: "Candidate has been resgistered");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }
}
