import 'dart:io';

import 'package:iam/core/constant/app_texts.dart';
import 'package:iam/core/services/pick_avater.dart';
import 'package:iam/core/di/inject.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/pick_option.dart';
import '../cubit/signup_cubit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  File? _avatarFile;
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  String? _selectedCountry;
  bool _acceptedTerms = false;
  CountryCode _selectedCountryCode = CountryCode.fromCode(
    'AE',
  ); // Default to UAE


  final List<String> _arabCountries = [
    'المغرب',
    'الجزائر',
    'تونس',
    'ليبيا',
    'مصر',
    'السودان',
    'السعودية',
    'الأردن',
    'البحرين',
    'سوريا',
    'العراق',
    'الكويت',
    'قطر',
    'الإمارات',
    'سلطنة عمان',
    'اليمن',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleSignup(SignupCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.passwordsDoNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.pleaseSelectCountry),
          backgroundColor: Colors.red,
        ),
      );
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

    // Combine country code with phone number
    final fullPhoneNumber =
        '${_selectedCountryCode.dialCode}${_phoneController.text.trim()}';

    cubit.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: fullPhoneNumber,
      password: _passwordController.text,
      age: _ageController.text.trim(),
      gender: _selectedGender ?? '',
      country: _selectedCountry ?? '',
      city: _cityController.text.trim(),
      avatar: _avatarFile,
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    if (!mounted) {
      debugPrint('_pickAvatar: Widget not mounted');
      return;
    }

    debugPrint('_pickAvatar: Starting to pick avatar from ${source == ImageSource.camera ? "camera" : "gallery"}');
    
    try {
      final File? file = await PickAvatarService.pickAvatar(
        source,
        context: context,
      );

      debugPrint('_pickAvatar: File picked: ${file != null}');
      
      if (mounted && file != null) {
      setState(() => _avatarFile = file);
      } else if (!mounted) {
        debugPrint('_pickAvatar: Widget unmounted after picking');
      } else {
        debugPrint('_pickAvatar: No file selected');
      }
    } catch (e, stackTrace) {
      debugPrint('_pickAvatar Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPickSheet() {
    final isIPad =
        Platform.isIOS && (MediaQuery.of(context).size.shortestSide >= 600);

    if (isIPad) {
      showCupertinoModalPopup(
        context: context,
        builder: (popupContext) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(popupContext);
                debugPrint('Camera button pressed on iPad');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    debugPrint('Calling _pickAvatar for camera');
                    _pickAvatar(ImageSource.camera);
                  } else {
                    debugPrint('Widget not mounted, cannot pick avatar');
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_outlined, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(AppTexts.camera),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(popupContext);
                debugPrint('Gallery button pressed on iPad');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    debugPrint('Calling _pickAvatar for gallery');
                    _pickAvatar(ImageSource.gallery);
                  } else {
                    debugPrint('Widget not mounted, cannot pick avatar');
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(AppTexts.gallery),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(popupContext),
            child: Text(AppTexts.cancel),
          ),
        ),
      );
    } else {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PickOption(
                icon: Icons.photo_camera_outlined,
                label: AppTexts.camera,
                onTap: () {
                  Navigator.pop(context);
                    debugPrint('Camera button pressed');
                    Future.delayed(const Duration(milliseconds: 300)).then((_) {
                      if (mounted) {
                        debugPrint('Calling _pickAvatar for camera');
                  _pickAvatar(ImageSource.camera);
                      }
                    });
                },
              ),
              PickOption(
                icon: Icons.photo_library_outlined,
                label: AppTexts.gallery,
                onTap: () {
                  Navigator.pop(context);
                    debugPrint('Gallery button pressed');
                    Future.delayed(const Duration(milliseconds: 300)).then((_) {
                      if (mounted) {
                        debugPrint('Calling _pickAvatar for gallery');
                  _pickAvatar(ImageSource.gallery);
                      }
                    });
                },
              ),
            ],
          ),
        ),
      ),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SignupCubit>(),
      child: BlocListener<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.accountCreatedSuccess),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to OTP screen with email
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.verifyOtp,
              arguments: {'email': _emailController.text.trim()},
            );
          } else if (state is SignupFailure) {
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
                AppTexts.createAcc,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20.h),
                        Center(
                          child: GestureDetector(
                            onTap: _showPickSheet,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120.w,
                                  height: 120.w,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.brandGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 50,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: _avatarFile == null
                                      ? Icon(
                                          Icons.person,
                                          color: AppColors.textOnPrimary,
                                          size: 60.sp,
                                        )
                                      : ClipOval(
                                          child: Image.file(
                                            _avatarFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.accentGradient,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.surface,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: AppColors.textOnPrimary,
                                      size: 18.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        AppTextField(
                          controller: _nameController,
                          hint: AppTexts.fullName,
                          leadingIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTexts.pleaseEnterName;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
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
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: CountryCodePicker(
                                onChanged: (CountryCode countryCode) {
                                  setState(() {
                                    _selectedCountryCode = countryCode;
                                  });
                                },
                                initialSelection: 'AE',
                                favorite: ['+971', 'AE'],
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                textStyle: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                dialogTextStyle: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15.sp,
                                ),
                                flagWidth: 24.w,
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                boxDecoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: AppTextField(
                                controller: _phoneController,
                                hint: AppTexts.phone,
                                keyboardType: TextInputType.phone,
                                leadingIcon: Icons.phone_outlined,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return AppTexts.pleaseEnterPhone;
                                //   }
                                //   return null;
                                // },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
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
                            if (value.length < 6) {
                              return AppTexts.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
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
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        AppTextField(
                          controller: _ageController,
                          hint: '${AppTexts.age} (21-55)',
                          keyboardType: TextInputType.number,
                          leadingIcon: Icons.calendar_today_outlined,
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return AppTexts.pleaseEnterAge;
                          //   }
                          //   final age = int.tryParse(value);
                          //   if (age == null || age < 21 || age > 55) {
                          //     return AppTexts.ageRange;
                          //   }
                          //   return null;
                          // },
                        ),
                        SizedBox(height: 20.h),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            hintText: AppTexts.gender,
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 15.sp,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.textSecondary,
                              size: 22.sp,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: 'male',
                              child: Text(AppTexts.male),
                            ),
                            DropdownMenuItem<String>(
                              value: 'female',
                              child: Text(AppTexts.female),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return AppTexts.pleaseSelectGender;
                          //   }
                          //   return null;
                          // },
                        ),
                        SizedBox(height: 20.h),
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: InputDecoration(
                            hintText: AppTexts.country,
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 15.sp,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            prefixIcon: Icon(
                              Icons.public_outlined,
                              color: AppColors.textSecondary,
                              size: 22.sp,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _arabCountries.map((country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountry = value;
                            });
                          },
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return AppTexts.pleaseSelectCountry;
                          //   }
                          //   return null;
                          // },
                        ),
                        SizedBox(height: 20.h),
                        AppTextField(
                          controller: _cityController,
                          hint: AppTexts.city,
                          leadingIcon: Icons.location_city_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTexts.pleaseEnterCity;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptedTerms = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptedTerms = !_acceptedTerms;
                                  });
                                },
                                child: Text(
                                  AppTexts.acceptTermsAndConditions,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                        BlocBuilder<SignupCubit, SignupState>(
                          builder: (context, state) {
                            final isLoading = state is SignupLoading;
                            return PrimaryButton(
                              title: isLoading
                                  ? AppTexts.creating
                                  : AppTexts.createAcc,
                              onPressed: isLoading
                                  ? null
                                  : () => _handleSignup(
                                      context.read<SignupCubit>(),
                                    ),
                              isLoading: isLoading,
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
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
