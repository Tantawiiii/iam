import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../models/coupon_model.dart';

class CouponService {
  final ApiService _apiService;

  CouponService(this._apiService);

  /// Search/validate a coupon by code. Returns [CouponModel] on success.
  /// Throws [DioException] or [Exception] with message on failure.
  Future<CouponModel> searchCoupon(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw Exception('Please enter a promo code');
    }

    final response = await _apiService.get<dynamic>(
      ApiConstants.couponsSearch,
      queryParameters: {'code': trimmed},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }

    final result = data['result'] as String?;
    final status = (data['status'] as num?)?.toInt();

    if (result != 'Success' || status != 200) {
      final message = data['message'] as String? ?? 'Invalid or expired promo code';
      throw Exception(message);
    }

    final couponData = data['data'];
    if (couponData is! Map<String, dynamic>) {
      throw Exception('Invalid coupon data');
    }

    final coupon = CouponModel.fromJson(couponData);
    if (coupon.active != 1) {
      throw Exception('This promo code is no longer active');
    }

    return coupon;
  }
}
