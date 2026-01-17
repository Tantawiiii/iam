import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthService _authService;

  ResetPasswordCubit(this._authService) : super(ResetPasswordInitial());

  Future<void> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(ResetPasswordLoading());

    try {
      final response = await _authService.resetPassword(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        String errorMessage = 'An error occurred. Please try again.';
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        }
        emit(ResetPasswordFailure(errorMessage));
        return;
      }

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final result = responseData['result'];
        if (result != null && result.toString().toLowerCase() == 'error') {
          String errorMessage = 'An error occurred. Please try again.';
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
          emit(ResetPasswordFailure(errorMessage));
          return;
        }
      }

      emit(ResetPasswordSuccess(response.data));
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

      emit(ResetPasswordFailure(errorMessage));
    }
  }

  void reset() {
    emit(ResetPasswordInitial());
  }
}
