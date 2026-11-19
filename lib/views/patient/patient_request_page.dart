import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientRequestPage extends StatefulWidget {
  const PatientRequestPage({super.key, this.sessionStorage});

  final AuthSessionStorage? sessionStorage;

  @override
  State<PatientRequestPage> createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  late Future<String?> _firstName;

  @override
  void initState() {
    super.initState();
    _firstName = (widget.sessionStorage ?? SecureAuthSessionStorage())
        .readFirstName();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<String?>(
            future: _firstName,
            builder: (context, snapshot) {
              final firstName = snapshot.data?.trim();
              final greeting = snapshot.hasError
                  ? context.tr('patientGreetingLoadError')
                  : firstName?.isNotEmpty == true
                  ? context.tr(
                      'patientGreetingWithName',
                      namedArgs: {'name': firstName!},
                    )
                  : context.tr('patientGreeting');

              return Text(
                greeting,
                textAlign: TextAlign.start,
                style: AppTextConstants.headingStyle(
                  context,
                ).copyWith(color: AppColors.primary, fontSize: 28),
              );
            },
          ),
          const SizedBox(height: 16),
          const _OrderMedicineBanner(),
          const SizedBox(height: 32),
          const Directionality(
            textDirection: .ltr,
            child: Row(
              children: [
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.near_me_outlined,
                    title: 'nearestPharmacy',
                    subtitle: 'browseMap',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.cached,
                    title: 'reorder',
                    subtitle: 'previousOrders',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.document_scanner_outlined,
                    title: 'newPrescription',
                    subtitle: 'uploadPrescription',
                    highlighted: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('recentOrders'),
                style: AppTextConstants.headingStyle(
                  context,
                ).copyWith(fontSize: 25, color: AppColors.primary),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios_outlined),
                label: Text(context.tr('viewAllOrders')),
                iconAlignment: IconAlignment.end,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextConstants.bodyStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _RequestCard(
            name: 'augmentinName',
            date: 'todayOrderDate',
            acceptedCount: 3,
            rejectedCount: 1,
            isActive: true,
          ),
          const _RequestCard(
            name: 'concorName',
            date: 'octoberOrderDate',
            acceptedCount: 5,
            rejectedCount: 1,
          ),
          const _RequestCard(
            name: 'panadolName',
            date: 'mayOrderDate',
            acceptedCount: 3,
            rejectedCount: 2,
          ),
        ],
      ),
    );
  }
}

class _OrderMedicineBanner extends StatelessWidget {
  const _OrderMedicineBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00475D), Color(0xFF003B49)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.directional(
              textDirection: context.locale == Locale("ar") ? .rtl : .ltr,
              end: 0,
              start: 0,
              bottom: 0,
              top: 0,
              child: Image.asset(
                'assets/images/patient_home_top.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned.directional(
              textDirection: context.locale == Locale("ar") ? .rtl : .ltr,
              top: 20,
              start: 18,
              bottom: 16,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('findMedicineTitle'),
                        textAlign: TextAlign.end,
                        style: AppTextConstants.headingStyle(
                          context,
                        ).copyWith(color: Colors.white, fontSize: 27),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('findMedicineDescription'),
                        style: AppTextConstants.bodyStyle(
                          context,
                        ).copyWith(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          context.tr('orderNow'),
                          style: AppTextConstants.subheadingStyle(
                            context,
                          ).copyWith(color: Colors.white, fontSize: 19),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: highlighted ? Border.all(color: AppColors.decoration) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: highlighted
                ? const Color(0xFFBDF5E4)
                : const Color(0xFFE9EDFF),
            child: Icon(
              icon,
              color: highlighted ? const Color(0xFF007A61) : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(title),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextConstants.subheadingStyle(
              context,
            ).copyWith(fontSize: 15, color: const Color(0xFF182238)),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(subtitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextConstants.bodyStyle(
              context,
            ).copyWith(fontSize: 13, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
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

    if (!isActive) {
      return Padding(padding: const EdgeInsets.only(bottom: 14), child: card);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF007A61), Color(0xFF78E5BF)],
          ),
        ),
        child: card,
      ),
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
