import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/services/pick_avater.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/di/inject.dart' as di;
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/pick_option.dart';
import '../cubit/update_profile_cubit.dart';

class UpdateProfileTab extends StatefulWidget {
  const UpdateProfileTab({super.key});

  @override
  State<UpdateProfileTab> createState() => _UpdateProfileTabState();
}

class _UpdateProfileTabState extends State<UpdateProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  File? _avatarFile;
  File? _idImageFile;
  File? _bankStatementImageFile;
  File? _invoiceImageFile;
  String? _currentAvatarUrl;
  String? _currentIdImageUrl;
  String? _currentBankStatementImageUrl;
  String? _currentInvoiceImageUrl;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final storageService = di.sl<StorageService>();
    final user = storageService.getUser();
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _currentAvatarUrl = user.avatar;
      // Load new fields if available
      if (user.age != null) {
        _ageController.text = user.age.toString();
      }
      if (user.gender != null) {
        _selectedGender = user.gender;
      }
      if (user.country != null) {
        _countryController.text = user.country!;
      }
      if (user.city != null) {
        _cityController.text = user.city!;
      }
      _currentIdImageUrl = user.idImage;
      _currentBankStatementImageUrl = user.bankStatementImage;
      _currentInvoiceImageUrl = user.invoiceImage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final File? file = await PickAvatarService.pickAvatar(source);
    if (file != null) {
      setState(() => _avatarFile = file);
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File) onPicked) async {
    final File? file = await PickAvatarService.pickAvatar(source);
    if (file != null) {
      onPicked(file);
    }
  }

  void _showImagePickSheet(Function(File) onPicked) {
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
                  _pickImage(ImageSource.camera, onPicked);
                },
              ),
              PickOption(
                icon: Icons.photo_library_outlined,
                label: AppTexts.gallery,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, onPicked);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickSheet() {
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
                  _pickAvatar(ImageSource.camera);
                },
              ),
              PickOption(
                icon: Icons.photo_library_outlined,
                label: AppTexts.gallery,
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpdateProfile(UpdateProfileCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate required ID image
    if (_idImageFile == null &&
        (_currentIdImageUrl == null || _currentIdImageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.pleaseUploadIdImage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    cubit.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
      age: _ageController.text.trim(),
      gender: _selectedGender,
      country: _countryController.text.trim(),
      city: _cityController.text.trim(),
      avatar: _avatarFile,
      idImage: _idImageFile,
      bankStatementImage: _bankStatementImageFile,
      invoiceImage: _invoiceImageFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateProfileCubit, UpdateProfileState>(
      listener: (context, state) async {
        if (state is UpdateProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message),
              backgroundColor: Colors.green,
            ),
          );
          // Update stored user data
          final storageService = di.sl<StorageService>();
          await storageService.updateStoredUser(state.response.data);
          _nameController.text = state.response.data.name;
          _emailController.text = state.response.data.email;
          _phoneController.text = state.response.data.phone;
          if (state.response.data.age != null) {
            _ageController.text = state.response.data.age.toString();
          }
          _selectedGender = state.response.data.gender;
          if (state.response.data.country != null) {
            _countryController.text = state.response.data.country!;
          }
          if (state.response.data.city != null) {
            _cityController.text = state.response.data.city!;
          }
          if (mounted) {
            setState(() {
              _currentAvatarUrl = state.response.data.avatar;
              _currentIdImageUrl = state.response.data.idImage;
              _currentBankStatementImageUrl =
                  state.response.data.bankStatementImage;
              _currentInvoiceImageUrl = state.response.data.invoiceImage;
              _avatarFile = null;
              _idImageFile = null;
              _bankStatementImageFile = null;
              _invoiceImageFile = null;
            });
          }
          // Clear password fields
          _passwordController.clear();
          _confirmPasswordController.clear();
        } else if (state is UpdateProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _showPickSheet,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppColors.overlayColor,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (_currentAvatarUrl != null &&
                                _currentAvatarUrl!.isNotEmpty)
                          ? NetworkImage(_currentAvatarUrl!)
                          : null,
                      child:
                          _avatarFile == null &&
                              (_currentAvatarUrl == null ||
                                  _currentAvatarUrl!.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 60.sp,
                              color: AppColors.greyTextColor,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
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
                controller: _passwordController,
                hint: AppTexts.newPasswordOptional,
                leadingIcon: Icons.lock_outline,
                obscure: true,
                obscurable: true,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _confirmPasswordController,
                hint: AppTexts.confirmPassword,
                leadingIcon: Icons.lock_outline,
                obscure: true,
                obscurable: true,
                validator: (value) {
                  if (_passwordController.text.isNotEmpty &&
                      (value == null || value != _passwordController.text)) {
                    return AppTexts.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _ageController,
                hint: AppTexts.age,
                keyboardType: TextInputType.number,
                leadingIcon: Icons.calendar_today_outlined,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 120) {
                      return AppTexts.validAge;
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              // Gender
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
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
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
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _countryController,
                hint: AppTexts.country,
                leadingIcon: Icons.public_outlined,
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _cityController,
                hint: AppTexts.city,
                leadingIcon: Icons.location_city_outlined,
              ),
              SizedBox(height: 24.h),
              _buildImagePicker(
                title: AppTexts.idImage,
                required: true,
                file: _idImageFile,
                currentUrl: _currentIdImageUrl,
                onTap: () => _showImagePickSheet((file) {
                  setState(() => _idImageFile = file);
                }),
              ),
              SizedBox(height: 16.h),

              _buildImagePicker(
                title: AppTexts.bankStatementImage,
                required: false,
                file: _bankStatementImageFile,
                currentUrl: _currentBankStatementImageUrl,
                onTap: () => _showImagePickSheet((file) {
                  setState(() => _bankStatementImageFile = file);
                }),
              ),
              SizedBox(height: 16.h),

              _buildImagePicker(
                title: AppTexts.invoiceImage,
                required: false,
                file: _invoiceImageFile,
                currentUrl: _currentInvoiceImageUrl,
                onTap: () => _showImagePickSheet((file) {
                  setState(() => _invoiceImageFile = file);
                }),
              ),
              SizedBox(height: 32.h),
              BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
                builder: (context, state) {
                  final isLoading = state is UpdateProfileLoading;
                  return PrimaryButton(
                    title: isLoading
                        ? AppTexts.updating
                        : AppTexts.updateProfile,
                    onPressed: isLoading
                        ? null
                        : () => _handleUpdateProfile(
                            context.read<UpdateProfileCubit>(),
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

  Widget _buildImagePicker({
    required String title,
    required bool required,
    required File? file,
    required String? currentUrl,
    required VoidCallback onTap,
  }) {
    final hasImage =
        file != null || (currentUrl != null && currentUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 14.sp),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: required && !hasImage ? Colors.red : AppColors.border,
                width: 1,
              ),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: file != null
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.network(
                                currentUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.broken_image,
                                    size: 40.sp,
                                    color: AppColors.textSecondary,
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap to upload',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (required && !hasImage) ...[
          SizedBox(height: 4.h),
          Text(
            AppTexts.pleaseUploadIdImage,
            style: TextStyle(color: Colors.red, fontSize: 12.sp),
          ),
        ],
      ],
    );
  }
}
