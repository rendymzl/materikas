import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/models/menu_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/hive_boxex.dart';
import 'menu_data.dart';

class MenuWidgetController extends GetxController {
  final hoveredIndex = (-1).obs;
  final RxInt selectedIndexMenu = 0.obs;
  late final selectedUserString = ''.obs;

  final AuthService authService = Get.find();
  final InternetService internetService = Get.find();
  final BillingService billingService = Get.put(BillingService());
  SupabaseClient supabase = Supabase.instance.client;

  late final isOwner = authService.isOwner;
  final menuData = <MenuModel>[].obs;

  void getMenu() {
    var aa = authService.checkIsOwner();
    print('objecta aaa ${aa}');
    print('objecta bbb ${authService.selectedUser.value?.name}');
    print('objecta ccc ${isOwner.value}');
    selectedIndexMenu.value = 0;
    Future.delayed(Duration.zero, () {
      menuData.clear();

      menuData.add(transaction);
      final accessList = authService.selectedUser.value?.accessList ?? [];
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
    print('menu index $index');
    selectedIndexMenu.value = index;
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
      case 'Supplier':
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
    menuData.clear();
    await HiveBox.saveSelectedUser('');
    selectedIndexMenu.value = 0;
    Get.offAllNamed(Routes.SELECT_USER);
  }

  Future<void> signOut() async {
    if (internetService.isConnected.value) {
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
