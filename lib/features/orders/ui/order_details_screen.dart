import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/localization/language_cubit.dart';
import '../../../core/network/payment_service.dart';
import '../../../core/routing/app_routes.dart';
import '../cubit/order_details_cubit.dart';
import '../models/order_card_item_model.dart';
import '../models/order_details_model.dart';
import '../../../shared/widgets/primary_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderNumber;

  const OrderDetailsScreen({super.key, required this.orderNumber});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final PaymentService _paymentService = di.sl<PaymentService>();
  bool _isPaymentLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderDetailsCubit>()..getOrderDetails(widget.orderNumber),
      child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          context.watch<LanguageCubit>();

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              title: Text(
                '${AppTexts.order} #${widget.orderNumber}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Builder(
              builder: (context) {
                if (state is OrderDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OrderDetailsFailure) {
                  return _buildErrorState(context, state.message);
                }

                if (state is OrderDetailsSuccess) {
                  final order = state.order;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderInfoCard(order),
                        SizedBox(height: 20.h),
                        _buildAddressCard(order),
                        SizedBox(height: 20.h),
                        _buildPaymentCard(order),
                        if (order.invoicePdfUrl != null &&
                            order.invoicePdfUrl!.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          _buildInvoiceSection(context, order),
                        ],
                        SizedBox(height: 20.h),
                        _buildOrderItemsSection(context, order.cards),
                        SizedBox(height: 24.h),
                        _buildActionsSection(
                          context: context,
                          order: order,
                          isProcessing: state.isActionInProgress,
                        ),
                        SizedBox(height: 44.h),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: AppColors.greyTextColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<OrderDetailsCubit>().getOrderDetails(widget.orderNumber);
            },
            child: Text(AppTexts.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderDetailsModel order) {
    return Container(
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
                AppTexts.orderInformation,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackTextColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(AppTexts.orderNumberLabel, order.orderNumber),
          SizedBox(height: 12.h),
          _buildInfoRow(AppTexts.orderDate, _formatDate(order.createdAt)),
          SizedBox(height: 12.h),
          _buildInfoRow(AppTexts.customer, order.name),
          SizedBox(height: 12.h),
          _buildInfoRow(AppTexts.email, order.email),
          SizedBox(height: 12.h),
          _buildInfoRow(AppTexts.phone, order.phone),
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderDetailsModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.shippingAddress,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackTextColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            order.addressLine,
            style: TextStyle(fontSize: 14.sp, color: AppColors.blackTextColor),
          ),
          SizedBox(height: 8.h),
          Text(
            '${order.city}, ${order.state} ${order.zipCode}',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderDetailsModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.paymentInformation,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackTextColor,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            AppTexts.paymentMethod,
            order.paymentMethod.toUpperCase(),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            AppTexts.paymentStatus,
            _localizedPaymentStatus(order.paymentStatus),
          ),
          if (order.promoCode != null) ...[
            SizedBox(height: 12.h),
            _buildInfoRow(AppTexts.promoCode, order.promoCode ?? ''),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(BuildContext context, OrderDetailsModel order) {
    final invoiceUrl = order.invoicePdfUrl;
    if (invoiceUrl == null || invoiceUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                AppTexts.invoice,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openUrl(invoiceUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                AppTexts.viewInvoice,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _downloadInvoice(context, invoiceUrl, order),
              icon: Icon(Icons.download, size: 20.sp, color: AppColors.primary),
              label: Text(
                AppTexts.downloadInvoice,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(
    BuildContext context,
    List<OrderCardItemModel> cards,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orderItems,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackTextColor,
          ),
        ),
        SizedBox(height: 16.h),
        ...cards.map((card) => _buildOrderItemCard(context, card)),
      ],
    );
  }

  Widget _buildOrderItemCard(
    BuildContext context,
    OrderCardItemModel cardItem,
  ) {
    final itemName = cardItem.card.name;
    final itemPrice = cardItem.card.price;
    final currency = cardItem.card.currency;
    final quantity = cardItem.qty;
    final itemImage = cardItem.card.image;
    final productNumber = cardItem.card.productNumber;

    final totalPrice = (double.tryParse(itemPrice) ?? 0) * quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textFieldBorderColor),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.overlayColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: itemImage != null && itemImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: itemImage,
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
                        Icons.image_not_supported,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_not_supported,
                    color: AppColors.greyTextColor,
                    size: 32.sp,
                  ),
          ),
          SizedBox(width: 16.w),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      '${AppTexts.quantity}: $quantity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '$itemPrice $currency',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '${AppTexts.total}: ${totalPrice.toStringAsFixed(2)} $currency',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                if (productNumber.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${AppTexts.productNumber}: ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.greyTextColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          productNumber,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.blackTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: productNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AppTexts.productNumber} ${AppTexts.copied}',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.copy,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection({
    required BuildContext context,
    required OrderDetailsModel order,
    required bool isProcessing,
  }) {
    final isCancelable = _isOrderCancelable(order.status);
    final isPending = order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'processing';
    final isNotPaid = order.paymentStatus.toLowerCase() != 'captured' && order.paymentStatus.toLowerCase() != 'confirmed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPending && isNotPaid) ...[
          PrimaryButton(
            onPressed: _isPaymentLoading || isProcessing ? null : () => _startPayment(context, order),
            title: AppTexts.payNow,
            isLoading: _isPaymentLoading,
          ),
          SizedBox(height: 16.h),
        ],
        if (isCancelable)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing || _isPaymentLoading ? null : () => _confirmCancel(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                AppTexts.cancelOrder,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (isCancelable) SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isProcessing || _isPaymentLoading ? null : () => _confirmDelete(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
            child: Text(
              AppTexts.deleteOrder,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (isProcessing) ...[
          SizedBox(height: 16.h),
          Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _startPayment(BuildContext context, OrderDetailsModel order) async {
    setState(() => _isPaymentLoading = true);
    try {
      debugPrint('--- TAP PAYMENT: Starting Retry Charge Creation ---');
      final response = await _paymentService.createTapCharge(
        amount: double.tryParse(order.totalAmount ?? '0') ?? 0.0,
        currency: 'AED',
        orderId: order.orderNumber,
        customerFirstName: order.name.split(' ').first,
        customerLastName: order.name.contains(' ') ? order.name.split(' ').last : 'Name',
        customerEmail: order.email,
        customerPhoneCode: '971',
        customerPhoneNumber: order.phone,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final chargeData = response.data;
        final transactionUrl = chargeData['transaction']?['url'];

        if (transactionUrl != null) {
          if (!context.mounted) return;

          final result = await Navigator.of(context).pushNamed(
            AppRoutes.paymentWebView,
            arguments: {'url': transactionUrl},
          );

          if (result != null) {
            final chargeResponse = await _paymentService.getTapCharge(result as String);
            final data = chargeResponse.data;
            final status = data['status'];
            final tapMessage = data['response']?['message']?.toString() ?? AppTexts.paymentFailed;

            if (status == 'CAPTURED') {
              if (context.mounted) {
                await _updateOrderStatus(context, order.id, 'confirmed');
                // Refresh order details after successful payment
                if (mounted) {
                  context.read<OrderDetailsCubit>().getOrderDetails(widget.orderNumber);
                }
              }
            } else {
              if (context.mounted) {
                _showResultDialog(context, tapMessage, isError: true);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      if (context.mounted) {
        _showResultDialog(context, AppTexts.paymentFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPaymentLoading = false);
    }
  }

  Future<void> _updateOrderStatus(BuildContext context, int orderId, String status) async {
    try {
      await _paymentService.changeOrderStatus(orderId, status);
      if (context.mounted) {
        _showResultDialog(
          context,
          status == 'confirmed' ? AppTexts.paymentSuccess : AppTexts.paymentCancelled,
          isError: status == 'cancel',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showResultDialog(context, AppTexts.paymentFailed, isError: true);
      }
    }
  }

  void _showResultDialog(BuildContext context, String message, {bool isError = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Column(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
              size: 60.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              isError ? AppTexts.paymentFailed : AppTexts.paymentSuccess,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
            ),
            if (isError) ...[
              SizedBox(height: 16.h),
              Text(
                AppTexts.paymentRetryInstructions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            title: AppTexts.ok,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyTextColor),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blackTextColor,
            ),
          ),
        ),
      ],
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
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.length > 20) {
        return dateString.substring(0, 20);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _downloadInvoice(
    BuildContext context,
    String url,
    OrderDetailsModel order,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    debugPrint('[Invoice] 1. START download url=$url');

    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppTexts.downloading),
          duration: const Duration(seconds: 2),
        ),
      );

      final downloadsDir = await getDownloadsDirectory();
      final fallbackDir = await getApplicationDocumentsDirectory();
      final saveDir = downloadsDir ?? fallbackDir;
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
      debugPrint('[Invoice] 2. saveDir=${saveDir.path} (downloads=${downloadsDir != null})');

      final fileName =
          'invoice_${order.orderNumber.isNotEmpty ? order.orderNumber : DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${saveDir.path}/$fileName';
      debugPrint('[Invoice] 3. filePath=$filePath');

      final dio = Dio();
      await dio.download(url, filePath);
      debugPrint('[Invoice] 4. dio.download SUCCESS');

      if (!context.mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(AppTexts.invoiceDownloaded),
          duration: const Duration(seconds: 3),
        ),
      );

      if (Platform.isAndroid || Platform.isIOS) {
        try {
          debugPrint('[Invoice] 5. opening file: $filePath');
          final result = await OpenFilex.open(filePath);
          debugPrint('[Invoice] 6. OpenFilex result: type=${result.type} message=${result.message}');
        } catch (e, st) {
          debugPrint('[Invoice] 6. OpenFilex FAILED: $e');
          debugPrint('[Invoice] stackTrace: $st');
        }
      }
    } catch (e, st) {
      debugPrint('[Invoice] DOWNLOAD FAILED: $e');
      debugPrint('[Invoice] stackTrace: $st');
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppTexts.downloadFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTexts.confirmCancelOrder),
        content: Text(AppTexts.cancelOrderConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppTexts.close),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppTexts.cancelOrder),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      final cubit = context.read<OrderDetailsCubit>();
      final messenger = ScaffoldMessenger.of(context);

      final result = await cubit.cancelOrder();
      if (!messenger.mounted) return;

      if (result == null) {
        _showResultSnackBar(
          messenger,
          AppTexts.orderCancelledSuccess,
          Colors.green,
        );
      } else {
        _showResultSnackBar(
          messenger,
          _resolveErrorMessage(result),
          Colors.red,
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTexts.confirmDeleteOrder),
        content: Text(AppTexts.deleteOrderConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppTexts.close),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppTexts.deleteOrder,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      final cubit = context.read<OrderDetailsCubit>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      final result = await cubit.deleteOrder();
      if (!messenger.mounted || !navigator.mounted) return;

      if (result == null) {
        _showResultSnackBar(
          messenger,
          AppTexts.orderDeletedSuccess,
          Colors.green,
        );
        navigator.pop(true);
      } else {
        _showResultSnackBar(
          messenger,
          _resolveErrorMessage(result),
          Colors.red,
        );
      }
    }
  }

  void _showResultSnackBar(
    ScaffoldMessengerState messenger,
    String message,
    Color color,
  ) {
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  String _resolveErrorMessage(String message) {
    if (message == OrderDetailsCubit.orderNotLoadedKey) {
      return AppTexts.orderNotLoaded;
    }
    return message;
  }

  bool _isOrderCancelable(String status) {
    final normalized = status.toLowerCase();
    return !{
      'cancel',
      'cancelled',
      'canceled',
      'completed',
      'delivered',
    }.contains(normalized);
  }

  String _localizedPaymentStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized == '1' || normalized == 'paid') {
      return AppTexts.paid;
    }
    if (normalized == '0' ||
        normalized == 'pending' ||
        normalized == 'unpaid' ||
        normalized == 'awaiting') {
      return AppTexts.pending;
    }
    return status;
  }
}
