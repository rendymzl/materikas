import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/menu_widget/menu_controller.dart';

class SelectUserController extends GetxController {
  late final AuthService authService = Get.find();
  late final MenuWidgetController _menuC =
      Get.put(MenuWidgetController(), permanent: true);

  late final Box<dynamic> box;
  final isLoading = false.obs;
  // late final loadingStatus = authService.loadingStatus;
  // late final isConnected = authService.connected;
  late final account = authService.account;
  late final store = authService.store;

  // final workers = <Cashier>[].obs;
  var selectedUser = ''.obs;

  final TextEditingController passwordController = TextEditingController();

  void selectUser(String user) {
    selectedUser.value = user;
  }

  @override
  void onInit() async {
    isLoading.value = true;
    // authService.loadingStatus.value = 'Menghubungkan User...';
    box = await Hive.openBox('selectedUser');
    // authService.loadingStatus.value = 'Menghubungkan Akun...';
    await authService.getAccount();
    await authService.getStore();
    isLoading.value = false;
    // print('SelectUserController : ${account.value}');
    String? user = await isSelectedUser();
    if (user?.isNotEmpty ?? false) {
      print('usernya $user');
      selectedUser.value = user!;
      authService.getSelectedCashier(user);
      authService.selectedIndexMenu.value = 0;
      _menuC.getMenu();
      Get.offAllNamed(Routes.HOME);
    }
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    super.onInit();
  }

  Future<String?> isSelectedUser() async {
    return box.get('user');
  }

  void goToHome() {
    authService.getSelectedCashier(selectedUser.value);
    box.put('user', selectedUser.value);
    authService.isOwner.value = account.value!.role == selectedUser.value;
    _menuC.getMenu();
    Get.offAllNamed(Routes.HOME);
  }

  void loginUserHandle() {
    if (selectedUser.isNotEmpty && passwordController.text.isNotEmpty) {
      // Implementasi logika login
      if (account.value!.role == selectedUser.value) {
        if (account.value!.password == passwordController.text) {
          print('Login berhasil untuk ${selectedUser.value}');
          goToHome();
        } else {
          Get.defaultDialog(
            title: 'Error',
            content: const Text('Ada yang salah, silahkan coba lagi'),
          );
        }
      } else {
        var cashier = account.value!.users.firstWhereOrNull(
          (u) => u.name == selectedUser.value,
        );
        if (cashier != null) {
          if (cashier.password == passwordController.text) {
            goToHome();
          } else {
            Get.defaultDialog(
              title: 'Error',
              content:
                  const Text('Password tidak cocok dengan akun yang dipilih!'),
            );
          }
        }
      }
    } else {
      // Tampilkan pesan kesalahan jika akun atau password tidak diisi
      Get.defaultDialog(
        title: 'Error',
        content: const Text('Harap pilih akun dan masukkan password!'),
      );
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // try {
    if (authService.connected.value) {
      await logout();
      Get.offNamed(Routes.LOGIN);
    } else {
      print('ga ada inet');

      await Get.defaultDialog(
        title: 'Error',
        content:
            const Text('Tidak ada koneksi internet untuk mengeluarkan akun.'),
      );
    }
  }
}
