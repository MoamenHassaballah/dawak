import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/authentication/select_address_page.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:dawak/viewmodels/auth_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PharmacySignupScreen extends StatefulWidget {
  const PharmacySignupScreen({super.key});

  @override
  State<PharmacySignupScreen> createState() => _PharmacySignupScreenState();
}

class _PharmacySignupScreenState extends State<PharmacySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  double? _addressLatitude;
  double? _addressLongitude;

  Future<void> _selectAddress() async {
    final currentLatitude = _addressLatitude;
    final currentLongitude = _addressLongitude;
    final initialSelection = currentLatitude == null || currentLongitude == null
        ? null
        : SelectedAddress(
            latitude: currentLatitude,
            longitude: currentLongitude,
            address: _addressController.text,
          );
    final selection = await context.push<SelectedAddress>(
      SelectAddressPage(initialSelection: initialSelection),
    );
    if (!mounted || selection == null) {
      return;
    }
    setState(() {
      _addressController.text = selection.address;
      _addressLatitude = selection.latitude;
      _addressLongitude = selection.longitude;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final latitude = _addressLatitude;
    final longitude = _addressLongitude;
    if (latitude == null || longitude == null) {
      return;
    }

    final result = await context.read<AuthViewModel>().signupPharmacy(
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      pharmacyName: _nameController.text,
      latitude: latitude,
      longitude: longitude,
      address: _addressController.text,
    );
    if (!mounted) {
      return;
    }

    final message = result.isSuccess
        ? result.message ?? context.tr('confirmEmailMessage')
        : result.message ??
              switch (result.failure) {
                SignupFailure.connection => context.tr('signupConnectionError'),
                SignupFailure.invalidResponse => context.tr(
                  'signupInvalidResponse',
                ),
                _ => context.tr('signupFailed'),
              };

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.tr(
            result.isSuccess ? 'signupSuccessTitle' : 'signupErrorTitle',
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (result.isSuccess) {
                context.pushAndRemoveUntil(
                  const LoginScreen(),
                  (route) => false,
                );
              }
            },
            child: Text(context.tr(result.isSuccess ? 'login' : 'ok')),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: AppColors.stroke),
      borderRadius: BorderRadius.circular(12),
    );

    return InputDecoration(
      label: AppText(text: label, color: AppColors.grey),
      fillColor: Colors.white,
      filled: true,
      prefixIcon: Icon(icon, color: AppColors.grey),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1, color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  Image.asset(
                    'assets/icon/logo_shadow.png',
                    width: 88,
                    height: 88,
                  ),
                  Text(
                    'Dawak',
                    style: AppTextConstants.headingStyle(context).copyWith(
                      fontSize: 32,
                      fontFamily: 'Poppins',
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'دواك',
                    style: AppTextConstants.headingStyle(context).copyWith(
                      fontSize: 32,
                      fontFamily: 'Tajawal',
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  AppText(
                    text: 'pharmacySignupHeading',
                    style: AppTextConstants.subheadingStyle(context),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: 'pharmacySignupSubtitle',
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _decoration(
                            context,
                            'pharmacyName',
                            Icons.person_outline,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? context.tr('pharmacyNameRequired')
                              : null,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          readOnly: true,
                          showCursor: false,
                          onTap: _selectAddress,
                          decoration: _decoration(
                            context,
                            'address',
                            Icons.location_on_outlined,
                            suffixIcon: const Icon(Icons.map_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null ||
                                  value.trim().isEmpty ||
                                  _addressLatitude == null ||
                                  _addressLongitude == null
                              ? context.tr('addressRequired')
                              : null,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _decoration(
                            context,
                            'email',
                            Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr('emailRequired');
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value.trim())) {
                              return context.tr('emailInvalid');
                            }
                            return null;
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: _decoration(
                            context,
                            'phone',
                            Icons.phone_outlined,
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr('phoneRequired');
                            }
                            // if (!RegExp(
                            //   r'^(?:[+0#]2)?0?(10|11|12|15)[0-9]{8}$',
                            // ).hasMatch(value.trim())) {
                            //   return context.tr('phoneInvalid');
                            // }
                            return null;
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: _decoration(
                            context,
                            'password',
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () =>
                                    _isPasswordObscured = !_isPasswordObscured,
                              ),
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          obscureText: _isPasswordObscured,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.length < 8
                              ? context.tr('passwordTooShort')
                              : null,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: _decoration(
                            context,
                            'confirmPassword',
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _isConfirmPasswordObscured =
                                    !_isConfirmPasswordObscured,
                              ),
                              icon: Icon(
                                _isConfirmPasswordObscured
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          obscureText: _isConfirmPasswordObscured,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.tr('confirmPasswordRequired');
                            }
                            if (value != _passwordController.text) {
                              return context.tr('passwordsDoNotMatch');
                            }
                            return null;
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      backgroundColor: AppColors.primary,
                      fixedSize: const Size.fromHeight(58),
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
                            text: 'createAccount',
                            color: Colors.white,
                            style: AppTextConstants.subheadingStyle(
                              context,
                            ).copyWith(fontSize: 22, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(text: 'alreadyHaveAccount'),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () =>
                            context.pushReplacement(const LoginScreen()),
                        child: AppText(
                          text: 'login',
                          style: AppTextConstants.bodyStyle(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
