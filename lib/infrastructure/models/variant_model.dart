class Variant {
  final String id;
  final double price;
  final int stock;
  final Map<String, String>? attributes;

  Variant({
    required this.id,
    required this.price,
    required this.stock,
    this.attributes,
  });

  factory Variant.fromMap(Map<String, dynamic> map) {
    return Variant(
      id: map['id'],
      price: map['price'].toDouble(),
      stock: map['stock'],
      attributes: map['attributes'] != null
          ? Map<String, String>.from(map['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'stock': stock,
      'attributes': attributes,
    };
  }
}
