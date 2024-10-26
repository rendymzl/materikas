import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/menu_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import 'menu_data.dart';

class MenuWidgetController extends GetxController {
  final AuthService authService = Get.find();
  final BillingService billingService = Get.find();
  SupabaseClient supabase = Supabase.instance.client;

  // final isConnected = true.obs;

  late final account = Rx<AccountModel?>(null);
  late final isOwner = authService.isOwner;
  late final CountdownTimer countdown;
  // final selectedIndex = 0.obs;
  // final selectedUser = ''.obs;
  final menuData = <MenuModel>[].obs;
  late final subsExpired = false.obs;

  @override
  void onInit() async {
    debugPrint('MenuWidgetController INIT');
    account.value = authService.account.value;
    // ever(billingService.isExpired, (_) {
    //   billingService.isExpired.value =
    //       !billingService.isLastMonthBillPaid.value &&
    //           DateTime.now().isAfter(DateTime(
    //               billingService.thisMonth.value.year,
    //               billingService.thisMonth.value.month,
    //               10));
    //   print('awdwadwadwad ${billingService.isExpired.value}');
    // });
    countdown = CountdownTimer(
      endTime: DateTime(billingService.nextMonth.year,
              billingService.nextMonth.month, billingService.nextMonth.day)
          .add(const Duration(days: -1))
          .millisecondsSinceEpoch,
      widgetBuilder: (_, CurrentRemainingTime? time) {
        // Pastikan 'time' nullable
        if (time == null) {
          // subsExpired.value = true;
          return const Text('');
        }
        // Gunakan nilai default jika null
        return Text(
          '${time.days ?? 0} Hari, ${time.hours ?? 0} : ${time.min ?? 0} : ${time.sec ?? 0}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      },
    );

    // isConnected.value = authService.connected.value;
    getMenu();

    super.onInit();
  }

  void getMenu() {
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
    authService.selectedIndexMenu.value = index;
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
    menuData.clear();
    var box = await Hive.openBox('selectedUser');
    box.put('user', '');
    authService.selectedIndexMenu.value = 0;
    Get.offAllNamed(Routes.SELECT_USER);
  }

  Future<void> signOut() async {
    if (authService.connected.value) {
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
