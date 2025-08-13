import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white, // iOS clean white background
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Icon(
                CupertinoIcons.sparkles, // Replace with your logo image if needed
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 20),

              // App Name
              const Text(
                "StyleSync",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 10),

              // Subtext (optional)
              const Text(
                "Your style, perfectly synced.",
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),

              const SizedBox(height: 30),

              // Loading Indicator
              const CupertinoActivityIndicator(radius: 14),
            ],
          ),
        ),
      ),
    );
  }
}
