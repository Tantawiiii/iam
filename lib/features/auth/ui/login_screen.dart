import 'package:iam/core/constant/app_texts.dart';
import 'package:iam/core/di/inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_assets.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/language_switcher.dart';
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
  bool _acceptedTerms = false;

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

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.pleaseAcceptTerms),
          backgroundColor: Colors.red,
        ),
      );
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
        child: BlocBuilder<LanguageCubit, Locale>(
          buildWhen: (prev, next) => prev != next,
          builder: (context, locale) {
            AppTexts.updateLocale(locale);
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 26.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 32.h),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: const LanguageSwitcher(compact: true),
                      ),
                      SizedBox(height: 16.h),
                      ClipOval(
                    child: Image.asset(
                      AppAssets.newLogoDark,
                      width: 140.w,
                      height: 140.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 30.h),
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
                  SizedBox(height: 12.h),
                  Text(
                    AppTexts.loginToCont,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 26.h),
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
                  SizedBox(height: 14.h),
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
                  SizedBox(height: 8.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                      ),
                      child: Text(
                        AppTexts.forgetPassword,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      AppTexts.currentLanguage ==
                                          AppLanguage.ar
                                      ? 'أوافق على '
                                      : 'I accept the ',
                                ),
                                TextSpan(
                                  text: AppTexts.termsAndConditions,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.termsAndConditions,
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      final isLoading = state is LoginLoading;
                      return PrimaryButton(
                        title: isLoading
                            ? AppTexts.loginLoading
                            : AppTexts.login,
                        onPressed: isLoading
                            ? null
                            : () =>
                                  _handleLogin(context.read<LoginCubit>()),
                        isLoading: isLoading,
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 8.h),
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
        );
          },
        ),
      ),
    );
  }
}
