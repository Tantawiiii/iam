import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../services/settings_service.dart';

part 'resell_product_state.dart';

class ResellProductCubit extends Cubit<ResellProductState> {
  final SettingsService _settingsService;

  ResellProductCubit(this._settingsService) : super(ResellProductInitial());

  Future<void> resellProduct({
    required String name,
    required String description,
    required String price,
    required String productNumber,
  }) async {
    emit(ResellProductLoading());

    try {
      final response = await _settingsService.resellProduct(
        name: name,
        description: description,
        price: price,
        productNumber: productNumber,
      );

      // Check status code for validation errors (422, etc.)
      if (response.statusCode != null &&
          response.statusCode! >= 400 &&
          response.statusCode! < 500) {
        String errorMessage = 'Failed to submit product. Please try again.';
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          errorMessage = data['message']?.toString() ?? errorMessage;
        }
        emit(ResellProductFailure(errorMessage));
        return;
      }

      // Check if response indicates success
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check for error result
        if (data['result'] == 'Error') {
          final errorMessage =
              data['message']?.toString() ??
              'Failed to submit product. Please try again.';
          emit(ResellProductFailure(errorMessage));
          return;
        }

        // Check for status: false (validation errors)
        if (data['status'] == false || data['status'] == 'false') {
          final errorMessage =
              data['message']?.toString() ??
              'Failed to submit product. Please try again.';
          emit(ResellProductFailure(errorMessage));
          return;
        }
      }

      emit(ResellProductSuccess());
    } catch (e) {
      String errorMessage = 'Failed to submit product. Please try again.';

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

      emit(ResellProductFailure(errorMessage));
    }
  }

  void reset() {
    emit(ResellProductInitial());
  }
}
