import 'package:iam/core/constant/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/network/dio_client.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/models/user_model.dart';
import '../cubit/user_info_cubit.dart';
import '../../notifications/cubit/notifications_cubit.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<UserInfoCubit>()..checkAuth()),
        BlocProvider.value(value: di.sl<NotificationsCubit>()),
      ],
      child: BlocListener<UserInfoCubit, UserInfoState>(
        listener: (context, state) {
          if (state is UserInfoSuccess) {
            context.read<NotificationsCubit>().updateNotificationsFromUser(
              state.user,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: Text(AppTexts.myAccount),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: BlocBuilder<UserInfoCubit, UserInfoState>(
            builder: (context, state) {
              if (state is UserInfoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is UserInfoFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.greyTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<UserInfoCubit>().checkAuth();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is UserInfoSuccess) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoSection(state.user),
                      SizedBox(height: 32.h),
                      _buildOrdersSection(context, state.orders),
                      SizedBox(height: 32.h),
                      _buildProductsForSaleSection(
                        context,
                        state.productsForSale,
                      ),
                      SizedBox(height: 32.h),
                      _buildDeleteAccountSection(context),
                      SizedBox(height: 28.h),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(UserModel user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.textFieldBorderColor,
            backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                ? CachedNetworkImageProvider(user.avatar!)
                : null,
            child: user.avatar == null || user.avatar!.isEmpty
                ? Icon(
                    Icons.person,
                    color: AppColors.greyTextColor,
                    size: 40.sp,
                  )
                : null,
          ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 16.sp,
                color: AppColors.greyTextColor,
              ),
              SizedBox(width: 8.w),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16.sp,
                color: AppColors.greyTextColor,
              ),
              SizedBox(width: 8.w),
              Text(
                user.phone,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(BuildContext context, List<dynamic> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orders,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackTextColor,
          ),
        ),
        SizedBox(height: 16.h),
        if (orders.isEmpty)
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: AppColors.overlayColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64.sp,
                  color: AppColors.greyTextColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.noOrdersYet,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.greyTextColor,
                  ),
                ),
              ],
            ),
          )
        else
          ...orders.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            return _buildOrderCard(context, order, index);
          }).toList(),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order, int index) {
    String orderId = '';
    String orderNumber = '';
    String orderStatus = '';
    String orderDate = '';
    String? orderTotal;

    if (order is Map) {
      orderId =
          order['id']?.toString() ?? order['orderId']?.toString() ?? 'N/A';
      orderNumber =
          order['order_number']?.toString() ??
          order['orderNumber']?.toString() ??
          orderId;
      orderStatus =
          order['status']?.toString() ??
          order['orderStatus']?.toString() ??
          'Unknown';
      orderDate =
          order['createdAt']?.toString() ??
          order['date']?.toString() ??
          order['created_at']?.toString() ??
          '';
      orderTotal =
          order['total']?.toString() ??
          order['amount']?.toString() ??
          order['price']?.toString();
    } else {
      orderId = order.toString();
      orderNumber = orderId;
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.orderDetails,
          arguments: {'orderNumber': orderNumber},
        );
        if (!context.mounted) return;
        if (result == true) {
          final cubit = context.read<UserInfoCubit>();
          if (!cubit.isClosed) {
            cubit.checkAuth();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$orderId',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackTextColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(orderStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    orderStatus,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _getStatusColor(orderStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (orderDate.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14.sp,
                    color: AppColors.greyTextColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    orderDate.length > 20
                        ? orderDate.substring(0, 20)
                        : orderDate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ],
              ),
            ],
            if (orderTotal != null) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                  Text(
                    orderTotal,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsForSaleSection(
    BuildContext context,
    List<dynamic> productsForSale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.productsForSale,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackTextColor,
          ),
        ),
        SizedBox(height: 16.h),
        if (productsForSale.isEmpty)
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: AppColors.overlayColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 64.sp,
                  color: AppColors.greyTextColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.noProductsForSale,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.greyTextColor,
                  ),
                ),
              ],
            ),
          )
        else
          ...productsForSale.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return _buildProductForSaleCard(context, product, index);
          }).toList(),
      ],
    );
  }

  Widget _buildProductForSaleCard(
    BuildContext context,
    dynamic product,
    int index,
  ) {
    int? productId;
    String? productNumber;
    String productName = '';
    String? productImage;
    String? productPrice;

    if (product is Map) {
      productId =
          product['id'] as int? ??
          product['product_id'] as int? ??
          product['card_id'] as int? ??
          (product['id'] != null
              ? int.tryParse(product['id'].toString())
              : null) ??
          (product['product_id'] != null
              ? int.tryParse(product['product_id'].toString())
              : null) ??
          (product['card_id'] != null
              ? int.tryParse(product['card_id'].toString())
              : null);

      productNumber =
          product['product_number']?.toString() ??
          product['productNumber']?.toString();

      productName =
          product['name']?.toString() ??
          product['product_name']?.toString() ??
          product['title']?.toString() ??
          'Product ${index + 1}';

      productImage =
          product['image']?.toString() ?? product['product_image']?.toString();

      productPrice =
          product['price']?.toString() ?? product['product_price']?.toString();
    }

    if (productId == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: {
            'productId': productId,
            'isForSale': true,
            'productNumber': productNumber,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.textFieldBorderColor),
        ),
        child: Row(
          children: [
            if (productImage != null && productImage.isNotEmpty)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.overlayColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: productImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.textFieldBorderColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image_outlined,
                      color: AppColors.greyTextColor,
                      size: 32.sp,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.overlayColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.greyTextColor,
                  size: 32.sp,
                ),
              ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (productNumber != null && productNumber.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${AppTexts.productNumber}: $productNumber',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ],
                  if (productPrice != null && productPrice.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      productPrice,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.greyTextColor,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  Widget _buildDeleteAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        SizedBox(height: 16.h),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: () => _confirmDeleteAccount(context),
          child: Text(
            AppTexts.deleteAccount,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTexts.deleteAccountConfirmationTitle),
        content: Text(AppTexts.deleteAccountConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppTexts.close),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppTexts.deleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<UserInfoCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await cubit.deleteAccount();
    if (!context.mounted) return;

    if (result == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppTexts.deleteAccountSuccess),
          backgroundColor: Colors.green,
        ),
      );

      await di.sl<StorageService>().clearAuthData();
      di.sl<DioClient>().clearAuthToken();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }
}
