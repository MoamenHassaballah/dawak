import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: .spaceAround,
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            const SizedBox(height: 40),
                            AppText(
                              text: "welcomeHeader",
                              style: AppTextConstants.headingStyle(
                                context,
                              ).copyWith(fontSize: 20),
                            ),
                            AppText(
                              text: "welcomeHeaderSubtitle",
                              style: AppTextConstants.bodyStyle(
                                context,
                              ).copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    8,
                                  ),
                                ),
                              ),
                              child: AppText(
                                text: "browsePharmacies",
                                color: Colors.white,
                                style: AppTextConstants.subheadingStyle(
                                  context,
                                ).copyWith(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Image.asset("assets/images/guest_home_icon.png"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF006C51),
                        Color(0xFF8CF3CC),
                        Color(0xFF006C51),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: .center,
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      AppText(
                        text: "discoverPharmacies",
                        style: AppTextConstants.headingStyle(
                          context,
                        ).copyWith(fontSize: 20),
                      ),

                      TextButton.icon(
                        onPressed: () {},
                        label: AppText(text: "viewAll"),
                        icon: Icon(Icons.arrow_forward_ios_outlined),
                        iconAlignment: .end,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                ListView.builder(
                  itemCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        height: 150,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.stroke,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: .start,
                          spacing: 10,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "samplePharmacyName",
                                    style: AppTextConstants.headingStyle(
                                      context,
                                    ).copyWith(fontSize: 18),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: .center,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: AppText(
                                          text: "samplePharmacyAddress",
                                          style: AppTextConstants.bodyStyle(
                                            context,
                                          ).copyWith(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: .center,
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      AppText(
                                        text: "01000000000",
                                        translate: false,
                                        style: AppTextConstants.bodyStyle(
                                          context,
                                        ).copyWith(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  height: double.infinity,
                                  color: AppColors.background,
                                  child: Image.asset(
                                    "assets/images/pharm_placeholder.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            height: 67,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: "registerAndOrderBanner",
                    maxLines: 2,
                    color: Colors.white,
                    style: AppTextConstants.headingStyle(
                      context,
                    ).copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF006C51),
                        Color(0xFF79C8AD),
                        Color(0xFF006C51),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText(
                    text: "registerNow",
                    color: Colors.white,
                    style: AppTextConstants.headingStyle(
                      context,
                    ).copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
