import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

part 'verify_otp_state.dart';

class VerifyOtpCubit extends Cubit<VerifyOtpState> {
  final AuthService _authService;

  VerifyOtpCubit(this._authService) : super(VerifyOtpInitial());

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(VerifyOtpLoading());

    try {
      final response = await _authService.verifyOtp(email: email, otp: otp);

      // Check response status code
      if (response.statusCode != null && response.statusCode! >= 400) {
        String errorMessage = 'An error occurred. Please try again.';
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        }
        emit(VerifyOtpFailure(errorMessage));
        return;
      }

      // Check if response contains error in result field
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final result = responseData['result'];
        if (result != null && result.toString().toLowerCase() == 'error') {
          // Extract error message
          String errorMessage = 'An error occurred. Please try again.';
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
          emit(VerifyOtpFailure(errorMessage));
          return;
        }
      }

      emit(VerifyOtpSuccess(response.data));
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e is DioException) {
        if (e.response != null) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'].toString();
          } else {
            errorMessage = e.response?.statusMessage ?? errorMessage;
          }
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage =
              'Connection timeout. Please check your internet connection.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'No internet connection. Please check your network.';
        }
      }

      emit(VerifyOtpFailure(errorMessage));
    }
  }

  void reset() {
    emit(VerifyOtpInitial());
  }
}
