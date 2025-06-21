class MidtransSettingModel {
  String snapUrl;
  String orderId;
  String price;

  MidtransSettingModel({
    required this.snapUrl,
    required this.orderId,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'snap_url': snapUrl,
      'order_id': orderId,
      'price': price,
    };
  }

  factory MidtransSettingModel.fromMap(Map<String, dynamic> map) {
    return MidtransSettingModel(
      snapUrl: map['snap_url'] ?? '',
      orderId: map['order_id'] ?? '',
      price: map['price'] ?? '',
    );
  }
}
