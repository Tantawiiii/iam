class OrderCardModel {
  final int id;
  final int qty;
  final String? color;

  OrderCardModel({
    required this.id,
    required this.qty,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qty': qty,
      if (color != null && color!.isNotEmpty) 'color': color,
    };
  }
}

