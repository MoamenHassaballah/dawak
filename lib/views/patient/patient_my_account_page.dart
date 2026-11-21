import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/patient/patient_edit_account_page.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/session_expired_dialog.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientMyAccountPage extends StatefulWidget {
  const PatientMyAccountPage({
    super.key,
    this.sessionStorage,
    this.viewModel,
  });

  final AuthSessionStorage? sessionStorage;
  final PatientViewModel? viewModel;

  @override
  State<PatientMyAccountPage> createState() => _PatientMyAccountPageState();
}

class _PatientMyAccountPageState extends State<PatientMyAccountPage> {
  late final AuthSessionStorage _sessionStorage;
  late final PatientViewModel _patientViewModel;
  late final bool _ownsViewModel;
  late Future<PatientProfileResult> _profileFuture;
  PatientProfile? _profile;
  bool _isSigningOut = false;
  bool _sessionExpiredDialogScheduled = false;

  @override
  void initState() {
    super.initState();
    _sessionStorage = widget.sessionStorage ?? SecureAuthSessionStorage();
    _ownsViewModel = widget.viewModel == null;
    _patientViewModel =
        widget.viewModel ?? PatientViewModel(sessionStorage: _sessionStorage);
    _profileFuture = _patientViewModel.getProfile();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _patientViewModel.dispose();
    }
    super.dispose();
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

  Future<void> _handleExpiredSession() async {
    var sessionClearFailed = false;
    try {
      await _sessionStorage.clearSession();
    } on PlatformException {
      sessionClearFailed = true;
    }

    if (!mounted) {
      return;
    }
    if (sessionClearFailed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('signOutFailed'))));
    }
    context.pushAndRemoveUntil(const LoginScreen(), (route) => false);
  }

  void _scheduleSessionExpiredDialog() {
    if (_sessionExpiredDialogScheduled || !mounted) {
      return;
    }
    _sessionExpiredDialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showSessionExpiredDialog(
        context,
        onLogin: _handleExpiredSession,
      );
    });
  }

  Future<void> _openEditAccount() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    final result = await context.push<PatientProfile>(
      PatientEditAccountPage(
        initialProfile: profile,
        viewModel: _patientViewModel,
        onSessionExpired: _handleExpiredSession,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() => _profile = result);
  }

  String _failureMessage(PatientProfileResult result) {
    if (result.failure == PatientProfileFailure.unauthorized) {
      return context.tr('profileUnauthorizedError');
    }
    final message = result.message?.trim();
    if (message?.isNotEmpty == true) {
      return message!;
    }
    return switch (result.failure) {
      PatientProfileFailure.connection => context.tr('profileConnectionError'),
      PatientProfileFailure.unauthorized => context.tr(
        'profileUnauthorizedError',
      ),
      PatientProfileFailure.forbidden => context.tr('profileForbiddenError'),
      PatientProfileFailure.missingSession => context.tr(
        'profileSessionError',
      ),
      _ => context.tr('profileLoadFailed'),
    };
  }

  Widget _profileLoadError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _profile = null;
                  _profileFuture = _patientViewModel.getProfile();
                });
              },
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileIcon({double size = 88}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.decoration,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.decoration, width: 7),
            ),
            child: Icon(Icons.person, color: Colors.white, size: size * 0.55),
          ),
          Positioned(
            right: -3,
            bottom: -2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: AppTextConstants.bodyStyle(
              context,
            ).copyWith(color: AppColors.grey, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: AppTextConstants.bodyStyle(
                      context,
                    ).copyWith(color: AppColors.primary, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 17, color: AppColors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.chevron_left, size: 20, color: AppColors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.end,
                style: AppTextConstants.bodyStyle(context).copyWith(
                  color: titleColor ?? AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 18, color: titleColor ?? AppColors.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (profile != null) {
      return _buildProfile(profile);
    }

    return FutureBuilder<PatientProfileResult>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final result = snapshot.data;
        if (result?.failure == PatientProfileFailure.unauthorized) {
          _scheduleSessionExpiredDialog();
        }
        if (snapshot.hasError || result == null || !result.isSuccess) {
          return _profileLoadError(
            result == null
                ? context.tr('profileLoadFailed')
                : _failureMessage(result),
          );
        }
        _profile = result.profile;
        return _buildProfile(result.profile!);
      },
    );
  }

  Widget _buildProfile(PatientProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('myAccount'),
            textAlign: TextAlign.start,
            style: AppTextConstants.headingStyle(
              context,
            ).copyWith(color: AppColors.primary, fontSize: 24),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                _profileIcon(size: 96),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: AppTextConstants.subheadingStyle(
                    context,
                  ).copyWith(color: AppColors.primary, fontSize: 20),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _openEditAccount,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    context.tr('editAccountData'),
                    style: AppTextConstants.bodyStyle(
                      context,
                    ).copyWith(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('personalInformation'),
                  textAlign: TextAlign.end,
                  style: AppTextConstants.subheadingStyle(
                    context,
                  ).copyWith(color: AppColors.primary, fontSize: 17),
                ),
                _profileDetail(
                  icon: Icons.email_outlined,
                  label: context.tr('email'),
                  value: profile.email,
                ),
                _profileDetail(
                  icon: Icons.phone_outlined,
                  label: context.tr('phone'),
                  value: profile.phone,
                ),
                _profileDetail(
                  icon: Icons.location_on_outlined,
                  label: context.tr('address'),
                  value: profile.address ?? context.tr('notProvided'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('securityAndPrivacy'),
                  textAlign: TextAlign.end,
                  style: AppTextConstants.subheadingStyle(
                    context,
                  ).copyWith(color: AppColors.primary, fontSize: 17),
                ),
                const SizedBox(height: 8),
                _actionRow(
                  icon: Icons.email_outlined,
                  title: context.tr('changeEmail'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _actionRow(
                  icon: Icons.lock_outline,
                  title: context.tr('changePassword'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _actionRow(
                  icon: Icons.logout,
                  title: _isSigningOut
                      ? context.tr('signOut')
                      : context.tr('signOut'),
                  titleColor: Colors.red,
                  onTap: _isSigningOut ? () {} : _signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
