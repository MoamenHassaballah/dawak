import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/views/onboarding/onboarding_parent.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      context.pushReplacement(const OnboardingParent());
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/icon/logo.png', width: 200, height: 200),
      ),
    );
  }
}
