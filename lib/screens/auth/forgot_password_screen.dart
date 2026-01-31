import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    Helpers.unfocus(context);

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _emailSent = success;
    });

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        'Password reset email sent!',
        isSuccess: true,
      );
    } else if (authProvider.errorMessage != null && mounted) {
      Helpers.showSnackBar(context, authProvider.errorMessage!, isError: true);
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                // Title
                Center(
                  child: Text(
                    AppStrings.resetPassword,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Center(
                  child: Text(
                    _emailSent
                        ? 'We have sent a password reset link to your email'
                        : AppStrings.resetPasswordDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                if (!_emailSent) ...[
                  // Email
                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.done,
                    validator: Validators.email,
                    onSubmitted: (_) => _sendResetEmail(),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  // Send Button
                  CustomButton(
                    text: AppStrings.sendResetLink,
                    onPressed: _sendResetEmail,
                    isLoading: _isLoading,
                  ),
                ] else ...[
                  // Resend Button
                  CustomButton(
                    text: 'Resend Email',
                    onPressed: _sendResetEmail,
                    isLoading: _isLoading,
                  ),
                ],
                const SizedBox(height: AppSizes.lg),
                // Back to Login
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(AppStrings.backToLogin),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
