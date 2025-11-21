import 'brand_model.dart';

class BrandsResponseModel {
  final String result;
  final List<BrandModel> data;
  final String message;
  final int status;

  BrandsResponseModel({
    required this.result,
    required this.data,
    required this.message,
    required this.status,
  });

  factory BrandsResponseModel.fromJson(Map<String, dynamic> json) {
    return BrandsResponseModel(
      result: json['result'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => BrandModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
      'status': status,
    };
  }
}

