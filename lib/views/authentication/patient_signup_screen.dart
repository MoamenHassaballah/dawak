import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassowrdController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Row(
                    textDirection: .ltr,
                    mainAxisAlignment: .center,
                    spacing: 16,
                    children: [
                      Image.asset(
                        'assets/icon/logo_shadow.png',
                        width: 80,
                        height: 80,
                      ),
                      Column(
                        children: [
                          Text(
                            "Dawak",
                            style: AppTextConstants.headingStyle(context)
                                .copyWith(
                                  fontSize: 30,
                                  fontFamily: 'Poppins',
                                  color: AppColors.primary,
                                ),
                            textAlign: .center,
                          ),
                          Text(
                            "دواك",
                            style: AppTextConstants.headingStyle(context)
                                .copyWith(
                                  fontSize: 30,
                                  fontFamily: 'Tajawal',
                                  color: AppColors.primary,
                                ),
                            textAlign: .center,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const SizedBox(height: 24),
                  AppText(
                    text: "firstStepTitle",
                    style: AppTextConstants.subheadingStyle(context),
                  ),
                  const SizedBox(height: 8),
                  AppText(text: "firstStepSubtitle", color: AppColors.grey),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      spacing: 16,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            label: AppText(text: "name", color: AppColors.grey),
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.person_2_outlined,
                              color: AppColors.grey,
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
                          keyboardType: .name,
                          validator: (value) {
                            return value?.isEmpty ?? true
                                ? context.tr("nameRequired")
                                : null;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            label: AppText(
                              text: "email",
                              color: AppColors.grey,
                            ),
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.grey,
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
                          keyboardType: .emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr("emailRequired");
                            } else if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return context.tr("emailInvalid");
                            }

                            return null;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                        ),

                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            label: AppText(
                              text: "phone",
                              color: AppColors.grey,
                            ),
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.phone,
                              color: AppColors.grey,
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
                          keyboardType: .phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr("phoneRequired");
                            } else if (!RegExp(
                              r'^(?:[+0#]2)?0?(10|11|12|15)[0-9]{8}$',
                            ).hasMatch(value.trim())) {
                              return context.tr("phoneInvalid");
                            }

                            return null;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                        ),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            label: AppText(
                              text: "password",
                              color: AppColors.grey,
                            ),
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.grey,
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
                          obscureText: true,
                          keyboardType: .text,
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return context.tr("passwordTooShort");
                            }

                            return null;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                        ),

                        TextFormField(
                          controller: _confirmPassowrdController,
                          decoration: InputDecoration(
                            label: AppText(
                              text: "confirmPassword",
                              color: AppColors.grey,
                            ),
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.grey,
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
                          obscureText: true,
                          keyboardType: .text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr("confirmPasswordRequired");
                            } else if (value != _passwordController.text) {
                              return context.tr("passwordsDoNotMatch");
                            }

                            return null;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                      backgroundColor: AppColors.primary,
                      fixedSize: Size.fromHeight(50),
                    ),

                    child: AppText(
                      text: "createAccount",
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
                      AppText(text: "alreadyHaveAccount"),
                      InkWell(
                        onTap: () {
                          context.pushReplacement(LoginScreen());
                        },
                        child: AppText(
                          text: "login",
                          style: AppTextConstants.bodyStyle(
                            context,
                          ).copyWith(fontWeight: .w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
