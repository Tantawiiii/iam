import 'package:iam/core/constant/app_texts.dart';
import 'package:iam/core/di/inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp(ForgotPasswordCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.sendOtp(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForgotPasswordCubit>(),
      child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response['message']?.toString() ??
                    'OTP sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushNamed(
              AppRoutes.verifyOtp,
              arguments: {
                'email': state.email,
                'isPasswordReset': true,
              },
            );
          } else if (state is ForgotPasswordFailure) {
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
                AppTexts.forgetPassword,
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
                      AppTexts.forgetPassword,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppTexts.enter6DigitCodeSentToEmail,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
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
                    SizedBox(height: 32.h),
                    BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                      builder: (context, state) {
                        final isLoading = state is ForgotPasswordLoading;
                        return PrimaryButton(
                          title: isLoading
                              ? AppTexts.sendingOtp
                              : AppTexts.send,
                          onPressed: isLoading
                              ? null
                              : () => _handleSendOtp(
                                  context.read<ForgotPasswordCubit>(),
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
