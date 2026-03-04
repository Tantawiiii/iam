class CouponModel {
  final int id;
  final String code;
  final String type; // 'percentage' | 'fixed'
  final String value;
  final int active;
  final String? createdAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.active,
    this.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'percentage',
      value: (json['value']?.toString()) ?? '0',
      active: (json['active'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }

  double get numericValue => double.tryParse(value) ?? 0.0;

  bool get isPercentage => type == 'percentage';
  bool get isFixed => type == 'fixed';
}
