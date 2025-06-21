import 'package:get/get.dart';

import '../../../infrastructure/models/billing_model.dart';

class Stores {
  String? id;
  String? ownerId;
  DateTime createdAt;
  RxString name;
  RxString address;
  RxString phone;
  RxString telp;
  RxList<Billing>? billings;
  RxString? promo;
  RxString? logoUrl;
  RxList<String>? textPrint;

  Stores({
    this.id,
    this.ownerId,
    required this.createdAt,
    required this.name,
    required this.address,
    required this.phone,
    required this.telp,
    this.billings,
    this.promo,
    this.logoUrl,
    this.textPrint,
  });
}
