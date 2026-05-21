import 'package:app_do_an_nhanh/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Providers
import 'package:app_do_an_nhanh/providers/cart_provider.dart';
import 'package:app_do_an_nhanh/providers/order_provider.dart';

// Import Screens
import 'package:app_do_an_nhanh/screens/onboarding_screen.dart';
import 'package:app_do_an_nhanh/screens/login_screen.dart';
import 'package:app_do_an_nhanh/screens/register_screen.dart';
import 'package:app_do_an_nhanh/screens/main_layout.dart';
import 'package:app_do_an_nhanh/screens/home_screen.dart';
// Import Theme
import 'package:app_do_an_nhanh/utils/app_theme.dart';
import 'package:app_do_an_nhanh/utils/onboarding_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const FastFoodApp(),
    ),
  );
}

class FastFoodApp extends StatelessWidget {
  const FastFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đồ ăn nhanh',
      theme: AppTheme.lightTheme,
      home: const AppStart(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = args is int ? args : 0;
          final safeIndex = (initialIndex < 0 || initialIndex > 3)
              ? 0
              : initialIndex;
          return MainLayout(initialIndex: safeIndex);
        },
        '/home': (context) =>
            const HomeScreen(), // --> THÊM ROUTE NÀY CHO THÀNH VIÊN 2
      },
    );
  }
}

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingStorage.isCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }

        final isCompleted = snapshot.data ?? false;
        if (!isCompleted) {
          return OnboardingScreen(
            onCompleted: () async {
              await OnboardingStorage.setCompleted();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthGate()),
              );
            },
          );
        }

        return const AuthGate();
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const MainLayout();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
