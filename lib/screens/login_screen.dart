import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_textfield.dart';
import 'package:app_do_an_nhanh/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Prevents overflow when keyboard appears
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                const CustomTextfield(
                  hintText: "Email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Password Field
                const CustomTextfield(
                  hintText: "Mật khẩu",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 8),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Quên mật khẩu?"),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                PrimaryButton(
                  text: "Đăng nhập",
                  width: double.infinity,
                  height: 56,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/main");
                  },
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: const Text("Chưa có tài khoản?"),
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
