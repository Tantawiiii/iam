import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_service.dart';

class SettingsService {
  final ApiService _apiService;

  SettingsService(this._apiService);

  Future<Response> checkAuth() async {
    try {
      final response = await _apiService.get(ApiConstants.checkAuth);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getOrderDetails(String orderNumber) async {
    try {
      final response = await _apiService.get(
        ApiConstants.orderDetails(orderNumber),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> changeOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orderChangeStatus(orderId),
        data: {'status': status},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteOrder(int orderId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.orderById(orderId),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteAccount() async {
    try {
      final response = await _apiService.delete(ApiConstants.deleteAccount);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> resellProduct({
    required String name,
    required String description,
    required String price,
    required String productNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'price': price,
        'product_number': productNumber,
      });

      final response = await _apiService.post(
        ApiConstants.userProducts,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
