import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../home/main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _canUseBiometric = false;
  String _biometricType = 'Sidik Jari';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canUse = await BiometricService.canUseBiometricLogin();
    final biometricType = await BiometricService.getBiometricTypeName();
    if (mounted) {
      setState(() {
        _canUseBiometric = canUse;
        _biometricType = biometricType;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    Helpers.unfocus(context);

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    // Simpan kredensial jika rememberMe aktif
    if (success && _rememberMe) {
      await BiometricService.saveCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await BiometricService.enableBiometric();
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (authProvider.errorMessage != null && mounted) {
      Helpers.showSnackBar(context, authProvider.errorMessage!, isError: true);
      authProvider.clearError();
    }
  }

  Future<void> _loginWithBiometric() async {
    setState(() => _isLoading = true);

    final authenticated = await BiometricService.authenticate(
      localizedReason: 'Sentuh sensor sidik jari untuk masuk ke ShopeZone',
    );

    if (!authenticated) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Autentikasi biometrik gagal',
            isError: true);
      }
      return;
    }

    final credentials = await BiometricService.getSavedCredentials();
    final email = credentials['email'];
    final password = credentials['password'];

    if (email == null || password == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Kredensial tidak ditemukan',
            isError: true);
      }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success =
        await authProvider.signInWithEmail(email, password, rememberMe: true);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (authProvider.errorMessage != null && mounted) {
      Helpers.showSnackBar(context, authProvider.errorMessage!, isError: true);
      authProvider.clearError();
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle(rememberMe: true);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (authProvider.errorMessage != null && mounted) {
      Helpers.showSnackBar(context, authProvider.errorMessage!, isError: true);
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),
                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
                const SizedBox(height: AppSizes.lg),
                // Title
                Center(
                  child: Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: AppSizes.xl),
                // Welcome Text
                Text(
                  AppStrings.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.loginSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                const SizedBox(height: AppSizes.xl),
                // Email
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'Masukkan email Anda',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSizes.md),
                // Password
                CustomTextField(
                  label: AppStrings.password,
                  hint: 'Masukkan kata sandi',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  onSubmitted: (_) => _login(),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSizes.sm),
                // Remember Me and Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _rememberMe = !_rememberMe),
                          child: const Text(
                            'Ingat saya',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(AppStrings.forgotPassword),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                // Login Button
                CustomButton(
                  text: AppStrings.login,
                  onPressed: _login,
                  isLoading: _isLoading,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 700.ms)
                    .slideY(begin: 0.1, end: 0),
                // Biometric Login Button
                if (_canUseBiometric) ...[
                  const SizedBox(height: AppSizes.md),
                  CustomButton(
                    text: 'Login dengan $_biometricType',
                    onPressed: _loginWithBiometric,
                    isLoading: _isLoading,
                    isOutlined: true,
                    prefixIcon: Icon(
                      Icons.fingerprint,
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 750.ms),
                ],
                const SizedBox(height: AppSizes.lg),
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                      ),
                      child: Text(
                        AppStrings.orContinueWith,
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                // Google Button
                CustomButton(
                  text: AppStrings.continueWithGoogle,
                  onPressed: _loginWithGoogle,
                  isLoading: _isLoading,
                  isOutlined: true,
                  prefixIcon: Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.g_mobiledata, size: 24),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 800.ms),
                const SizedBox(height: AppSizes.xl),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(AppStrings.signUp),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                // Admin Login Link
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings, size: 18),
                    label: const Text('Masuk sebagai Admin'),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
