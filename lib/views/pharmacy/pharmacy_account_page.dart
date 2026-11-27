import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PharmacyAccountPage extends StatefulWidget {
  const PharmacyAccountPage({super.key, this.sessionStorage});

  final AuthSessionStorage? sessionStorage;

  @override
  State<StatefulWidget> createState() => _PharmacyAccountPage();
}

class _PharmacyAccountPage extends State<PharmacyAccountPage> {
  late final AuthSessionStorage _sessionStorage;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _sessionStorage = widget.sessionStorage ?? SecureAuthSessionStorage();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('signOutFailed'))));
      return;
    }

    if (!mounted) {
      return;
    }
    context.pushAndRemoveUntil(const LoginScreen(), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: ElevatedButton(
        onPressed: _isSigningOut ? () {} : _signOut,
        child: AppText(text: "Logout"),
      ),
    );
  }
}
