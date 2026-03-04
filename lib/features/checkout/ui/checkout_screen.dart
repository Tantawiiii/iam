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
import '../../settings/models/check_auth_response_model.dart';
import '../../settings/ui/update_profile_tab.dart';
import '../cubit/order_cubit.dart';
import '../models/create_order_request_model.dart';
import '../models/create_order_data_model.dart';
import '../models/order_card_model.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';
import '../../cart/models/cart_item_model.dart';
import '../../home/services/products_service.dart';
import '../../../core/services/storage_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  /// Selected color per cart item (same order as cartItems). Optional.
  final List<String>? itemColors;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    this.itemColors,
  });

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
 // final _zipCodeController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final String _paymentMethod = 'card';
  String _paymentType = 'cash';
  int? _selectedInstallmentMonths;

  bool _isCheckingPromo = false;
  CouponModel? _appliedCoupon;
  String? _promoErrorMessage;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
    _promoCodeController.addListener(_onPromoCodeChanged);
  }

  void _onPromoCodeChanged() {
    if (_appliedCoupon != null || _promoErrorMessage != null) {
      setState(() {
        _appliedCoupon = null;
        _promoErrorMessage = null;
      });
    }
  }

  void _prefillUserData() {
    try {
      final storageService = di.sl<StorageService>();
      final user = storageService.getUser();
      if (user != null) {
        _emailController.text = user.email;
        _phoneController.text = user.phone;
      }
    } catch (e) {
      debugPrint('Error prefilling user data: $e');
    }
  }

  @override
  void dispose() {
    _promoCodeController.removeListener(_onPromoCodeChanged);
    _emailController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    //_zipCodeController.dispose();
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
    return 0.0;
  }

  double _calculateBaseTotal() {
    return _calculateOriginalTotal();
  }

  double _calculateTotalAmount() {
    final baseTotal = _calculateBaseTotal();
    if (_appliedCoupon == null) return baseTotal;
    final coupon = _appliedCoupon!;
    if (coupon.isPercentage) {
      final discount = baseTotal * (coupon.numericValue / 100);
      return (baseTotal - discount).clamp(0.0, double.infinity);
    }
    return (baseTotal - coupon.numericValue).clamp(0.0, double.infinity);
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _promoErrorMessage = AppTexts.invalidPromoCode;
      });
      return;
    }
    setState(() {
      _isCheckingPromo = true;
      _promoErrorMessage = null;
    });
    try {
      final couponService = di.sl<CouponService>();
      final coupon = await couponService.searchCoupon(code);
      if (!mounted) return;
      setState(() {
        _appliedCoupon = coupon;
        _isCheckingPromo = false;
        _promoErrorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.couponApplied),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : AppTexts.invalidPromoCode;
      setState(() {
        _appliedCoupon = null;
        _isCheckingPromo = false;
        _promoErrorMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
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

      if (_paymentType == 'installment' && !user.active) {

        await _showInstallmentEnrollmentDialog(context);
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
    final colors = widget.itemColors;
    final cards = widget.cartItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final color = (colors != null && index < colors.length)
          ? (colors[index].isEmpty ? null : colors[index])
          : null;
      return OrderCardModel(id: item.cardId, qty: item.quantity, color: color);
    }).toList();

    double? increaseRate;
    double totalAmount = _calculateTotalAmount();

    if (_paymentType == 'installment' && _selectedInstallmentMonths != null) {
      increaseRate = _getIncreaseRate(_selectedInstallmentMonths!);
    }

    final orderData = CreateOrderRequestModel(
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
   //   zipCode: _zipCodeController.text.trim(),
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

  Future<void> _showInstallmentEnrollmentDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: AppColors.horizontalGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.error_outline_sharp,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                AppTexts.vipFeatureTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppTexts.vipFeatureMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        AppTexts.cancel,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _navigateToVipProduct(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppTexts.subscribeToVipNow,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// جلب عرض VIP من /api/front/offers والانتقال لصفحة المنتج (product_id)
  Future<void> _navigateToVipProduct(BuildContext context) async {
    try {
      final productsService = di.sl<ProductsService>();
      final offersResponse = await productsService.getOffers();
      final vipList = offersResponse.data
          .where((offer) =>
              offer.product?.toUpperCase().contains('VIP') == true ||
              offer.product == 'VIP CARD')
          .toList();
      final vipOffer =
          vipList.isNotEmpty ? vipList.first : (offersResponse.data.isNotEmpty ? offersResponse.data.first : null);
      final productId = vipOffer?.productId;
      if (!context.mounted) return;
      if (productId != null) {
        Navigator.of(context).pushNamed(
          AppRoutes.productDetails,
          arguments: {
            'productId': productId,
            'isForSale': false,
            'productNumber': null,
          },
        );
      }
    } catch (_) {}
  }




  /// عند نجاح طلب التقسيط: نعرض دايالوج نجاح ثم نودي للصفحة الرئيسية
  Future<void> _showInstallmentOrderSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                AppTexts.orderSubmittedSuccessTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppTexts.orderSubmittedSuccessMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                      arguments: {'triggerRefresh': true},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    AppTexts.ok,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDataUnderReviewDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty_rounded,
                  color: Colors.amber,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                AppTexts.dataUnderReview,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppTexts.dataUnderReviewMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    AppTexts.ok,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            if (_paymentType == 'installment') {
              _showInstallmentOrderSuccessDialog(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.message),
                  backgroundColor: Colors.green,
                ),
              );
              final orderData = CreateOrderDataModel.fromResponseData(
                state.response.data,
              );
              if (orderData != null) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.checkoutSuccess,
                  (route) => route.settings.name == AppRoutes.home,
                  arguments: orderData,
                );
              } else {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
              }
            }
          } else if (state is OrderFailure) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            if (state.message.contains('installment') ||
                state.message.contains('active')) {
              _showInstallmentEnrollmentDialog(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
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
                    // SizedBox(height: 16.h),
                    // AppTextField(
                    //   controller: _zipCodeController,
                    //   hint: AppTexts.zipCode,
                    //   keyboardType: TextInputType.number,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return AppTexts.pleaseEnterZipCode;
                    //     }
                    //     return null;
                    //   },
                    // ),
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
                              padding: EdgeInsets.all(12.w),
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
                                    Flexible(
                                      child: Text(
                                        AppTexts.cash,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: _paymentType == 'cash'
                                              ? AppColors.textOnPrimary
                                              : AppColors.textSecondary,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _paymentType = 'installment';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(12.w),
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
                                    Flexible(
                                      child: Text(
                                        AppTexts.installment,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: _paymentType == 'installment'
                                              ? AppColors.textOnPrimary
                                              : AppColors.textSecondary,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                          for (int i = 6; i <= 12; i++)
                            DropdownMenuItem<int>(
                              value: i,
                              child: Text('$i ${AppTexts.months}'),
                            ),

                          for (int i = 18; i <= 24; i += 6)
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _promoCodeController,
                            hint: AppTexts.enterPromoCode,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        SizedBox(
                          width: 100.w,
                          child: PrimaryButton(
                            title: AppTexts.applyPromoCode,
                            onPressed: _isCheckingPromo ? null : _applyPromoCode,
                            isLoading: _isCheckingPromo,
                          ),
                        ),
                      ],
                    ),
                    if (_promoErrorMessage != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        _promoErrorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                    if (_appliedCoupon != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${_appliedCoupon!.code} (${_appliedCoupon!.isPercentage ? '${_appliedCoupon!.value}% off' : '${_appliedCoupon!.value} ${AppTexts.eGP} off'})',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
