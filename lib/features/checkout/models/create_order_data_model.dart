
class CreateOrderDataModel {
  final int id;
  final String orderNumber;
  final String invoicePdfUrl;
  final String? name;
  final String? email;
  final num? totalAmount;
  final String? createdAt;

  const CreateOrderDataModel({
    required this.id,
    required this.orderNumber,
    required this.invoicePdfUrl,
    this.name,
    this.email,
    this.totalAmount,
    this.createdAt,
  });

  
  static CreateOrderDataModel? fromResponseData(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    final order = data['order'];
    final invoiceUrl =
        data['invoice_url'] as String? ??
        (order is Map ? order['invoice_pdf_url'] as String? : null);
    if (invoiceUrl == null || invoiceUrl.isEmpty) return null;

    int? id;
    String? orderNumber;
    String? name;
    String? email;
    num? totalAmount;
    String? createdAt;

    if (order is Map<String, dynamic>) {
      id = order['id'] as int?;
      orderNumber = order['order_number'] as String?;
      name = order['name'] as String?;
      email = order['email'] as String?;
      totalAmount = order['total_amount'] as num?;
      createdAt = order['createdAt'] as String?;
    }

    return CreateOrderDataModel(
      id: id ?? 0,
      orderNumber: orderNumber ?? '',
      invoicePdfUrl: invoiceUrl,
      name: name,
      email: email,
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }
}
