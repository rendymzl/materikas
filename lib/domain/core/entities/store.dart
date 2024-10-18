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
  });
}
