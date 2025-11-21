import 'brand_details_model.dart';

class BrandDetailsResponseModel {
  final String result;
  final BrandDetailsModel data;
  final String message;
  final int status;

  BrandDetailsResponseModel({
    required this.result,
    required this.data,
    required this.message,
    required this.status,
  });

  factory BrandDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return BrandDetailsResponseModel(
      result: json['result'] as String,
      data: BrandDetailsModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'data': data.toJson(),
      'message': message,
      'status': status,
    };
  }
}

