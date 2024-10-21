import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vote_tracker/firebase_options.dart';
import 'package:vote_tracker/providers/password_provider.dart';
import 'package:vote_tracker/services/auth_services/auth_gate.dart';
import 'package:vote_tracker/services/auth_services/auth_service.dart';
import 'package:vote_tracker/services/candidate_services/candidate_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShowPassword()),
        ChangeNotifierProvider(create: (context) => AuthServices()),
        ChangeNotifierProvider(create: (context) => CandidateServices())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
      designSize: Size(
          MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height),
    );
  }
}
