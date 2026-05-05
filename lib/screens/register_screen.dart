import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/custom_textfield.dart';
import 'package:app_do_an_nhanh/widgets/primary_button.dart';
import 'package:app_do_an_nhanh/widgets/custom_loading.dart';
import 'package:app_do_an_nhanh/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerWithEmailPassword(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        // Registration success + Login done, navigate to main
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
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                      "Đăng ký",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Field
                  CustomTextfield(
                    controller: _nameController,
                    hintText: "Họ và tên",
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập họ và tên'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // Phone Field
                  CustomTextfield(
                    controller: _phoneController,
                    hintText: "Số điện thoại",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập số điện thoại'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // Address Field
                  CustomTextfield(
                    controller: _addressController,
                    hintText: "Địa chỉ",
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Vui lòng nhập địa chỉ'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  CustomTextfield(
                    controller: _emailController,
                    hintText: "Email",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng nhập email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
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
                    validator: (value) => value != null && value.length < 6
                        ? 'Mật khẩu phải có ít nhất 6 ký tự'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  CustomTextfield(
                    controller: _confirmPasswordController,
                    hintText: "Xác Nhận Mật khẩu",
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Vui lòng xác nhận mật khẩu';
                      if (value != _passwordController.text)
                        return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Register Button
                  _isLoading
                      ? const Center(child: CustomLoading())
                      : PrimaryButton(
                          text: "Đăng ký",
                          width: double.infinity,
                          height: 56,
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                          onPressed: _register,
                        ),

                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text("Đã có tài khoản?"),
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
