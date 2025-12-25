import 'package:iam/core/constant/app_texts.dart';
import 'package:iam/core/di/inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/reset_password_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword(ResetPasswordCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.resetPassword(
      email: widget.email,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ResetPasswordCubit>(),
      child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.passwordResetSuccess),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          } else if (state is ResetPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.horizontalGradient.createShader(bounds),
              child: Text(
                AppTexts.resetPassword,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.h),
                    Text(
                      AppTexts.resetPasswordTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppTexts.resetPasswordDescription,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
                    AppTextField(
                      controller: _passwordController,
                      hint: AppTexts.newPassword,
                      obscure: true,
                      obscurable: true,
                      leadingIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTexts.pleaseEnterNewPassword;
                        }
                        if (value.length < 6) {
                          return AppTexts.passwordMinLength;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _confirmPasswordController,
                      hint: AppTexts.confirmPassword,
                      obscure: true,
                      obscurable: true,
                      leadingIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTexts.pleaseConfirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return AppTexts.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),
                    BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                      builder: (context, state) {
                        final isLoading = state is ResetPasswordLoading;
                        return PrimaryButton(
                          title: isLoading
                              ? AppTexts.resettingPassword
                              : AppTexts.resetPassword,
                          onPressed: isLoading
                              ? null
                              : () => _handleResetPassword(
                                  context.read<ResetPasswordCubit>(),
                                ),
                          isLoading: isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
