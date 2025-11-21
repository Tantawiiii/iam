import 'product_model.dart';

class BrandDetailsModel {
  final int id;
  final String name;
  final String slug;
  final bool active;
  final String? image;
  final List<ProductModel> products;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  BrandDetailsModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.active,
    this.image,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory BrandDetailsModel.fromJson(Map<String, dynamic> json) {
    return BrandDetailsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      active: json['active'] as bool,
      image: json['image'] as String?,
      products:
          (json['products'] as List<dynamic>?)
              ?.map(
                (product) =>
                    ProductModel.fromJson(product as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      deletedAt: json['deletedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'active': active,
      'image': image,
      'products': products.map((product) => product.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }
}

