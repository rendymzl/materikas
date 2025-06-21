class Customer {
  String? id;
  String? customerId;
  DateTime? createdAt;
  String name;
  String? phone;
  String? address;
  String? noteAddress;
  String? storeId;
  double? deposit;

  Customer({
    this.id,
    this.customerId,
    this.createdAt,
    required this.name,
    this.phone,
    this.address,
    this.noteAddress,
    this.storeId,
    this.deposit,
  });
}
