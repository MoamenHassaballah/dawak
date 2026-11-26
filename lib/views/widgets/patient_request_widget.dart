import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientRequestWidget extends StatelessWidget {
  const PatientRequestWidget({
    super.key,
    required this.name,
    required this.date,
    required this.acceptedCount,
    required this.rejectedCount,
    this.isActive = false,
  });

  final String name;
  final String date;
  final int acceptedCount;
  final int rejectedCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context.tr(name),
                  style: AppTextConstants.subheadingStyle(
                    context,
                  ).copyWith(fontSize: 19, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              _RequestState(isActive: isActive),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.access_time, color: Colors.blueGrey, size: 18),
              const SizedBox(width: 6),
              Text(
                context.tr(date),
                style: AppTextConstants.bodyStyle(
                  context,
                ).copyWith(fontSize: 14, color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ResponseCount(
                      count: acceptedCount,
                      label: context.tr('accepted'),
                      foregroundColor: const Color(0xFF007A61),
                      backgroundColor: const Color(0xFFD0F8EC),
                      icon: Icons.check_circle_outline,
                    ),
                    _ResponseCount(
                      count: rejectedCount,
                      label: context.tr('rejected'),
                      foregroundColor: const Color(0xFFB00020),
                      backgroundColor: const Color(0xFFFFEEEE),
                      icon: Icons.cancel_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFF0F1FF),
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: isActive
          ? Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF007A61), Color(0xFF78E5BF)],
                ),
              ),
              child: card,
            )
          : card,
    );
  }
}

class _RequestState extends StatelessWidget {
  const _RequestState({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD5F8EC) : const Color(0xFFF0F1FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.circle : Icons.check_circle_outline,
            color: isActive ? const Color(0xFF007A61) : Colors.blueGrey,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            context.tr(isActive ? 'orderAwaiting' : 'orderCompleted'),
            style: AppTextConstants.bodyStyle(context).copyWith(
              fontSize: 13,
              color: isActive ? AppColors.primary : Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCount extends StatelessWidget {
  const _ResponseCount({
    required this.count,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.icon,
  });

  final int count;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: AppTextConstants.subheadingStyle(
              context,
            ).copyWith(fontSize: 16, color: foregroundColor),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextConstants.bodyStyle(
              context,
            ).copyWith(fontSize: 13, color: foregroundColor),
          ),
          const SizedBox(width: 5),
          Icon(icon, size: 20, color: foregroundColor),
        ],
      ),
    );
  }
}
