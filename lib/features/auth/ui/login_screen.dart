import 'package:iam/core/constant/app_texts.dart';
import 'package:iam/core/di/inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_assets.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(LoginCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.loginSuccess),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -100.h,
                  right: -100.w,
                  child: Container(
                    width: 300.w,
                    height: 300.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150.h,
                  left: -150.w,
                  child: Container(
                    width: 400.w,
                    height: 400.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.2),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppAssets.newLogoDark,
                              width: 110.w,
                              height: 120.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 50.h),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.horizontalGradient.createShader(bounds),
                          child: Text(
                            AppTexts.welcomeBack,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          AppTexts.loginToCont,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 56.h),
                        AppTextField(
                          controller: _emailController,
                          hint: AppTexts.email,
                          keyboardType: TextInputType.emailAddress,
                          leadingIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTexts.pleaseEnterEmail;
                            }
                            if (!value.contains('@')) {
                              return AppTexts.pleaseEnterValidEmail;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),
                        AppTextField(
                          controller: _passwordController,
                          hint: AppTexts.password,
                          obscure: true,
                          obscurable: true,
                          leadingIcon: Icons.lock_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTexts.pleaseEnterPass;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 40.h),
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final isLoading = state is LoginLoading;
                            return PrimaryButton(
                              title: isLoading
                                  ? AppTexts.loginLoading
                                  : AppTexts.login,
                              onPressed: isLoading
                                  ? null
                                  : () => _handleLogin(
                                      context.read<LoginCubit>(),
                                    ),
                              isLoading: isLoading,
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            AppTexts.continueAsGuest,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppTexts.dontHaveAcc,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            TextButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.signup),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => AppColors
                                    .horizontalGradient
                                    .createShader(bounds),
                                child: Text(
                                  AppTexts.signUp,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
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
