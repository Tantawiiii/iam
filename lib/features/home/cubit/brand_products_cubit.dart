import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../services/brands_service.dart';
import '../models/brand_details_response_model.dart';

part 'brand_products_state.dart';

class BrandProductsCubit extends Cubit<BrandProductsState> {
  final BrandsService _brandsService;

  BrandProductsCubit(this._brandsService)
      : super(BrandProductsInitial());


  Future<void> getBrandById(int brandId) async {
    emit(BrandProductsLoading());

    try {
      final response = await _brandsService.getBrandById(brandId);

      emit(BrandProductsSuccess(response));
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

      emit(BrandProductsFailure(errorMessage));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(BrandProductsInitial());
  }
}

