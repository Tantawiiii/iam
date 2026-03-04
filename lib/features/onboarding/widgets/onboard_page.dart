

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../model/onboard_model.dart';

class OnboardPage extends StatelessWidget {
  const OnboardPage({super.key, required this.data});
  final OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: data.image.startsWith('http')
                    ? Image.network(
                        data.image,
                        width: 350.w,
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/onboarding1.png', // Fallback local image
                          width: 350.w,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                    : Image.asset(
                        data.image,
                        width: 350.w,
                        fit: BoxFit.fitHeight,
                      ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}