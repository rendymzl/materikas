import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/account_model.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';

class PinController extends GetxController {
  final authService = Get.find<AuthService>();
  final accountService = Get.find<AccountService>();
  final storeService = Get.find<StoreService>();

  late final account = authService.account;

//!Change PIN
  final oldPinController = TextEditingController();
  final newPinController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  final hideOldPassword = true.obs;
  final hideNewPassword = true.obs;

  void toggleHidePassword(String section) {
    section == 'oldPin'
        ? hideOldPassword.value = !hideOldPassword.value
        : hideNewPassword.value = !hideNewPassword.value;
  }

  String? validateOldPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    return null;
  }

  String? validateNewPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    return null;
  }

  Future<void> changePinHandle() async {
    if (authService.account.value!.password == oldPinController.text) {
      if (oldPinController.text != newPinController.text) {
        if ((formkey.currentState?.validate() ?? false)) {
          Get.defaultDialog(
            title: 'Mengubah PIN..',
            content: const CircularProgressIndicator(),
            barrierDismissible: false,
          );
          try {
            AccountModel updatedAccount =
                AccountModel.fromJson(authService.account.toJson());
            updatedAccount.password = newPinController.text;
            await accountService.update(updatedAccount);
            authService.account.value = updatedAccount;
            // authService
            //     .store(await storeService.getStore(account.value!.storeId!));

            oldPinController.text = '';
            newPinController.text = '';
            Get.back();
            Get.back();

            await Get.defaultDialog(
              title: 'Berhasil',
              middleText: 'Pin berhasil diubah.',
            );
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
      } else {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'PIN sama dengan sebelumnya',
          confirm: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    } else {
      Get.defaultDialog(
        title: 'Error',
        middleText: 'PIN sebelumnya tidak sesuai',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }
}
