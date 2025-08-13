// lib/screens/signup_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<authProvider>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('AI Fashioned')),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.person_crop_circle_badge_plus, size: 96),
                const SizedBox(height: 24),
                const Text('Welcome', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to sync your wardrobe and style.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 32),

                // Native-looking Apple button from package
                SignInWithAppleButton(
                  onPressed: () async {
                    await auth.signInWithApple();
                    // AuthGate will route automatically
                  },
                  style: SignInWithAppleButtonStyle.black,
                  height: 48,
                ),
                const SizedBox(height: 12),

                // Simple Google button (replace with your branded asset if desired)
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () async {
                    await auth.signInWithGoogle();
                    // AuthGate will route automatically
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.person_alt_circle, size: 20, color: CupertinoColors.black),
                      SizedBox(width: 10),
                      Text('Continue with Google',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CupertinoColors.black)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'We only use your email to create your account.\nYou can delete your data anytime.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
