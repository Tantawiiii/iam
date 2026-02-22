class PublicSettingResponseModel {
  final String result;
  final List<PublicSettingData> data;
  final String message;
  final int status;

  PublicSettingResponseModel({
    required this.result,
    required this.data,
    required this.message,
    required this.status,
  });

  factory PublicSettingResponseModel.fromJson(Map<String, dynamic> json) {
    return PublicSettingResponseModel(
      result: json['result'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => PublicSettingData.fromJson(e))
              .toList() ??
          [],
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class PublicSettingData {
  final int id;
  final String? name;
  final String? promotionalOfferImageOne;
  final String? titleOne;
  final String? promotionalOfferImageTwo;
  final String? titleTwo;
  final String? promotionalOfferImageThree;
  final String? titleThree;
  final String? promotionalOfferImageFour;
  final String? titleFour;
  final String? promotionalOfferImageFive;
  final String? titleFive;
  final List<String> termsAndConditions;
  final DateTime? createdAt;

  PublicSettingData({
    required this.id,
    this.name,
    this.promotionalOfferImageOne,
    this.titleOne,
    this.promotionalOfferImageTwo,
    this.titleTwo,
    this.promotionalOfferImageThree,
    this.titleThree,
    this.promotionalOfferImageFour,
    this.titleFour,
    this.promotionalOfferImageFive,
    this.titleFive,
    required this.termsAndConditions,
    this.createdAt,
  });

  factory PublicSettingData.fromJson(Map<String, dynamic> json) {
    return PublicSettingData(
      id: json['id'] ?? 0,
      name: json['name'],
      promotionalOfferImageOne: json['promotional_offer_image_one'],
      titleOne: json['title_one'],
      promotionalOfferImageTwo: json['promotional_offer_image_two'],
      titleTwo: json['title_two'],
      promotionalOfferImageThree: json['promotional_offer_image_three'],
      titleThree: json['title_three'],
      promotionalOfferImageFour: json['promotional_offer_image_four'],
      titleFour: json['title_four'],
      promotionalOfferImageFive: json['promotional_offer_image_five'],
      titleFive: json['title_five'],
      termsAndConditions: (json['terms_and_conditions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
