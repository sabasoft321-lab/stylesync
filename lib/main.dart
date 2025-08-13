import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylesync/providers/ProfileProvider.dart';
import 'package:stylesync/providers/auth_provider.dart';
import 'package:stylesync/providers/onboarding_provider.dart';

import 'Screens/auth_gate.dart';

import 'SplashWrapper.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: SplashWrapper(),
      ),
    );


  }
}
