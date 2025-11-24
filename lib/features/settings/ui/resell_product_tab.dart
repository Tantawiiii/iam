import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../cubit/resell_product_cubit.dart';

class ResellProductTab extends StatefulWidget {
  const ResellProductTab({super.key});

  @override
  State<ResellProductTab> createState() => _ResellProductTabState();
}

class _ResellProductTabState extends State<ResellProductTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _productNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _productNumberController.dispose();
    super.dispose();
  }

  void _handleSubmit(ResellProductCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.resellProduct(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _convertArabicToEnglish(_priceController.text.trim()),
      productNumber: _productNumberController.text.trim(),
    );
  }

  String _convertArabicToEnglish(String text) {
    const arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };
    return text.split('').map((char) => arabicToEnglish[char] ?? char).join();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResellProductCubit, ResellProductState>(
      listener: (context, state) {
        if (state is ResellProductSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTexts.productSubmittedSuccess),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form
          _nameController.clear();
          _descriptionController.clear();
          _priceController.clear();
          _productNumberController.clear();
          _formKey.currentState?.reset();
          // Navigate back to previous page
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is ResellProductFailure) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                AppTexts.resellProduct,
                style: TextStyle(
                  color: AppColors.blackTextColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppTexts.resellProductSubtitle,
                style: TextStyle(
                  color: AppColors.greyTextColor,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 32.h),
              AppTextField(
                controller: _nameController,
                hint: AppTexts.name,
                leadingIcon: Icons.shopping_bag_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterProductName;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _descriptionController,
                hint: AppTexts.description,
                leadingIcon: Icons.description_outlined,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterDescription;
                  }
                  if (value.trim().length < 10) {
                    return AppTexts.descriptionMustBeAtLeast10Characters;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              AppTextField(
                controller: _priceController,
                hint: AppTexts.price,
                leadingIcon: Icons.attach_money_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[٠-٩0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterPrice;
                  }
                  final englishValue = _convertArabicToEnglish(value.trim());
                  final price = double.tryParse(englishValue);
                  if (price == null || price <= 0) {
                    return AppTexts.pleaseEnterValidPrice;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: _productNumberController,
                hint: AppTexts.productNumber,
                leadingIcon: Icons.numbers_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTexts.pleaseEnterProductNumber;
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),
              BlocBuilder<ResellProductCubit, ResellProductState>(
                builder: (context, state) {
                  final isLoading = state is ResellProductLoading;
                  return PrimaryButton(
                    title: isLoading ? AppTexts.submitting : AppTexts.submit,
                    onPressed: isLoading
                        ? null
                        : () =>
                              _handleSubmit(context.read<ResellProductCubit>()),
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
