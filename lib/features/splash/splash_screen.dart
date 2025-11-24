import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_assets.dart';
import '../../core/constant/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../core/di/inject.dart' as di;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      final storageService = di.sl<StorageService>();
      final token = storageService.getToken();

      if (token != null && token.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.splashBackground,
              AppColors.backgroundLight,
              AppColors.splashBackground,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100.h,
              left: -100.w,
              child: Container(
                width: 300.w,
                height: 300.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150.h,
              right: -150.w,
              child: Container(
                width: 400.w,
                height: 400.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.15),
                      AppColors.accent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(28.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 50,
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.newLogoDark,
                            width: 140.w,
                            height: 140.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // SizedBox(height: 40.h),
                      // ShaderMask(
                      //   shaderCallback: (bounds) =>
                      //       AppColors.horizontalGradient.createShader(bounds),
                      //   child: Text(
                      //     'IAM',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 48.sp,
                      //       fontWeight: FontWeight.w900,
                      //       letterSpacing: 3,
                      //       height: 1.2,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
