import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/services/auth_service.dart';
import '../../settings/cubit/update_profile_cubit.dart';
import '../../settings/ui/update_profile_tab.dart';
import '../cubit/order_cubit.dart';
import '../models/create_order_request_model.dart';
import '../models/order_card_model.dart';
import '../models/check_auth_response_model.dart';
import '../../cart/models/cart_item_model.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final String _paymentMethod = 'card';
  String _paymentType = 'cash';
  int? _selectedInstallmentMonths;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  double _calculateOriginalTotal() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      final product = item.card;
      final quantity = item.quantity;
      final price = double.tryParse(product.price) ?? 0.0;
      total += price * quantity;
    }
    return total;
  }

  double _getIncreaseRate(int months) {
    if (months >= 6 && months <= 12) {
      return 0.15; // 15%
    } else if (months >= 18 && months <= 24) {
      return 0.20; // 20%
    } else if (months >= 30 && months <= 36) {
      return 0.25; // 25%
    }
    return 0.0;
  }

  double _calculateTotalAmount() {
    final originalTotal = _calculateOriginalTotal();
    if (_paymentType == 'installment' && _selectedInstallmentMonths != null) {
      final increaseRate = _getIncreaseRate(_selectedInstallmentMonths!);
      final increaseAmount = originalTotal * increaseRate;
      return originalTotal + increaseAmount;
    }
    return originalTotal;
  }

  Future<void> _checkAuthAndSubmitOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paymentType == 'installment' && _selectedInstallmentMonths == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.selectInstallmentMonths),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = di.sl<AuthService>();
      final response = await authService.checkAuth();

      if (!context.mounted) return;
      Navigator.pop(context);

      final checkAuthResponse = CheckAuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      final user = checkAuthResponse.data;

      if (!user.active) {
        if (user.idImage == null || user.idImage!.isEmpty) {
          await _showMissingIdImageDialog(context);
          return;
        }

        final missingBankStatement =
            user.bankStatementImage == null || user.bankStatementImage!.isEmpty;
        final missingInvoice =
            user.invoiceImage == null || user.invoiceImage!.isEmpty;

        if (missingBankStatement || missingInvoice) {
          await _showMissingImagesDialog(
            context,
            missingBankStatement,
            missingInvoice,
          );
          return;
        }

        await _showDataUnderReviewDialog(context);
        return;
      }

      _createOrder(context);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      String errorMessage = 'An error occurred. Please try again.';
      if (e is DioException) {
        if (e.response != null) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _createOrder(BuildContext context) {
    final cards = widget.cartItems.map((item) {
      return OrderCardModel(id: item.cardId, qty: item.quantity);
    }).toList();

    final originalTotal = _calculateOriginalTotal();
    double? increaseRate;
    double? totalAmount;

    if (_paymentType == 'installment' && _selectedInstallmentMonths != null) {
      increaseRate = _getIncreaseRate(_selectedInstallmentMonths!);
      totalAmount = originalTotal + (originalTotal * increaseRate);
    } else if (_paymentType == 'cash') {
      totalAmount = originalTotal;
    }

    final orderData = CreateOrderRequestModel(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      paymentMethod: _paymentMethod,
      promoCode: _promoCodeController.text.trim().isEmpty
          ? null
          : _promoCodeController.text.trim(),
      paymentType: _paymentType,
      installmentMonths: _selectedInstallmentMonths,
      increaseRate: increaseRate,
      totalAmount: totalAmount,
      cards: cards,
    );

    context.read<OrderCubit>().createOrder(orderData);
  }

  Future<void> _showMissingIdImageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppTexts.updateYourData,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          AppTexts.pleaseUpdateYourData,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppTexts.cancel,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToUpdateProfile(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              AppTexts.goToUpdateProfile,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMissingImagesDialog(
    BuildContext context,
    bool missingBankStatement,
    bool missingInvoice,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppTexts.uploadMissingImages,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          AppTexts.pleaseUploadMissingImages,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppTexts.cancel,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _navigateToUpdateProfile(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              AppTexts.goToUpdateProfile,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDataUnderReviewDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppTexts.dataUnderReview,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: Text(
          AppTexts.dataUnderReviewMessage,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              AppTexts.ok,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUpdateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<UpdateProfileCubit>(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.horizontalGradient.createShader(bounds),
                child: Text(
                  AppTexts.updateProfile,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const UpdateProfileTab(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderCubit>(),
      child: BlocListener<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
          } else if (state is OrderFailure) {
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
          appBar: AppBar(
            title: Text(AppTexts.checkout),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.contactInformation,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _emailController,
                      hint: AppTexts.email,
                      keyboardType: TextInputType.emailAddress,
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
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _phoneController,
                      hint: AppTexts.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTexts.pleaseEnterPhone;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppTexts.shippingAddress,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _addressLineController,
                      hint: AppTexts.addressLine,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTexts.pleaseEnterAddress;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _cityController,
                            hint: AppTexts.city,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppTexts.pleaseEnterCity;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AppTextField(
                            controller: _stateController,
                            hint: AppTexts.state,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppTexts.pleaseEnterState;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _zipCodeController,
                      hint: AppTexts.zipCode,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTexts.pleaseEnterZipCode;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      AppTexts.paymentMethod,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _paymentType = 'cash';
                                _selectedInstallmentMonths = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(
                                gradient: _paymentType == 'cash'
                                    ? AppColors.primaryGradient
                                    : null,
                                color: _paymentType == 'cash'
                                    ? null
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: _paymentType == 'cash'
                                      ? Colors.transparent
                                      : AppColors.border,
                                  width: _paymentType == 'cash' ? 0 : 1.5,
                                ),
                                boxShadow: _paymentType == 'cash'
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.money,
                                    color: _paymentType == 'cash'
                                        ? AppColors.textOnPrimary
                                        : AppColors.textSecondary,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    AppTexts.cash,
                                    style: TextStyle(
                                      color: _paymentType == 'cash'
                                          ? AppColors.textOnPrimary
                                          : AppColors.textSecondary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _paymentType = 'installment';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(
                                gradient: _paymentType == 'installment'
                                    ? AppColors.primaryGradient
                                    : null,
                                color: _paymentType == 'installment'
                                    ? null
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: _paymentType == 'installment'
                                      ? Colors.transparent
                                      : AppColors.border,
                                  width: _paymentType == 'installment'
                                      ? 0
                                      : 1.5,
                                ),
                                boxShadow: _paymentType == 'installment'
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: _paymentType == 'installment'
                                        ? AppColors.textOnPrimary
                                        : AppColors.textSecondary,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    AppTexts.installment,
                                    style: TextStyle(
                                      color: _paymentType == 'installment'
                                          ? AppColors.textOnPrimary
                                          : AppColors.textSecondary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_paymentType == 'installment') ...[
                      SizedBox(height: 24.h),
                      Text(
                        AppTexts.selectInstallmentMonths,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<int>(
                        value: _selectedInstallmentMonths,
                        decoration: InputDecoration(
                          hintText: AppTexts.installmentMonths,
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
                            Icons.calendar_today,
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
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        items: [
                          // 6-12 months (15% increase)
                          for (int i = 6; i <= 12; i++)
                            DropdownMenuItem<int>(
                              value: i,
                              child: Text('$i ${AppTexts.months}'),
                            ),
                          // 18-24 months (20% increase)
                          for (int i = 18; i <= 24; i += 6)
                            DropdownMenuItem<int>(
                              value: i,
                              child: Text('$i ${AppTexts.months}'),
                            ),
                          // 30-36 months (25% increase)
                          for (int i = 30; i <= 36; i += 6)
                            DropdownMenuItem<int>(
                              value: i,
                              child: Text('$i ${AppTexts.months}'),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedInstallmentMonths = value;
                          });
                        },
                      ),
                      if (_selectedInstallmentMonths != null) ...[
                        SizedBox(height: 24.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.totalAmount,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTexts.originalAmount,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    '${_calculateOriginalTotal().toStringAsFixed(2)} ${AppTexts.eGP}',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTexts.increaseAmount,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    '${(_calculateOriginalTotal() * _getIncreaseRate(_selectedInstallmentMonths!)).toStringAsFixed(2)} ${AppTexts.eGP}',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Divider(color: AppColors.border),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTexts.totalAmount,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${_calculateTotalAmount().toStringAsFixed(2)} ${AppTexts.eGP}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    SizedBox(height: 24.h),

                    Text(
                      AppTexts.promoCodeOptional,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _promoCodeController,
                      hint: AppTexts.enterPromoCode,
                    ),
                    SizedBox(height: 32.h),

                    BlocBuilder<OrderCubit, OrderState>(
                      builder: (context, state) {
                        final isLoading = state is OrderLoading;
                        return PrimaryButton(
                          title: isLoading
                              ? AppTexts.processing
                              : AppTexts.placeOrder,
                          onPressed: isLoading
                              ? null
                              : () => _checkAuthAndSubmitOrder(context),
                          isLoading: isLoading,
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
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
