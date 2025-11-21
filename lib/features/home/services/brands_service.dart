import '../../../core/network/api_constants.dart';
import '../../../core/network/api_service.dart';
import '../models/brands_response_model.dart';
import '../models/brand_details_response_model.dart';

class BrandsService {
  final ApiService _apiService;

  BrandsService(this._apiService);


  Future<BrandsResponseModel> getBrands() async {
    try {
      final response = await _apiService.get(ApiConstants.brands);

      return BrandsResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BrandDetailsResponseModel> getBrandById(int brandId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.categories}/$brandId',
      );

      return BrandDetailsResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}

