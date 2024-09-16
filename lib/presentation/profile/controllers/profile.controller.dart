import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/account_model.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AccountService _accountService = Get.find<AccountService>();

  late final account = _authService.account;
  late final store = _authService.store;
  late final cashier = _authService.account;

  final formCashierKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeTelpController = TextEditingController();

  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  String? validateCashierName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama kasir tidak boleh kosong';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  Future<void> registerWorker() async {
    if (formCashierKey.currentState?.validate() ?? false) {
      Get.defaultDialog(
        title: 'Menambahkan kasir...',
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );
      try {
        final Cashier newCashier = Cashier(
          id: ,
          createdAt: DateTime.now(),
          name: nameController.text,
          password: passwordController.text,
          accessList: <String>[].obs,
        );
        var updatedAccount =
            AccountModel.fromJson(_authService.account.toJson());

        updatedAccount.users.add(newCashier);

        await _accountService.update(updatedAccount);
        await _authService.getAccount();

        nameController.text = '';
        passwordController.text = '';
        Get.back();
      } catch (e) {
        Get.back();
        debugPrint(e.toString());
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Terjadi kesalahan tidak terduga',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    }
  }
}
