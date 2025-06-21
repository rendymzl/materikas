import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/hive_boxex.dart';
import '../../global_widget/menu_widget/menu_controller.dart';

class SelectUserController extends GetxController {
  final AuthService authService = Get.find();
  final StoreService storeService = Get.find();
  final MenuWidgetController _menuC =
      Get.put(MenuWidgetController(), permanent: true);

  final isLoading = false.obs;
  late final account = authService.account;
  late final store = authService.store;

  final Rx<String> selectedUserString = Rx<String>('');

  final TextEditingController passwordController = TextEditingController();

  void selectUserString(String user) {
    selectedUserString.value = user;
  }

  @override
  void onInit() async {
    isLoading.value = true;
    // final users = account.value?.users;
    // if (users == null || users.isEmpty) {
    //   goToHome();
    // } else {
    final selectedUser = await authService.getSelectedCashier();
    if (selectedUser != null) {
      selectedUserString.value = selectedUser.name;
      goToHome();
    } else {
      final userName = await HiveBox.getSelectedUser();
      if (userName != null && userName.isNotEmpty) {
        selectedUserString.value = userName;
        goToHome();
      }
    }
    // }
    isLoading.value = false;
    super.onInit();
  }

  void goToHome() {
    _menuC.getMenu();
    Get.offAllNamed(Routes.HOME);
  }

  void loginUserHandle() {
    if (selectedUserString.isNotEmpty) {
      final accountValue = account.value;
      if (accountValue == null) return;

      print('objecta casr role ${accountValue.role}');

      if (accountValue.role == selectedUserString.value) {
        if (accountValue.password == passwordController.text) {
          print('Login berhasil untuk ${selectedUserString.value}');
          HiveBox.saveSelectedUser(selectedUserString.value);

          goToHome();
        } else {
          showErrorDialog('Pin yang dimasukkan salah');
        }
      } else {
        final cashier = accountValue.users
            .firstWhereOrNull((u) => u.name == selectedUserString.value);
        if (cashier != null) {
          if (cashier.password == passwordController.text) {
            print('objecta aws ${selectedUserString.value}');
            print('objecta casr ${cashier.name}');
            authService.selectedUser.value = cashier;

            goToHome();
          } else {
            showErrorDialog('Pin yang dimasukkan salah');
          }
        } else {
          showErrorDialog('User tidak ditemukan');
        }
      }
    } else {
      showErrorDialog('Pilih akun dan masukkan password!');
    }
  }

  void showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      content: Text(message),
    );
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (Get.find<InternetService>().isConnected.value) {
      await logout();
      Get.offNamed(Routes.LOGIN);
    } else {
      showErrorDialog('Tidak ada koneksi internet untuk mengeluarkan akun.');
    }
  }
}
