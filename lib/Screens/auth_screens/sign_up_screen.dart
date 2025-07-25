// 7. Localized Sign Up Screen
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/Screens/auth_screens/addtional_info_screen.dart';
import 'package:vote_tracker/constants.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/providers/localization_provider.dart';
import 'package:vote_tracker/reusable_widgets/language_toggle.dart';
import 'package:vote_tracker/reusable_widgets/my_button.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';
import 'package:vote_tracker/util/app_localizations.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController cnicController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    cnicController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    cnicController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final passwordProvider = Provider.of<ShowPassword>(context, listen: true);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context);

    bool confirmPasswordHideIfPasswordHide = passwordProvider.isObsecureText;

    return Scaffold(
      appBar: AppBar(
        actions: const [
          LanguageToggle(),
        ],
      ),
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
                        localizations.createNewAccount.toUpperCase(),
                        style: TextStyle(
                            fontSize: 16.sp,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(18)),
                  MyTextFormField(
                    controller: cnicController,
                    hintText: localizations.enterCnicHint,
                    labelText: localizations.cnicNumber,
                    maxLength: 13,
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
                    labelText: localizations.confirmPassword,
                    prefixIcon: Icons.password,
                    hideText: confirmPasswordHideIfPasswordHide,
                    validator: (String? value) {
                      if (confirmPasswordController.text.isEmpty) {
                        return localizations.pleaseConfirmPassword;
                      }

                      if (confirmPasswordController.text !=
                          passwordController.text) {
                        confirmPasswordController.clear();
                        return localizations.passwordsDoNotMatch;
                      }
                      return null;
                    },
                    controller: confirmPasswordController,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(48)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          localizations.alreadyHaveAccount,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0x58585880),
                          ),
                        ),
                      ),
                      isLoading
                          ? Center(
                              child: SpinKitCircle(
                                color: darkGreenColor,
                              ),
                            )
                          : MyButton(
                              buttonText: localizations.signUp,
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
    final localizations = AppLocalizations.of(context);

    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        await authService.createUserWithEmailAndPassword(
          email: "${cnicController.text.trim()}@votify.pk",
          password: passwordController.text.toString().trim(),
        );

        setState(() {
          isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdditionalInformationScreen(),
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
