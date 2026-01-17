

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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(
                  data.image,
                  width: 300.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
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
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}