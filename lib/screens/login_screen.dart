import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_textfield.dart';
import 'package:app_do_an_nhanh/widgets/primary_button.dart';
import 'package:app_do_an_nhanh/widgets/custom_loading.dart';
import 'package:app_do_an_nhanh/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/main");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Prevents overflow when keyboard appears
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Đăng nhập",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email Field
                  CustomTextfield(
                    controller: _emailController,
                    hintText: "Email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập email';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextfield(
                    controller: _passwordController,
                    hintText: "Mật khẩu",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập mật khẩu';
                      return null;
                    },
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
                  _isLoading
                      ? const Center(child: CustomLoading())
                      : PrimaryButton(
                          text: "Đăng nhập",
                          width: double.infinity,
                          height: 56,
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                          onPressed: _login,
                        ),

                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/register");
                      },
                      child: const Text("Chưa có tài khoản?"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
