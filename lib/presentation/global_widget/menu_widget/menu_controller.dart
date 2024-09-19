import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/menu_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import 'menu_data.dart';

class MenuWidgetController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  SupabaseClient supabase = Supabase.instance.client;

  final connected = true.obs;

  late final account = Rx<AccountModel?>(null);
  late final isOwner = _authService.isOwner;
  final selectedIndex = 0.obs;
  // final selectedUser = ''.obs;
  final menuData = <MenuModel>[].obs;

  @override
  void onInit() async {
    debugPrint('MenuWidgetController INIT');
    account.value = _authService.account.value;
    connected.value = _authService.connected.value;
    getMenu();
    // selectedUser.value = _authService.selectedUser.value;

    // ever(account, (_) {
    //   isOwner.value = account.value?.role == 'owner';

    //   print('MenuWidgetController: isAdmin ${isOwner.value}');
    // });

    super.onInit();
  }

  void getMenu() {
    Future.delayed(Duration.zero, () {
      menuData.clear();

      menuData.add(transaction);
      final accessList = _authService.selectedUser.value?.accessList ?? [];
      final menus = [
        invoiceMenu,
        customerMenu,
        productMenu,
        salesMenu,
        operationalMenu,
        statisticMenu,
      ];
      for (var menu in menus) {
        if (isOwner.value || accessList.contains(menu.label)) {
          menuData.add(menu);
        }
      }
      if (isOwner.value) menuData.add(storeMenu);
    });
  }

  void handleClick(int index, String label) {
    selectedIndex.value = index;
    switch (label) {
      case 'Transaksi':
        Get.offNamed(Routes.HOME);
        break;
      case 'Invoice':
        Get.offNamed(Routes.INVOICE);
        break;
      case 'Pelanggan':
        Get.offNamed(Routes.CUSTOMER);
        break;
      case 'Barang':
        Get.offNamed(Routes.PRODUCT);
        break;
      case 'Sales':
        Get.offNamed(Routes.SALES);
        break;
      case 'Laporan':
        Get.offNamed(Routes.STATISTIC);
        break;
      case 'Operasional':
        Get.offNamed(Routes.OPERATING_COST);
        break;
      default:
        Get.offNamed(Routes.PROFILE);
        break;
    }
  }

  Future<void> changeUser() async {
    var box = await Hive.openBox('selectedUser');
    box.put('user', '');
    Get.offAllNamed(Routes.SELECT_USER);
  }

  Future<void> signOut() async {
    if (_authService.connected.value) {
      await Supabase.instance.client.auth.signOut();
      Get.offNamed(Routes.LOGIN);
    } else {
      await Get.defaultDialog(
        title: 'Error',
        middleText: 'Tidak ada koneksi internet untuk mengeluarkan akun.',
        confirm: TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    }
  }
}
