// lib/screens/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../SplashWrapper.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_services.dart';
import 'HomePage.dart';
import 'SignUp.dart';
import 'onboarding/onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<authProvider>();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SplashWrapper();
        }
        final user = snap.data;
        if (user == null) {
          return const SignupScreen();
        }

        // One-shot check to decide routing immediately
        final db = RealtimeDbService();
        return FutureBuilder<bool>(
          future: db.isOnboarded(user.uid),
          builder: (context, fs) {
            if (fs.connectionState == ConnectionState.waiting) {
              return const SplashWrapper();
            }
            if (fs.hasError) {
              // If we can’t read profile (rules/offline), be generous: let user onboard.
              return const OnboardingScreen();
            }
            final onboarded = fs.data == true;
            if (!onboarded) {
              return const OnboardingScreen();
            }

            // Once onboarded, you can optionally switch to a stream to live-update the profile:
            return StreamBuilder<AppUser?>(
              stream: db.userStream(user.uid),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const SplashWrapper();
                }
                // If the doc disappears or flag flips off later, fall back to onboarding.
                final profile = userSnap.data;
                if (profile == null || profile.onboardingComplete == false) {
                  return const OnboardingScreen();
                }
                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}
