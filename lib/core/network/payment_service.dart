import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'api_constants.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService;

  PaymentService(this._apiService);


  Future<Response> createTapCharge({
    required double amount,
    required String currency,
    required String orderId,
    required String customerFirstName,
    required String customerLastName,
    required String customerEmail,
    required String customerPhoneCode,
    required String customerPhoneNumber,
    String? description,
  }) async {
    try {
      final data = {
        "amount": amount,
        "currency": currency,
        "threeDSecure": true,
        "save_card": false,
        "description": description ?? "Order $orderId",
        "statement_descriptor": "IAM Platform",
        "reference": {
          "transaction": orderId,
          "order": orderId
        },
        "customer": {
          "first_name": customerFirstName,
          "last_name": customerLastName,
          "email": customerEmail,
          "phone": {
            "country_code": customerPhoneCode,
            "number": customerPhoneNumber
          }
        },
        
        "source": {
          "id": "src_all"
        },
        "redirect": {
          "url": EnvConfig.tapRedirectUrl
        }
      };

      final response = await _apiService.dio.post(
        '${EnvConfig.tapApiUrl}/v2/charges',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvConfig.tapSecretKey}',
          },
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTapCharge(String chargeId) async {
    try {
      final response = await _apiService.dio.get(
        '${EnvConfig.tapApiUrl}/v2/charges/$chargeId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvConfig.tapSecretKey}',
          },
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> changeOrderStatus(int orderId, String status) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orderChangeStatus(orderId),
        data: {
          "status": status,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
