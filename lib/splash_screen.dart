import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/storage/onboarding_storage.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/onboarding/onboarding_parent.dart';
import 'package:dawak/views/patient/patient_home_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.sessionStorage});

  final AuthSessionStorage? sessionStorage;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateFromSplash();
  }

  Future<void> _navigateFromSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    final sessionStorage =
        widget.sessionStorage ?? SecureAuthSessionStorage();
    final userId = await sessionStorage.readUserId();
    final accessToken = await sessionStorage.readAccessToken();
    final userType = await sessionStorage.readUserType();
    if (!mounted) {
      return;
    }

    if (userId?.isNotEmpty == true &&
        accessToken?.isNotEmpty == true &&
        userType?.isNotEmpty == true) {
      context.pushReplacement(
        userType == 'patient' ? const PatientHomePage() : const LoginScreen(),
      );
      return;
    }

    final hasSeenOnboarding = await OnboardingStorage.hasSeenOnboarding();
    if (!mounted) {
      return;
    }

    context.pushReplacement(
      hasSeenOnboarding ? const LoginScreen() : const OnboardingParent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/icon/logo.png', width: 200, height: 200),
      ),
    );
  }
}
