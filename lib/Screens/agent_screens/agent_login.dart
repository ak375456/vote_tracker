import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/agent_screens/agent_homescreen.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/providers/localization_provider.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/reusable_widgets/language_toggle.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';
import 'package:vote_tracker/util/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        actions: const [LanguageToggle()],
      ),
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/votify.png"),
              SizedBox(height: 45.h),
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
                            localizations.signInVoter,
                            style: TextStyle(
                              fontSize: 20.sp,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w400,
                            ),
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
                            localizations.signInAgent,
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
                labelText: localizations.email,
                hintText: localizations.emailHelperText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterEmail;
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                      .hasMatch(value)) {
                    return localizations.enterValidEmail;
                  }
                  return null;
                },
                prefixIcon: Icons.email,
              ),
              MyTextFormField(
                controller: passwordController,
                labelText: localizations.password,
                hintText: localizations.passwordHelperText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.pleaseEnterPassword;
                  }
                  if (value.length < 5) {
                    return localizations.passwordLengthValidation;
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
              SizedBox(height: ScreenUtil().setHeight(48)),
              isLoading
                  ? Center(
                      child: SpinKitCircle(
                        color: darkGreenColor,
                      ),
                    )
                  : MyButton(
                      buttonText: localizations.signIn,
                      buttonFunction: logInFunction,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void logInFunction() async {
    final candidateServices = Provider.of<CandidateServices>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    setState(() {
      isLoading = true;
    });
    
    if (_formKey.currentState!.validate()) {
      try {
        await candidateServices.signInWithEmailAndPassword(
          emailController.text.toString().trim(),
          passwordController.text.toString().trim(),
        );
        
        setState(() {
          isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VoteThroughAgentUser(),
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('${localizations.signupFailed}: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}