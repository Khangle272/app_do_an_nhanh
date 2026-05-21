import 'package:app_do_an_nhanh/utils/app_colors.dart';
import 'package:app_do_an_nhanh/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final Future<void> Function()? onCompleted;

  const OnboardingScreen({super.key, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    size: 90,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  "Đồ ăn nhanh",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Khám phá các món ăn nhanh ngon và rẻ",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textMain,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: "Bắt đầu",
                  onPressed: () async {
                    if (onCompleted != null) {
                      await onCompleted!();
                      return;
                    }
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  width: double.infinity,
                  height: 56,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
