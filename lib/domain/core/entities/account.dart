import 'package:get/get.dart';

import '../../../infrastructure/models/user_model.dart';

class Account {
  String? id;
  String accountId;
  DateTime createdAt;
  String name;
  String email;
  String role;
  String? storeId;
  RxList<Cashier> users;
  String password;
  String accountType;
  DateTime? startDate;
  DateTime? endDate;
  bool? isActive;
  DateTime updatedAt;

  Account({
    this.id,
    required this.accountId,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.role,
    this.storeId,
    required this.users,
    required this.password,
    required this.accountType,
    this.startDate,
    this.endDate,
    this.isActive,
    required this.updatedAt,
  });
}
