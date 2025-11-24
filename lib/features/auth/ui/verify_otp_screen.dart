import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/verify_otp_cubit.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerifyOtp(VerifyOtpCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.verifyOtp(email: widget.email, otp: _otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<VerifyOtpCubit>(),
      child: BlocListener<VerifyOtpCubit, VerifyOtpState>(
        listener: (context, state) {
          if (state is VerifyOtpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.otpVerifiedSuccess),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to login screen after successful verification
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          } else if (state is VerifyOtpFailure) {
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
                AppTexts.verifyOtp,
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
                    // Email display
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTexts.email,
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  widget.email,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8.w,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary.withOpacity(0.3),
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8.w,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTexts.pleaseEnterOtp;
                        }
                        if (value.length != 6) {
                          return AppTexts.otpMustBe6Digits;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      AppTexts.enter6DigitCodeSentToEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    BlocBuilder<VerifyOtpCubit, VerifyOtpState>(
                      builder: (context, state) {
                        final isLoading = state is VerifyOtpLoading;
                        return PrimaryButton(
                          title: isLoading
                              ? AppTexts.verifying
                              : AppTexts.verifyOtp,
                          onPressed: isLoading
                              ? null
                              : () => _handleVerifyOtp(
                                  context.read<VerifyOtpCubit>(),
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
