import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../services/brands_service.dart';
import '../models/brands_response_model.dart';

part 'brands_state.dart';

class BrandsCubit extends Cubit<BrandsState> {
  final BrandsService _brandsService;

  BrandsCubit(this._brandsService) : super(BrandsInitial());

  /// Fetch all brands
  Future<void> getBrands() async {
    emit(BrandsLoading());

    try {
      final response = await _brandsService.getBrands();

      emit(BrandsSuccess(response));
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

      emit(BrandsFailure(errorMessage));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(BrandsInitial());
  }
}

