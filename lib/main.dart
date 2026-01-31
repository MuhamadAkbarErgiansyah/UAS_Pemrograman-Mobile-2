import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_screen.dart';
import 'services/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // PENTING: Set persistence ke LOCAL agar session tersimpan
  // Ini akan menyimpan login state di browser/device
  await firebase_auth.FirebaseAuth.instance
      .setPersistence(firebase_auth.Persistence.LOCAL);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gvmhapmqgwxmqddvgqes.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2bWhhcG1xZ3d4bXFkZHZncWVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5MTQyNDAsImV4cCI6MjA1MjQ5MDI0MH0.5DmPKxJDlvhn1dIL86PHlZfMfiWLBVYh6JxKn6RLSLc',
  );

  runApp(const ShopZoneApp());
}

class ShopZoneApp extends StatelessWidget {
  const ShopZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProxyProvider<app_auth.AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) {
            if (auth.user != null) {
              cart?.initialize(auth.user!.uid);
            } else {
              cart?.clear();
            }
            return cart ?? CartProvider();
          },
        ),
        ChangeNotifierProxyProvider<app_auth.AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, auth, wishlist) {
            if (auth.user != null) {
              wishlist?.initialize(auth.user!.uid);
            } else {
              wishlist?.clear();
            }
            return wishlist ?? WishlistProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'ShopeZone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppStartup(),
      ),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _isCheckingOnboarding = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final hasSeenOnboarding =
        await SharedPreferencesHelper.getBool('has_seen_onboarding') ?? false;

    setState(() {
      _showOnboarding = !hasSeenOnboarding;
      _isCheckingOnboarding = false;
    });
  }

  Future<void> _completeOnboarding() async {
    await SharedPreferencesHelper.setBool('has_seen_onboarding', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Masih cek onboarding
    if (_isCheckingOnboarding) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Tampilkan onboarding jika belum pernah dilihat
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: _completeOnboarding,
      );
    }

    // PENTING: Gunakan StreamBuilder untuk listen Firebase Auth state
    // Ini akan otomatis detect jika user sudah login sebelumnya
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Masih loading auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking login status...'),
                ],
              ),
            ),
          );
        }

        // Cek apakah ada user yang sudah login
        final user = snapshot.data;

        if (user != null) {
          // User sudah login - initialize cart dan wishlist
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<CartProvider>().initialize(user.uid);
            context.read<WishlistProvider>().initialize(user.uid);
          });

          debugPrint('✅ User already logged in: ${user.email}');
          return const MainScreen();
        }

        // User belum login
        debugPrint('❌ No user logged in, showing login screen');
        return const LoginScreen();
      },
    );
  }
}
