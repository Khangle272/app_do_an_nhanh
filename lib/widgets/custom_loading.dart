import 'package:flutter/material.dart';
import 'package:app_do_an_nhanh/utils/app_colors.dart';

class CustomLoading extends StatelessWidget {
  final double size;

  const CustomLoading({super.key, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
