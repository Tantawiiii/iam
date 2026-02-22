import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../../../core/routing/app_routes.dart';
import '../models/create_order_data_model.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../core/network/payment_service.dart';
import '../../../core/di/inject.dart';

class OrderSuccessScreen extends StatefulWidget {
  final CreateOrderDataModel orderData;

  const OrderSuccessScreen({super.key, required this.orderData});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  final PaymentService _paymentService = sl<PaymentService>();
  bool _isPaymentLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppTexts.orderSuccessTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              _buildSuccessHeader(),
              SizedBox(height: 24.h),
              _buildOrderInfoCard(),
              SizedBox(height: 24.h),
              _buildPaymentSection(context),
              SizedBox(height: 24.h),
              _buildInvoiceSection(context),
              SizedBox(height: 32.h),
              _buildBackToHomeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Icon(Icons.check_circle, size: 72.sp, color: AppColors.success),
        SizedBox(height: 16.h),
        Text(
          AppTexts.orderPlacedSuccessfully,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.orderInformation,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _infoRow(AppTexts.orderNumberLabel, widget.orderData.orderNumber),
          if (widget.orderData.name != null && widget.orderData.name!.isNotEmpty)
            _infoRow(AppTexts.customer, widget.orderData.name!),
          if (widget.orderData.email != null &&
              widget.orderData.email!.isNotEmpty)
            _infoRow(AppTexts.email, widget.orderData.email!),
          if (widget.orderData.totalAmount != null)
            _infoRow(
              AppTexts.total,
              '${(widget.orderData.totalAmount as num).toStringAsFixed(2)} AED',
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                AppTexts.paymentMethod,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          PrimaryButton(
            onPressed: _isPaymentLoading ? null : () => _startPayment(context),
            title: AppTexts.completePayment,
            isLoading: _isPaymentLoading,
          ),
        ],
      ),
    );
  }

  Future<void> _startPayment(BuildContext context) async {
    setState(() => _isPaymentLoading = true);
    try {
      // 1. Create Tap Charge
      debugPrint('--- TAP PAYMENT: Starting Charge Creation ---');
      final response = await _paymentService.createTapCharge(
        amount: widget.orderData.totalAmount?.toDouble() ?? 0.0,
        currency: 'AED',
        orderId: widget.orderData.orderNumber,
        customerFirstName: widget.orderData.name?.split(' ').first ?? 'Customer',
        customerLastName: (widget.orderData.name?.contains(' ') ?? false)
            ? widget.orderData.name!.split(' ').last
            : 'Name',
        customerEmail: widget.orderData.email ?? 'customer@email.com',
        customerPhoneCode: '971',
        customerPhoneNumber: '50000000',
      );

      debugPrint('--- TAP PAYMENT: Charge Response Received: ${response.statusCode}');
      debugPrint('--- TAP PAYMENT: Response Body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final chargeData = response.data;
        final transactionUrl = chargeData['transaction']?['url'];

        if (transactionUrl != null) {
          debugPrint('--- TAP PAYMENT: Navigating to WebView: $transactionUrl');
          if (!context.mounted) return;
          final result = await Navigator.of(context).pushNamed(
            AppRoutes.paymentWebView,
            arguments: {
              'url': transactionUrl,
            },
          );

          debugPrint('--- TAP PAYMENT: Result from WebView: $result');

          if (result != null) {
            // 3. Verify status from Tap directly
            debugPrint('--- TAP PAYMENT: Verifying Charge Status for ID: $result');
            final chargeResponse = await _paymentService.getTapCharge(result as String);
            final data = chargeResponse.data;
            final status = data['status'];
            
            debugPrint('--- TAP PAYMENT: Detailed Charge Response: $data');
            debugPrint('--- TAP PAYMENT: Final Status: $status');
            
            // Extract the descriptive message from Tap (e.g., "Captured", "Declined", etc.)
            final tapMessage = data['response']?['message']?.toString() ?? AppTexts.paymentFailed;

            if (status == 'CAPTURED') {
              debugPrint('--- TAP PAYMENT: Success! Updating backend...');
              if (context.mounted) {
                await _updateOrderStatus(context, 'confirmed');
              }
            } else {
              debugPrint('--- TAP PAYMENT: Payment Not Captured. Status: $status');
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

  Future<void> _updateOrderStatus(BuildContext context, String status) async {
    debugPrint('--- BACKEND UPDATE: Changing status to: $status for Order ID: ${widget.orderData.id}');
    try {
      await _paymentService.changeOrderStatus(widget.orderData.id, status);
      debugPrint('--- BACKEND UPDATE: Success!');
      
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
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            },
            title: AppTexts.backToHome,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          PrimaryButton(
            onPressed: () => _openUrl(widget.orderData.invoicePdfUrl),
            title: AppTexts.viewInvoice,
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: () => _downloadInvoice(context),
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
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final url = widget.orderData.invoicePdfUrl;
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
          'invoice_${widget.orderData.orderNumber.isNotEmpty ? widget.orderData.orderNumber : DateTime.now().millisecondsSinceEpoch}.pdf';
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

  Widget _buildBackToHomeButton(BuildContext context) {
    return PrimaryButton(
      onPressed: () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      },
      title: AppTexts.backToHome,
    );
  }
}
