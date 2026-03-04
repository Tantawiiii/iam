import 'review_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final String oldPrice;
  final String discount;
  final String price;
  final String productNumber;
  final String currency;
  final int quantity;
  final String? linkVideo;
  final String? image;
  final List<dynamic> gallery;
  final String category;
  final String? brand;
  final bool active;
  final double averageRating;
  final int reviewsCount;
  final List<ReviewModel> reviews;
  final String mobile;
  final String type;
  final String typeSilicone;
  final String hardness;
  final String bio;
  final String timeInEar;
  final String endCuring;
  final String viscosity;
  final String color;
  final String packaging;
  final String itemNumber;
  final String mixGun;
  final String mixCanules;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final bool freeDelivery;
  final bool oneYearWarranty;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.shortDescription,
    required this.oldPrice,
    required this.discount,
    required this.price,
    required this.productNumber,
    required this.currency,
    required this.quantity,
    this.linkVideo,
    this.image,
    required this.gallery,
    required this.category,
    this.brand,
    required this.active,
    required this.averageRating,
    required this.reviewsCount,
    required this.reviews,
    required this.mobile,
    required this.type,
    required this.typeSilicone,
    required this.hardness,
    required this.bio,
    required this.timeInEar,
    required this.endCuring,
    required this.viscosity,
    required this.color,
    required this.packaging,
    required this.itemNumber,
    required this.mixGun,
    required this.mixCanules,
    required this.createdAt,
    required this.updatedAt,
      this.deletedAt,
      required this.freeDelivery,
      required this.oneYearWarranty,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var gallery = json['gallery'] as List<dynamic>? ?? [];
    String? image = json['image'] as String?;

    if (image == null && gallery.isNotEmpty) {
      if (gallery.first != null) {
        image = gallery.first.toString();
      }
    }

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String,
      oldPrice: json['old_price'] as String,
      discount: json['discount'] as String,
      price: json['price'] as String,
      productNumber: json['product_number'] as String? ?? '',
      currency: json['currency'] as String,
      quantity: json['quantity'] as int,
      linkVideo: json['link_video'] as String?,
      image: image,
      gallery: gallery,
      category:
          json['category'] as String? ??
          (json['category_id'] != null ? json['category_id'].toString() : ''),
      brand: json['brand'] as String?,
      active: json['active'] as bool,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      mobile: json['mobile'] as String? ?? '',
      type: json['type'] as String? ?? '',
      typeSilicone: json['type_silicone'] as String? ?? '',
      hardness: json['hardness'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      timeInEar: json['time_in_ear'] as String? ?? '',
      endCuring: json['end_curing'] as String? ?? '',
      viscosity: json['viscosity'] as String? ?? '',
      color: _parseColor(json['color']),
      packaging: json['packaging'] as String? ?? '',
      itemNumber: json['item_number'] as String? ?? '',
      mixGun: json['mix_gun'] as String? ?? '',
      mixCanules: json['mix_canules'] as String? ?? '',
      createdAt:
          json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      updatedAt:
          json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
      deletedAt: json['deletedAt'] as String? ?? json['deleted_at'] as String?,
      freeDelivery: json['free_delevery'] as bool? ?? false,
      oneYearWarranty: json['one_year_warranty'] as bool? ?? false,
    );
  }

  /// Colors as list (from API array or parsed from "a - b" string).
  List<String> get colorList {
    if (color.isEmpty) return [];
    if (color.contains(' - ') || color.contains('،') || color.contains(',')) {
      return color
          .split(RegExp(r'\s*[-،,]\s*'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [color];
  }

  static String _parseColor(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .join(' - ');
    }
    return value.toString().trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'short_description': shortDescription,
      'old_price': oldPrice,
      'discount': discount,
      'price': price,
      'product_number': productNumber,
      'currency': currency,
      'quantity': quantity,
      'link_video': linkVideo,
      'image': image,
      'gallery': gallery,
      'category': category,
      'brand': brand,
      'active': active,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'mobile': mobile,
      'type': type,
      'type_silicone': typeSilicone,
      'hardness': hardness,
      'bio': bio,
      'time_in_ear': timeInEar,
      'end_curing': endCuring,
      'viscosity': viscosity,
      'color': color,
      'packaging': packaging,
      'item_number': itemNumber,
      'mix_gun': mixGun,
      'mix_canules': mixCanules,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'free_delevery': freeDelivery,
      'one_year_warranty': oneYearWarranty,
    };
  }
}
