import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/candidate_screens/candidate_homescreen.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

class CandidateLoginScreen extends StatefulWidget {
  const CandidateLoginScreen({super.key});

  @override
  State<CandidateLoginScreen> createState() => _CandidateLoginScreenState();
}

late TextEditingController emailController;
late TextEditingController passwordController;

class _CandidateLoginScreenState extends State<CandidateLoginScreen> {
  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final passwordProvider = Provider.of<ShowPassword>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/votify.png"),
              SizedBox(
                height: 45.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Sign In (Voter)",
                            style: TextStyle(
                                fontSize: 20.sp,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            "Sign In (Candidate)",
                            style: TextStyle(
                              fontSize: 20.sp,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Divider(
                          thickness: 5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              MyTextFormField(
                controller: emailController,
                labelText: email,
                hintText: emailHelperText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
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
              SizedBox(
                height: ScreenUtil().setHeight(48),
              ),
              isLoading
                  ? Center(
                      child: SpinKitCircle(
                        // Using a CircularProgressIndicator for loading indication
                        color: darkGreenColor,
                      ),
                    )
                  : MyButton(
                      buttonText: "Sign In",
                      buttonFunction: logInFunction,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void logInFunction() async {
    final candidateServices =
        Provider.of<CandidateServices>(context, listen: false);
    setState(() {
      isLoading = true; // Set isLoading to true to show loading indicator
    });
    if (_formKey.currentState!.validate()) {
      // Perform signup process
      try {
        await candidateServices.signInWithEmailAndPassword(
          emailController.text.toString().trim(),
          passwordController.text.toString().trim(),
        );
        // If signup successful, isLoading will remain true until this point
        setState(() {
          isLoading = false; // Set isLoading to false to hide loading indicator
        });
        // Optionally, navigate to another screen upon successful signup

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const CandidateHomeScreen(),
          ),
        );
      } catch (e) {
        // Handle signup errors
        setState(() {
          isLoading = false; // Set isLoading to false to hide loading indicator
        });
        // Handle error, you can display an error message or perform other actions
        print('Signup failed: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
