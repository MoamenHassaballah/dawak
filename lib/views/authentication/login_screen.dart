import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/viewmodels/auth_viewmodel.dart';
import 'package:dawak/views/authentication/signup_account_selection.dart';
import 'package:dawak/views/guest/guest_main_page.dart';
import 'package:dawak/views/patient/patient_home_page.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isSecured = true;

  Future<void> _submitLogin() async {
    final result = await context.read<AuthViewModel>().login(
      email: emailController.text,
      password: passwordController.text,
    );
    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      if (result.response?.userType == 'patient') {
        context.pushAndRemoveUntil(const PatientHomePage(), (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('pharmacyHomeComingSoon'))),
        );
      }
      return;
    }

    final messageKey = switch (result.failure) {
      LoginFailure.connection => 'loginConnectionError',
      LoginFailure.invalidResponse => 'loginInvalidResponse',
      LoginFailure.invalidCredentials => 'loginInvalidCredentials',
      LoginFailure.rateLimited => 'loginRateLimited',
      LoginFailure.storage => 'loginStorageError',
      _ => 'loginFailed',
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('loginErrorTitle')),
        content: Text(context.tr(messageKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('ok')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.background),
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Image.asset(
                    'assets/icon/logo_shadow.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Dawak",
                    style: AppTextConstants.headingStyle(context).copyWith(
                      fontSize: 40,
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                    ),
                    textAlign: .center,
                  ),
                  Text(
                    "دواك",
                    style: AppTextConstants.headingStyle(context).copyWith(
                      fontSize: 40,
                      fontFamily: 'Tajawal',
                      color: AppColors.primary,
                    ),
                    textAlign: .center,
                  ),

                  const SizedBox(height: 40),

                  AppText(
                    text: "welcomeBack",
                    style: AppTextConstants.subheadingStyle(context),
                  ),
                  AppText(text: "loginToContinue", color: AppColors.grey),

                  const SizedBox(height: 24),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      label: AppText(text: "email", color: AppColors.grey),
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.stroke,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: _isSecured,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      label: AppText(text: "password", color: AppColors.grey),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isSecured = !_isSecured;
                          });
                        },
                        icon: Icon(
                          _isSecured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.stroke,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(alignment: .centerEnd),
                    child: AppText(text: "forgotPassword"),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                      backgroundColor: AppColors.primary,
                      fixedSize: Size.fromHeight(50),
                    ),

                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : AppText(
                            text: "login",
                            color: Colors.white,
                            style: AppTextConstants.subheadingStyle(
                              context,
                            ).copyWith(fontSize: 25),
                          ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      AppText(text: "dontHaveAccount"),
                      InkWell(
                        onTap: () {
                          context.push(SignupAccountSelection());
                        },
                        child: AppText(
                          text: "createNewAccount",
                          style: AppTextConstants.bodyStyle(
                            context,
                          ).copyWith(fontWeight: .w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  InkWell(
                    onTap: () {
                      context.pushReplacement(GuestMainPage());
                    },
                    child: AppText(
                      text: "continueAsGuest",
                      style: AppTextConstants.bodyStyle(context).copyWith(
                        fontWeight: .w600,
                        decoration: TextDecoration.underline,
                        decorationThickness: 10,
                        decorationColor: AppColors.accent2,
                      ),
                      color: AppColors.accent2,
                      textAlign: .center,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
