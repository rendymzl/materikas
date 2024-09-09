import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/menu_widget/menu_controller.dart';

class SelectUserController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ProductService _productService = Get.put(ProductService());
  final InvoiceService _invoiceService = Get.put(InvoiceService());
  final CustomerService _customerService = Get.put(CustomerService());
  final MenuWidgetController _menuC =
      Get.put(MenuWidgetController(), permanent: true);

  late final AccountModel? account;

  final List<Map<String, dynamic>> workers = [
    {'name': 'Account 1', 'password': '1234'},
    {'name': 'Account 2', 'password': '1234'},
    {'name': 'Account 3', 'password': '1234'},
  ].obs;
  var selectedUser = ''.obs;
  late final isConnected = false.obs;
  final TextEditingController passwordController = TextEditingController();

  void selectUser(String user) {
    selectedUser.value = user;
  }

  @override
  void onInit() async {
    print('SelectUserController INIT');
    isConnected.value = await _menuC.connected.value;
    print('SelectUserController getAccount');
    account = await _authService.account.value;
    await _invoiceService.subscribe(account!.storeId!);
    await _productService.subscribe(account!.storeId!);
    await _customerService.subscribe(account!.storeId!);
    print('SelectUserController FINISH INIT');
    // print('SelectUserController : ${account.value}');
    super.onInit();
  }

  void loginUserHandle() {
    if (selectedUser.isNotEmpty && passwordController.text.isNotEmpty) {
      // Implementasi logika login
      final worker = workers
          .firstWhereOrNull((worker) => worker['name'] == selectedUser.value);
      if (worker != null && worker['password'] == passwordController.text) {
        print('Login berhasil untuk ${selectedUser.value}');
        Get.offAllNamed(Routes.HOME);
      } else {
        if ('Admin' == selectedUser.value &&
            '1234' == passwordController.text) {
          print('Login berhasil untuk ${selectedUser.value}');
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.defaultDialog(
            title: 'Error',
            content: Text('Password tidak cocok dengan akun yang dipilih!'),
          );
        }
      }
    } else {
      // Tampilkan pesan kesalahan jika akun atau password tidak diisi
      Get.defaultDialog(
        title: 'Error',
        content: Text('Harap pilih akun dan masukkan password!'),
      );
    }
  }

  Future<void> signOut() async {
    // try {
    if (isConnected.value) {
      await _authService.supabaseClient.auth.signOut();
      Get.offNamed(Routes.LOGIN);
    } else {
      AppDialog.show(
        title: 'Error',
        content: 'Tidak ada koneksi internet untuk mengeluarkan akun.',
        onConfirm: () {
          Get.back();
          Get.back();
        },
      );
      // await Get.defaultDialog(
      //   title: 'Error',
      //   middleText: 'Tidak ada koneksi internet untuk mengeluarkan akun.',
      //   confirm: TextButton(
      //     onPressed: () {
      //       Get.back();
      //       Get.back();
      //     },
      //     child: const Text('OK'),
      //   ),
      // );
    }
  }
}
