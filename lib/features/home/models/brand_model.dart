class BrandModel {
  final int id;
  final String name;
  final String slug;
  final bool active;
  final String? image;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.active,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      active: json['active'] as bool,
      image: json['image'] as String?,
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }
}

