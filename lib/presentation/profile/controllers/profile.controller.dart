import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/account_model.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../global_widget/app_dialog_widget.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AccountService _accountService = Get.find<AccountService>();

  late final account = _authService.account;
  late final store = _authService.store;
  late final cashiers = _authService.cashiers;

  final formCashierKey = GlobalKey<FormState>();

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
        String id = cashiers.isNotEmpty
            ? (int.parse(cashiers.last.id.toString()) + 1).toString()
            : '1';
        final Cashier newCashier = Cashier(
          id: id,
          createdAt: DateTime.now(),
          name: nameController.text,
          password: passwordController.text,
          accessList: <String>[].obs,
        );
        var updatedAccount = AccountModel.fromJson(account.toJson());
        print(updatedAccount.users.length);

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

  Future<void> removeCashier(Cashier cashier) async {
    AppDialog.show(
      title: 'Hapus Kasir',
      content: 'Hapus Kasir ini?',
      confirmText: "Ya",
      cancelText: "Tidak",
      confirmColor: Colors.grey,
      cancelColor: Get.theme.primaryColor,
      onConfirm: () async {
        account.value!.users.remove(cashier);
        await _accountService.update(account.value!);
        await _authService.getAccount();
        Get.back();
      },
      onCancel: () => Get.back(),
    );

    if (formCashierKey.currentState?.validate() ?? false) {
      Get.defaultDialog(
        title: 'Menambahkan kasir...',
        content: const CircularProgressIndicator(),
        barrierDismissible: false,
      );
      try {
        String id = cashiers.isNotEmpty
            ? (int.parse(cashiers.last.id.toString()) + 1).toString()
            : '1';
        final Cashier newCashier = Cashier(
          id: id,
          createdAt: DateTime.now(),
          name: nameController.text,
          password: passwordController.text,
          accessList: <String>[].obs,
        );
        var updatedAccount = AccountModel.fromJson(account.toJson());
        print(updatedAccount.users.length);

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

//CheckBoxHandle
  void checkBoxHandle(Cashier cashier, String accessName) {
    if (cashier.accessList.contains(accessName)) {
      cashier.accessList.remove(accessName);
    } else {
      cashier.accessList.add(accessName);
    }
    print(cashier.accessList);
  }

//Change PIN
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
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  String? validateNewPin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  Future<void> changePinHandle() async {
    if (_authService.account.value!.password == oldPinController.text) {
      if (oldPinController.text != newPinController.text) {
        if ((formkey.currentState?.validate() ?? false)) {
          Get.defaultDialog(
            title: 'Mengubah PIN..',
            content: const CircularProgressIndicator(),
            barrierDismissible: false,
          );
          try {
            AccountModel updatedAccount =
                AccountModel.fromJson(_authService.account.toJson());
            updatedAccount.password = newPinController.text;
            await _accountService.update(updatedAccount);
            await _authService.getAccount();

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
