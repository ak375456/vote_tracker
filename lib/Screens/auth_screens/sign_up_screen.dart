import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/auth_screens/addtional_info_screen.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // final authservice = Provider.of<AuthServices>(context, listen: false);
    final passwordProvider = Provider.of<ShowPassword>(context, listen: true);
    bool confirmPasswordHideIfPasswordHide = passwordProvider.isObsecureText;
    return Scaffold(
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/votify.png"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        createNewAccount.toUpperCase(),
                        style: TextStyle(
                            fontSize: 16.sp,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(18),
                  ),
                  MyTextFormField(
                    controller: emailController,
                    hintText: emailHelperText,
                    labelText: email,
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
                  MyTextFormField(
                    labelText: "Confirm password",
                    prefixIcon: Icons.password,
                    hideText: confirmPasswordHideIfPasswordHide,
                    validator: (String? value) {
                      if (confirmPasswordController.text.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (confirmPasswordController.text !=
                          passwordController.text) {
                        confirmPasswordController.clear();
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    controller: confirmPasswordController,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(48),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0x58585880),
                          ),
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
                              buttonText: signUp,
                              buttonFunction: singUpFunction),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void singUpFunction() async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    setState(() {
      isLoading = true; // Set isLoading to true to show loading indicator
    });
    if (_formKey.currentState!.validate()) {
      // Perform signup process
      try {
        await authService.createUserWithEmailAndPassword(
          email: emailController.text.toString().trim(),
          password: passwordController.text.toString().trim(),
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
            builder: (context) => const AdditionalInformationScreen(),
          ),
        );
      } catch (e) {
        // Handle signup errors
        setState(() {
          isLoading = false; // Set isLoading to false to hide loading indicator
        });
        // Handle error, you can display an error message or perform other actions
      }
    } else {
      // If form validation fails, keep isLoading as true to keep showing loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

//   void signup() async {
//     final authservice = Provider.of<AuthServices>(context, listen: false);
//     try {
//       await authservice.createUserWithEmailAndPassword(
//           email: emailController.text.toString().trim(),
//           password: passwordController.text.toString().trim());
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const HomeScreen(),
//         ),
//       );
//     } catch (e) {
//       log();
//     }
//   }
// }
}
