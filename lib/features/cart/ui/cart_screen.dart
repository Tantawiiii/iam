import 'package:iam/core/constant/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/cart_cubit.dart';
import '../../home/services/products_service.dart';
import '../models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  final Map<int, String> _selectedColorByCartItemId = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final storageService = di.sl<StorageService>();
        final token = storageService.getToken();
        final hasToken = token != null && token.isNotEmpty;
        if (hasToken) {
          context.read<CartCubit>().getCart();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      final storageService = di.sl<StorageService>();
      final token = storageService.getToken();
      final hasToken = token != null && token.isNotEmpty;
      if (hasToken) {
        context.read<CartCubit>().getCart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageCubit>();
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartInitial) {
          final storageService = di.sl<StorageService>();
          final token = storageService.getToken();
          final hasToken = token != null && token.isNotEmpty;
          if (hasToken) {
            context.read<CartCubit>().getCart();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.horizontalGradient.createShader(bounds),
            child: Text(
              AppTexts.cart,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartInitial || state is CartLoading) {
              return _buildCartShimmer();
            }

            if (state is CartFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        final storageService = di.sl<StorageService>();
                        final token = storageService.getToken();
                        final hasToken = token != null && token.isNotEmpty;
                        if (hasToken) {
                          context.read<CartCubit>().getCart();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 14.h,
                        ),
                      ),
                      child: Text(
                        AppTexts.retry,
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is CartSuccess) {
              final cartItems = state.response.data;

              if (cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(32.w),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.textOnPrimary,
                          size: 64.sp,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        AppTexts.cartEmpty,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        AppTexts.addItemsToCart,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        return _buildCartItem(cartItem);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTexts.total,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                _calculateTotal(cartItems),
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                final itemColors = cartItems.map((item) {
                                  return _selectedColorByCartItemId[item.id] ??
                                      item.color ??
                                      (item.card.colorList.isNotEmpty
                                          ? item.card.colorList.first
                                          : '');
                                }).toList();
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.checkout,
                                  arguments: {
                                    'cartItems': cartItems,
                                    'itemColors': itemColors,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 18.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Text(
                                AppTexts.checkout,
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100.h),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItemModel cartItem) {
    final product = cartItem.card;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: product.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: product.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_outlined,
                        color: AppColors.textTertiary,
                        size: 30.sp,
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_outlined,
                    color: AppColors.textTertiary,
                    size: 30.sp,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${product.price} ${product.currency}',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                // if (product.colorList.isNotEmpty) ...[
                //   SizedBox(height: 8.h),
                //   _buildColorSelector(cartItem),
                // ],
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onTap: () {
                        final color = _selectedColorByCartItemId[cartItem.id] ??
                            cartItem.color;
                        _updateQuantity(cartItem.cardId, 'minus', color: color);
                      },
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        cartItem.quantity.toString(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onTap: () {
                        final color = _selectedColorByCartItemId[cartItem.id] ??
                            cartItem.color;
                        _updateQuantity(cartItem.cardId, 'plus', color: color);
                      },
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _updateQuantity(
                            cartItem.cardId,
                            'delete',
                            color: cartItem.color,
                          );
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(CartItemModel cartItem) {
    final product = cartItem.card;
    final colors = product.colorList;
    if (colors.isEmpty) return const SizedBox.shrink();
    final selected =
        _selectedColorByCartItemId[cartItem.id] ?? cartItem.color ?? colors.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppTexts.color}:',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: colors.map((colorName) {
            final isSelected = selected == colorName;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorByCartItemId[cartItem.id] = colorName;
                });
                _updateQuantity(
                  cartItem.cardId,
                  'add',
                  color: colorName,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  colorName,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textOnPrimary, size: 18.sp),
      ),
    );
  }

  void _updateQuantity(int cardId, String method, {String? color}) async {
    final storageService = di.sl<StorageService>();
    final token = storageService.getToken();
    final hasToken = token != null && token.isNotEmpty;

    if (!hasToken) return;

    final productsService = di.sl<ProductsService>();
    try {
      await productsService.addToCart(
        productId: cardId,
        method: method,
        color: color,
      );
      if (mounted) {
        context.read<CartCubit>().getCart();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _calculateTotal(List<CartItemModel> cartItems) {
    double total = 0.0;
    String currency = AppTexts.eGP;

    for (var item in cartItems) {
      final product = item.card;
      final quantity = item.quantity;
      final price = double.tryParse(product.price) ?? 0.0;
      total += price * quantity;
      currency = product.currency;
    }

    return '${total.toStringAsFixed(2)} $currency';
  }

  Widget _buildCartShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: AppColors.textFieldBorderColor,
            highlightColor: AppColors.white,
            period: const Duration(milliseconds: 1200),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.overlayColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: AppColors.textFieldBorderColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 16.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.textFieldBorderColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 14.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: AppColors.textFieldBorderColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 12.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: AppColors.textFieldBorderColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
