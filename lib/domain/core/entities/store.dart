import 'package:get/get.dart';

class Stores {
  String id;
  DateTime createdAt;
  RxString name;
  RxString address;
  RxString phone;
  RxString telp;
  RxString? promo;

  Stores({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.address,
    required this.phone,
    required this.telp,
    this.promo,
  });
}
