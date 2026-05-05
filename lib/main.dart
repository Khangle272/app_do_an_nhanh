import 'package:app_do_an_nhanh/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_do_an_nhanh/providers/cart_provider.dart';
import 'package:app_do_an_nhanh/screens/onboarding_screen.dart';
import 'package:app_do_an_nhanh/screens/login_screen.dart';
import 'package:app_do_an_nhanh/screens/register_screen.dart';
import 'package:app_do_an_nhanh/screens/main_layout.dart';
import 'package:app_do_an_nhanh/providers/order_provider.dart';
import 'package:app_do_an_nhanh/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

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
