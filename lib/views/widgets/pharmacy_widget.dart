import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class PharmacyWidget extends StatelessWidget {
  const PharmacyWidget({super.key, this.name, this.address, this.phone});

  final String? name;
  final String? address;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.stroke, width: 1.5),
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name ?? "samplePharmacyName",
                  style: AppTextConstants.headingStyle(
                    context,
                  ).copyWith(fontSize: 18),
                  maxLines: 2,
                  translate: name == null,
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
                        text: address ?? "samplePharmacyAddress",
                        style: AppTextConstants.bodyStyle(
                          context,
                        ).copyWith(fontSize: 16),
                        translate: address == null,
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
                      text: phone ?? "01000000000",
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
            flex: 2,
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
    );
  }
}
