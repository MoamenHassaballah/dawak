import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientMyAccountPage extends StatefulWidget {
  const PatientMyAccountPage({super.key, this.sessionStorage});

  final AuthSessionStorage? sessionStorage;

  @override
  State<PatientMyAccountPage> createState() => _PatientMyAccountPageState();
}

class _PatientMyAccountPageState extends State<PatientMyAccountPage> {
  late final AuthSessionStorage _sessionStorage;
  late final Future<String?> _firstName;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _sessionStorage = widget.sessionStorage ?? SecureAuthSessionStorage();
    _firstName = _sessionStorage.readFirstName();
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _sessionStorage.clearSession();
    } on PlatformException {
      if (!mounted) {
        return;
      }
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('signOutFailed'))),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    context.pushAndRemoveUntil(const LoginScreen(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('myAccount'),
            textAlign: TextAlign.start,
            style: AppTextConstants.headingStyle(
              context,
            ).copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.decoration,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<String?>(
                  future: _firstName,
                  builder: (context, snapshot) {
                    final firstName = snapshot.data?.trim();
                    final name = snapshot.hasError
                        ? context.tr('accountNameLoadError')
                        : firstName?.isNotEmpty == true
                        ? firstName!
                        : context.tr('patientAccount');
                    return Text(
                      name,
                      textAlign: TextAlign.center,
                      style: AppTextConstants.subheadingStyle(
                        context,
                      ).copyWith(color: AppColors.primary),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout),
            label: Text(context.tr('signOut')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: AppTextConstants.subheadingStyle(
                context,
              ).copyWith(fontSize: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
