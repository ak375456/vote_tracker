import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/Admin_Panel/admin_screen_bottom_nav_holder.dart';
import 'package:vote_tracker/Screens/auth_screens/sign_up_screen.dart';
import 'package:vote_tracker/Screens/agent_screens/agent_login.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/bottom_nav_bar_helper.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/providers/localization_provider.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/reusable_widgets/language_toggle.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';
import 'package:vote_tracker/util/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
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
    final passwordProvider = Provider.of<ShowPassword>(context, listen: true);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          const LanguageToggle(),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: REdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Language Toggle at the top

                  SizedBox(height: 20.h),

                  Image.asset("assets/votify.png"),
                  SizedBox(height: 45.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Text(
                                localizations.signInVoter,
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const Divider(
                              thickness: 5,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CandidateLoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          localizations.signInAgent,
                          style: TextStyle(
                            fontSize: 20.sp,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  MyTextFormField(
                    controller: emailController,
                    labelText: localizations.cnicNumber,
                    hintText: localizations.enterCnicHint,
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations.pleaseEnterCnic;
                      }
                      return null;
                    },
                    prefixIcon: Icons.badge,
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

                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ));
                        },
                        child: Text(
                          localizations.dontHaveAccount,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0x58585880),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void logInFunction() async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final String cnicAsEmail = "${emailController.text.trim()}@votify.pk";
        print("email $cnicAsEmail");
        await authService.signInWithEmailAndPassword(
          cnicAsEmail,
          passwordController.text.toString().trim(),
        );

        setState(() {
          isLoading = false;
        });

        if (!emailController.text.toString().contains("admin")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavBarOfApp(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavBarOfAdmin(),
            ),
          );
        }
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
