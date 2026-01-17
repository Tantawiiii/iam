import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/contact_us_cubit.dart';

class ContactUsTab extends StatefulWidget {
  const ContactUsTab({super.key});

  @override
  State<ContactUsTab> createState() => _ContactUsTabState();
}

class _ContactUsTabState extends State<ContactUsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit(ContactUsCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.sendContactMessage(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      message: _messageController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageCubit>();
    
    // Debug: Print current language and text values
    debugPrint('ContactUsTab - Current Language: ${AppTexts.currentLanguage}');
    debugPrint('ContactUsTab - getInTouch: ${AppTexts.getInTouch}');
    debugPrint('ContactUsTab - contactUsSubtitle: ${AppTexts.contactUsSubtitle}');
    
    return BlocListener<ContactUsCubit, ContactUsState>(
      listener: (context, state) {
        if (state is ContactUsSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              contentPadding: EdgeInsets.all(24.w),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    state.response.message ?? AppTexts.messageSentSuccess,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackTextColor,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        AppTexts.ok,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _messageController.clear();
        } else if (state is ContactUsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                AppTexts.getInTouch,
                style: TextStyle(
                  color: AppColors.blackTextColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppTexts.contactUsSubtitle,
                style: TextStyle(
                  color: AppColors.greyTextColor,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 32.h),
            
              AppTextField(
                controller: _nameController,
                hint: AppTexts.name,
                leadingIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterName;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
          
              AppTextField(
                controller: _emailController,
                hint: AppTexts.email,
                leadingIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterEmail;
                  }
                  if (!value.contains('@')) {
                    return AppTexts.pleaseEnterValidEmail;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              
              AppTextField(
                controller: _phoneController,
                hint: AppTexts.phone,
                leadingIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterPhone;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
             
              AppTextField(
                controller: _messageController,
                hint: AppTexts.messageLabel,
                leadingIcon: Icons.message_outlined,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterMessage;
                  }
                  if (value.trim().length < 10) {
                    return AppTexts.messageMinLengthError;
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),
              // Submit Button
              BlocBuilder<ContactUsCubit, ContactUsState>(
                builder: (context, state) {
                  final isLoading = state is ContactUsLoading;
                  return PrimaryButton(
                    title: isLoading ? AppTexts.sending : AppTexts.sendMessage,
                    onPressed: isLoading
                        ? null
                        : () => _handleSubmit(
                              context.read<ContactUsCubit>(),
                            ),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

