import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_textfield.dart';
import 'package:app_do_an_nhanh/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                    "Đăng ký",
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

                const SizedBox(height: 16),

                const CustomTextfield(
                  hintText: "Xác Nhận Mật khẩu",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 24),

                // Register Button
                PrimaryButton(
                  text: "Đăng ký",
                  width: double.infinity,
                  height: 56,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {},
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: const Text("Đã có tài khoản?"),
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
