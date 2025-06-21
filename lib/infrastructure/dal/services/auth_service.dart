import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/auth_repository.dart';
import '../../models/account_model.dart';
import '../../models/store_model.dart';
import '../../navigation/routes.dart';
import '../../utils/hive_boxex.dart';
import 'internet_service.dart';

class AuthService extends GetxService implements AuthRepository {
  final supabaseClient = Supabase.instance.client;

  @override
  Future<bool> isLoggedIn() async {
    return supabaseClient.auth.currentUser != null;
  }

  final Rx<AccountModel?> account = Rx<AccountModel?>(null);
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);

  final RxList<Cashier> cashiers = RxList<Cashier>([]);

  @override
  RxList<Cashier> getCashier() {
    if (account.value?.users.isNotEmpty == true) {
      cashiers.assignAll(
          account.value!.users..sort((a, b) => a.id!.compareTo(b.id!)));
    }
    return cashiers;
  }

  final Rx<Cashier?> selectedUser = Rx<Cashier?>(null);

  final Rx<int?> token = Rx<int?>(null);
  final Rx<int?> initToken = Rx<int?>(null);
  final RxBool isOwner = false.obs;

  Future<bool> checkAccess(String code) async {
    final accessList = selectedUser.value?.accessList ?? [];
    return isOwner.value || accessList.contains(code);
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await Get.find<InternetService>().onClose();
      Get.offAllNamed(Routes.SPLASH);
    } on AuthException catch (e) {
      print(e.message);
      Get.defaultDialog(
        title: 'Error',
        content: Text(e.message.contains('Invalid login credentials')
            ? 'Email atau password salah'
            : e.message.contains('No address')
                ? 'Nyalakan internet untuk masuk'
                : 'Terjadi kesalahan, silakan coba lagi'),
      );
    }
  }

  @override
  Future<Cashier?> getSelectedCashier() async {
    String? userName = await HiveBox.getSelectedUser();

    selectedUser.value =
        account.value?.users.firstWhereOrNull((user) => user.name == userName);
    isOwner.value = selectedUser.value == null;
    // print('objecta aaa ${selectedUser.value}');
    // print('objecta aaa ${isOwner.value}');
    return selectedUser.value;
  }

  bool checkIsOwner() {
    return isOwner.value = selectedUser.value == null;
  }

  @override
  Future<void> insert(AccountModel account) {
    throw UnimplementedError();
  }
}
