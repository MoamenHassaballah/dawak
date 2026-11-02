import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/views/authentication/patient_signup_screen.dart';
import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SignupAccountSelection extends StatelessWidget {
  const SignupAccountSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -450,
            right: -120,
            left: -120,
            child: CircleAvatar(
              radius: 350,
              backgroundColor: AppColors.decoration,
            ),
          ),

          Positioned.directional(
            textDirection: .ltr,
            top: 100,
            start: 0,
            end: 0,
            child: Column(
              children: [
                Row(
                  textDirection: .ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: .center,
                  spacing: 24,
                  children: [
                    Text(
                      "Dawak",
                      style: AppTextConstants.headingStyle(context).copyWith(
                        fontSize: 40,
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                      ),
                      textAlign: .center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "دواك",
                        style: AppTextConstants.headingStyle(context).copyWith(
                          fontSize: 40,
                          fontFamily: 'Tajawal',
                          color: AppColors.primary,
                        ),
                        textAlign: .center,
                      ),
                    ),
                  ],
                ),
                AppText(text: "newAccount"),
              ],
            ),
          ),

          Positioned.fill(
            top: 200,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AppText(
                        text: "welcomeToDawak",
                        style: AppTextConstants.subheadingStyle(context),
                      ),
                      const SizedBox(height: 12),
                      AppText(text: "chooseAccountType", color: AppColors.grey),
                      const SizedBox(height: 24),

                      InkWell(
                        onTap: () {
                          context.push(PatientSignupScreen());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          padding: EdgeInsets.all(24),
                          child: Row(
                            spacing: 24,
                            children: [
                              Image.asset("assets/images/user.png", width: 69),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    AppText(
                                      text: "patient",
                                      style: AppTextConstants.subheadingStyle(
                                        context,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppText(
                                      text: "patientDesc",
                                      color: AppColors.grey,
                                      style: AppTextConstants.bodyStyle(
                                        context,
                                      ).copyWith(fontSize: 15),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        padding: EdgeInsets.all(24),
                        child: Row(
                          spacing: 24,
                          children: [
                            Image.asset(
                              "assets/images/pharmacy.png",
                              width: 69,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  AppText(
                                    text: "pharmacy",
                                    style: AppTextConstants.subheadingStyle(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppText(
                                    text: "pharmacyDesc",
                                    color: AppColors.grey,
                                    style: AppTextConstants.bodyStyle(
                                      context,
                                    ).copyWith(fontSize: 15),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          AppText(text: "alreadyHaveAccount"),
                          InkWell(
                            onTap: () {
                              context.pop();
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
        ],
      ),
    );
  }
}
