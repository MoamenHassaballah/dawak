import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/patient/patient_edit_account_page.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:dawak/views/widgets/session_expired_dialog.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientMyAccountPage extends StatefulWidget {
  const PatientMyAccountPage({super.key, this.sessionStorage, this.viewModel});

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
      showSessionExpiredDialog(context, onLogin: _handleExpiredSession);
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

  Future<void> _openEmailUpdateSheet() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }

    final updatedProfile = await showModalBottomSheet<PatientProfile>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ChangeEmailBottomSheet(
        initialEmail: profile.email,
        onUpdate: (email) => _patientViewModel.updateEmail(email: email),
        onSessionExpired: _handleExpiredSession,
      ),
    );

    if (!mounted || updatedProfile == null) {
      return;
    }
    setState(() => _profile = updatedProfile);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.tr('emailUpdateSuccess'))));
  }

  Future<void> _openPasswordUpdateSheet() async {
    final didUpdate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ChangePasswordBottomSheet(
        onUpdate: (currentPassword, newPassword) =>
            _patientViewModel.updatePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            ),
        onSessionExpired: _handleExpiredSession,
      ),
    );

    if (!mounted || didUpdate != true) {
      return;
    }
    await _showPasswordUpdatedDialog();
  }

  Future<void> _showPasswordUpdatedDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: AppText(text: 'passwordUpdatedTitle'),
        content: AppText(text: 'passwordUpdatedRelogin'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _signOut();
            },
            child: AppText(text: 'ok'),
          ),
        ],
      ),
    );
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
      PatientProfileFailure.missingSession => context.tr('profileSessionError'),
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

  Widget _profileIcon({double size = 88, String? imageUrl}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            clipBehavior: .hardEdge,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.decoration,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.decoration, width: 5),
            ),
            child: Image.network(
              "$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}",
              fit: .cover,
              loadingBuilder: (context, child, _) => ClipOval(child: child),
              errorBuilder: (context, url, error) {
                debugPrint("error loading image: ${error.toString()}");
                return Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.55,
                );
              },
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: .center,
            children: [
              Icon(icon, size: 17, color: AppColors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextConstants.bodyStyle(
                  context,
                ).copyWith(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextConstants.bodyStyle(
              context,
            ).copyWith(color: AppColors.primary, fontSize: 15),
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
            Icon(icon, size: 18, color: titleColor ?? AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: AppTextConstants.bodyStyle(context).copyWith(
                  color: titleColor ?? AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 20,
              color: AppColors.grey,
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: .start,
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
                _profileIcon(size: 150, imageUrl: profile.img),
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
                  iconAlignment: .end,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('personalInformation'),
            textAlign: TextAlign.end,
            style: AppTextConstants.subheadingStyle(
              context,
            ).copyWith(color: AppColors.primary, fontSize: 17),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: .start,
              children: [
                _profileDetail(
                  icon: Icons.email_outlined,
                  label: context.tr('email'),
                  value: profile.email,
                ),
                Divider(),
                _profileDetail(
                  icon: Icons.phone_outlined,
                  label: context.tr('phone'),
                  value: profile.phone,
                ),
                Divider(),
                _profileDetail(
                  icon: Icons.location_on_outlined,
                  label: context.tr('address'),
                  value: profile.address ?? context.tr('notProvided'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('securityAndPrivacy'),
            textAlign: TextAlign.end,
            style: AppTextConstants.subheadingStyle(
              context,
            ).copyWith(color: AppColors.primary, fontSize: 17),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _actionRow(
                  icon: Icons.email_outlined,
                  title: context.tr('changeEmail'),
                  onTap: _openEmailUpdateSheet,
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _actionRow(
                  icon: Icons.lock_outline,
                  title: context.tr('changePassword'),
                  onTap: _openPasswordUpdateSheet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: _actionRow(
              icon: Icons.logout,
              title: _isSigningOut
                  ? context.tr('signOut')
                  : context.tr('signOut'),
              titleColor: Colors.red,
              onTap: _isSigningOut ? () {} : _signOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeEmailBottomSheet extends StatefulWidget {
  const _ChangeEmailBottomSheet({
    required this.initialEmail,
    required this.onUpdate,
    required this.onSessionExpired,
  });

  final String initialEmail;
  final Future<PatientProfileResult> Function(String email) onUpdate;
  final Future<void> Function() onSessionExpired;

  @override
  State<_ChangeEmailBottomSheet> createState() =>
      _ChangeEmailBottomSheetState();
}

class _ChangeEmailBottomSheetState extends State<_ChangeEmailBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final result = await widget.onUpdate(_emailController.text.trim());
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (result.isSuccess && result.profile != null) {
      Navigator.of(context).pop(result.profile);
      return;
    }

    if (result.failure == PatientProfileFailure.unauthorized) {
      await showSessionExpiredDialog(context, onLogin: widget.onSessionExpired);
      return;
    }

    final message = result.message?.trim();
    setState(() {
      _errorMessage = message?.isNotEmpty == true
          ? message
          : switch (result.failure) {
              PatientProfileFailure.connection => context.tr(
                'profileConnectionError',
              ),
              PatientProfileFailure.unauthorized => context.tr(
                'profileUnauthorizedError',
              ),
              PatientProfileFailure.forbidden => context.tr(
                'profileForbiddenError',
              ),
              PatientProfileFailure.missingSession => context.tr(
                'profileSessionError',
              ),
              _ => context.tr('profileSaveFailed'),
            };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('changeEmail'),
                  style: AppTextConstants.subheadingStyle(
                    context,
                  ).copyWith(color: AppColors.primary, fontSize: 20),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.tr('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr('emailRequired');
                    }
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return context.tr('emailInvalid');
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: AppTextConstants.bodyStyle(
                      context,
                    ).copyWith(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppText(text: 'cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: AppText(
                                  text: "save",
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordBottomSheet extends StatefulWidget {
  const _ChangePasswordBottomSheet({
    required this.onUpdate,
    required this.onSessionExpired,
  });

  final Future<PatientPasswordResult> Function(
    String currentPassword,
    String newPassword,
  )
  onUpdate;
  final Future<void> Function() onSessionExpired;

  @override
  State<_ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState
    extends State<_ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isSaving = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final result = await widget.onUpdate(
      _currentPasswordController.text,
      _newPasswordController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }

    if (result.failure == PatientProfileFailure.unauthorized) {
      await showSessionExpiredDialog(context, onLogin: widget.onSessionExpired);
      return;
    }

    final message = result.message?.trim();
    setState(() {
      _errorMessage = message?.isNotEmpty == true
          ? message
          : switch (result.failure) {
              PatientProfileFailure.connection => context.tr(
                'profileConnectionError',
              ),
              PatientProfileFailure.forbidden => context.tr(
                'profileForbiddenError',
              ),
              PatientProfileFailure.missingSession => context.tr(
                'profileSessionError',
              ),
              _ => context.tr('profileSaveFailed'),
            };
    });
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required TextInputAction textInputAction,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    final fontFamily = context.locale == const Locale('ar')
        ? 'Tajawal'
        : 'Poppins';
    final textStyle = AppTextConstants.bodyStyle(
      context,
    ).copyWith(fontFamily: fontFamily);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      style: textStyle,
      decoration: InputDecoration(
        labelText: context.tr(label),
        labelStyle: textStyle,
        errorStyle: textStyle.copyWith(color: Colors.red),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  text: 'changePassword',
                  style: AppTextConstants.subheadingStyle(
                    context,
                  ).copyWith(fontSize: 20),
                ),
                const SizedBox(height: 18),
                _passwordField(
                  controller: _currentPasswordController,
                  label: 'currentPassword',
                  obscureText: _obscureCurrentPassword,
                  textInputAction: TextInputAction.next,
                  onToggleObscure: () => setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? context.tr('currentPasswordRequired')
                      : null,
                ),
                const SizedBox(height: 14),
                _passwordField(
                  controller: _newPasswordController,
                  label: 'newPassword',
                  obscureText: _obscureNewPassword,
                  textInputAction: TextInputAction.done,
                  onToggleObscure: () => setState(
                    () => _obscureNewPassword = !_obscureNewPassword,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('newPasswordRequired');
                    }
                    if (value.length < 8) {
                      return context.tr('passwordTooShort');
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  AppText(
                    text: _errorMessage!,
                    translate: false,
                    color: Colors.red,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppText(text: 'cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: AppText(
                                  text: 'save',
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
