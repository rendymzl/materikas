import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import 'menu_data.dart';

class MenuWidgetController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  SupabaseClient supabase = Supabase.instance.client;

  final connected = true.obs;

  late final account = Rx<AccountModel?>(null);
  final isAdmin = false.obs;
  final selectedIndex = 0.obs;
  final selectedUser = ''.obs;
  final data = MenuData().obs;

  @override
  void onInit() async {
    debugPrint('MenuWidgetController INIT');
    account.value = _authService.account.value;
    connected.value = _authService.connected.value;
    ever(account, (_) {
      isAdmin.value = account.value?.role == 'owner';
      print('MenuWidgetController: isAdmin ${isAdmin.value}');
    });
    ever(selectedIndex, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectedUser.value = _authService.selectedUser.value;
      });
    });
    super.onInit();
  }

  void handleClick(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        Get.offNamed(Routes.HOME);
        break;
      case 1:
        Get.offNamed(Routes.INVOICE);
        break;
      case 2:
        Get.offNamed(Routes.CUSTOMER);
        break;
      case 3:
        Get.offNamed(Routes.PRODUCT);
        break;
      case 4:
        Get.offNamed(Routes.SALES);
        break;
      case 5:
        Get.offNamed(Routes.STATISTIC);
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
