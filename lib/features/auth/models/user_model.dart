class UserModel {
  final int id;
  final String name;
  final String phone;
  final String role;
  final String email;
  final String? avatar;
  final int? age;
  final String? gender;
  final String? country;
  final String? city;
  final String? idImage;
  final String? bankStatementImage;
  final String? invoiceImage;
  final bool active;
  final bool? isRefused;
  final List<dynamic> favorites;
  final List<dynamic> orders;
  final List<dynamic> productsForSale;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.email,
    this.avatar,
    this.age,
    this.gender,
    this.country,
    this.city,
    this.idImage,
    this.bankStatementImage,
    this.invoiceImage,
    required this.active,
    this.isRefused,
    required this.favorites,
    required this.orders,
    required this.productsForSale,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    List<dynamic> parseList(dynamic value) {
      if (value is List<dynamic>) return value;
      return [];
    }

    String? parseNullableString(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString();
    }

    bool parseBool(dynamic value, {bool defaultValue = false}) {
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return defaultValue;
    }

    return UserModel(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      phone: parseString(json['phone']),
      role: parseString(json['role']),
      email: parseString(json['email']),
      avatar: parseNullableString(json['avatar']),
      age: parseNullableInt(json['age']),
      gender: parseNullableString(json['gender']),
      country: parseNullableString(json['country']),
      city: parseNullableString(json['city']),
      idImage: parseNullableString(json['id_image']),
      bankStatementImage: parseNullableString(json['bank_statement_image']),
      invoiceImage: parseNullableString(json['invoice_image']),
      active: parseBool(json['active'], defaultValue: false),
      isRefused: json['is_refused'] != null
          ? parseBool(json['is_refused'])
          : null,
      favorites: parseList(json['favorites']),
      orders: parseList(json['orders']),
      productsForSale: parseList(json['products_for_sale']),
      createdAt: parseString(json['createdAt'] ?? json['created_at']),
      updatedAt: parseString(json['updatedAt'] ?? json['updated_at']),
      deletedAt: parseNullableString(json['deletedAt'] ?? json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'email': email,
      'avatar': avatar,
      'age': age,
      'gender': gender,
      'country': country,
      'city': city,
      'id_image': idImage,
      'bank_statement_image': bankStatementImage,
      'invoice_image': invoiceImage,
      'active': active,
      'is_refused': isRefused,
      'favorites': favorites,
      'orders': orders,
      'products_for_sale': productsForSale,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }
}
