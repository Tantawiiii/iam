import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Response> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String age,
    required String gender,
    required String country,
    required String city,
    File? avatar,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'age': age,
        'gender': gender,
        'country': country,
        'city': city,
        if (avatar != null)
          'avatar': await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
      });

      final response = await _apiService.post(
        ApiConstants.register,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? password,
    String? age,
    String? gender,
    String? country,
    String? city,
    File? avatar,
    File? idImage,
    File? bankStatementImage,
    File? invoiceImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
        if (age != null && age.isNotEmpty) 'age': age,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (country != null && country.isNotEmpty) 'country': country,
        if (city != null && city.isNotEmpty) 'city': city,
        if (avatar != null)
          'avatar': await MultipartFile.fromFile(
            avatar.path,
            filename: avatar.path.split('/').last,
          ),
        if (idImage != null)
          'id_image': await MultipartFile.fromFile(
            idImage.path,
            filename: idImage.path.split('/').last,
          ),
        if (bankStatementImage != null)
          'bank_statement_image': await MultipartFile.fromFile(
            bankStatementImage.path,
            filename: bankStatementImage.path.split('/').last,
          ),
        if (invoiceImage != null)
          'invoice_image': await MultipartFile.fromFile(
            invoiceImage.path,
            filename: invoiceImage.path.split('/').last,
          ),
      });

      final response = await _apiService.post(
        ApiConstants.updateProfile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout() async {
    try {
      final response = await _apiService.post(ApiConstants.logout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> checkAuth() async {
    try {
      final response = await _apiService.get(ApiConstants.checkAuth);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
