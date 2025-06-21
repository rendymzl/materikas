class SubscriptionPackage {
  final String name; // Nama paket (misalnya, "1 Bulan", "3 Bulan", "12 Bulan")
  final int durationInMonths; // Durasi langganan dalam bulan
  final double price; // Harga paket
  final double? priceBeforeDiscount; // Harga sebelum diskon (opsional)
  final String? note; // Catatan (opsional)

  SubscriptionPackage({
    required this.name,
    required this.durationInMonths,
    required this.price,
    this.priceBeforeDiscount,
    this.note,
  });

  // Factory untuk membuat instance dari Map (misalnya data API)
  factory SubscriptionPackage.fromMap(Map<String, dynamic> map) {
    return SubscriptionPackage(
      name: map['package_name'] as String,
      durationInMonths: map['duration_in_months'] as int,
      price: map['price'].toDouble(),
      priceBeforeDiscount: map['price_before_discount']?.toDouble(),
      note: map['note'],
    );
  }

  // Konversi instance menjadi Map (untuk disimpan ke database atau dikirim ke API)
  Map<String, dynamic> toMap() {
    return {
      'package_name': name,
      'duration_in_months': durationInMonths,
      'price': price,
      'priceBeforeDiscount': priceBeforeDiscount,
      'note': note,
    };
  }

  @override
  String toString() {
    return 'SubscriptionPackage(name: $name, durationInMonths: $durationInMonths, price: $price, priceBeforeDiscount: $priceBeforeDiscount, note: $note)';
  }
}
