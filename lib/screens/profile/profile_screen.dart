import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../orders/orders_screen.dart';
import '../address/addresses_screen.dart';
import '../chat/user_chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final user = auth.userModel;
          final firebaseUser = auth.user;

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              (user?.displayName ?? firebaseUser?.email ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(color: AppColors.primary),
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      user?.displayName ?? firebaseUser?.displayName ?? 'User',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      user?.email ?? firebaseUser?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Menu Items
              _MenuSection(
                title: 'Akun',
                items: [
                  _MenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: AppStrings.myOrders,
                    subtitle: 'Lihat riwayat pesanan',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Pengiriman',
                    subtitle: 'Kelola alamat pengiriman',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddressesScreen()),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Metode Pembayaran',
                    subtitle: 'Pilih metode pembayaran',
                    onTap: () {
                      _showPaymentMethodsDialog(context);
                    },
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: AppSizes.md),

              _MenuSection(
                title: 'Dukungan',
                items: [
                  _MenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chat dengan Admin',
                    subtitle: 'Tanya atau keluhan',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserChatScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    onTap: () {
                      _showHelpCenterDialog(context);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: 'Tentang',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(context, auth),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.md),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(AppStrings.logout),
              ),
              const SizedBox(height: AppSizes.lg),

              // App Version
              Center(
                child: Text(
                  '${AppStrings.appName} v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appTagline),
            const SizedBox(height: AppSizes.md),
            const Text('Versi: 1.0.0'),
            const SizedBox(height: AppSizes.xs),
            const Text('© 2024 ShopeZone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.lg),
            _PaymentMethodTile(
              icon: Icons.money,
              title: 'Bayar di Tempat (COD)',
              subtitle: 'Bayar saat pesanan diterima',
              isAvailable: true,
            ),
            _PaymentMethodTile(
              icon: Icons.account_balance,
              title: 'Transfer Bank',
              subtitle: 'BCA, Mandiri, BNI, BRI',
              isAvailable: true,
            ),
            _PaymentMethodTile(
              icon: Icons.qr_code,
              title: 'QRIS',
              subtitle: 'Scan untuk bayar dengan e-wallet',
              isAvailable: true,
            ),
            _PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'Kartu Kredit/Debit',
              subtitle: 'Visa, Mastercard, JCB',
              isAvailable: false,
              comingSoon: true,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pusat Bantuan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.lg),
            _HelpTile(
              icon: Icons.chat_bubble_outline,
              title: 'Hubungi Kami',
              subtitle: 'Chat dengan tim support',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserChatScreen()),
                );
              },
            ),
            _HelpTile(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@shopezone.com',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            _HelpTile(
              icon: Icons.phone_outlined,
              title: 'Telepon Kami',
              subtitle: '+62 21 1234 5678',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            _HelpTile(
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              subtitle: 'Pertanyaan yang sering diajukan',
              onTap: () {
                Navigator.of(context).pop();
                _showFAQDialog(context);
              },
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FAQ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FAQItem(
                question: 'How do I track my order?',
                answer:
                    'Go to My Orders section and tap on any order to see its tracking status.',
              ),
              _FAQItem(
                question: 'What payment methods are accepted?',
                answer:
                    'We accept COD, Bank Transfer, and QRIS payment methods.',
              ),
              _FAQItem(
                question: 'How can I return a product?',
                answer:
                    'Contact our support team within 7 days of receiving your order.',
              ),
              _FAQItem(
                question: 'How long is shipping?',
                answer:
                    'Shipping typically takes 2-5 business days depending on your location.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.sm,
            bottom: AppSizes.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          child: Column(
            children: items.map((item) => item).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(fontSize: 12, color: AppColors.textHint))
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isAvailable;
  final bool comingSoon;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isAvailable = true,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isAvailable ? AppColors.primary : AppColors.textHint,
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isAvailable ? null : AppColors.textHint,
            ),
          ),
          if (comingSoon) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 12,
        ),
      ),
      trailing: isAvailable
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : null,
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textHint)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
