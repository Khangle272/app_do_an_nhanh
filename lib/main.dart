import 'package:app_do_an_nhanh/screens/login_screen.dart';
import 'package:app_do_an_nhanh/screens/main_layout.dart';
import 'package:app_do_an_nhanh/screens/onboarding_screen.dart';
import 'package:app_do_an_nhanh/screens/register_screen.dart';
import 'package:app_do_an_nhanh/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FastFoodApp());
}

class FastFoodApp extends StatelessWidget {
  const FastFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}
