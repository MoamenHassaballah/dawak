import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isSecured = true;

  @override
  Widget build(BuildContext context) {
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
                  Image.asset('assets/icon/logo.png', width: 100, height: 100),
                  const SizedBox(height: 10),
                  Text(
                    "Dawak",
                    style: AppTextConstants.headingStyle.copyWith(
                      fontSize: 40,
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                    ),
                    textAlign: .center,
                  ),
                  Text(
                    "دواك",
                    style: AppTextConstants.headingStyle.copyWith(
                      fontSize: 40,
                      fontFamily: 'Tajawal',
                      color: AppColors.primary,
                    ),
                    textAlign: .center,
                  ),

                  const SizedBox(height: 10),

                  AppText(
                    text: "welcomeBack",
                    style: AppTextConstants.subheadingStyle,
                  ),
                  AppText(text: "loginToContinue", color: AppColors.grey),

                  const SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      label: AppText(text: "email"),
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
                          color: AppColors.primary,
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

                  const SizedBox(height: 30),
                  TextField(
                    controller: passwordController,
                    obscureText: _isSecured,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      label: AppText(text: "password"),
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
                          color: AppColors.primary,
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

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(alignment: .centerEnd),
                    child: AppText(text: "forgotPassword"),
                  ),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                      backgroundColor: AppColors.primary,
                      fixedSize: Size.fromHeight(50),
                    ),

                    child: AppText(
                      text: "login",
                      color: Colors.white,
                      style: AppTextConstants.subheadingStyle.copyWith(
                        fontSize: 25,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      AppText(text: "dontHaveAccount"),
                      AppText(
                        text: "createNewAccount",
                        style: AppTextConstants.bodyStyle.copyWith(
                          fontWeight: .w600,
                        ),
                      ),
                    ],
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
