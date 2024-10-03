import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/auth_repository.dart';
// import '../../../presentation/global_widget/menu_widget/menu_controller.dart';
import '../../models/account_model.dart';
import '../../models/store_model.dart';
import '../../navigation/routes.dart';
import '../database/powersync.dart';

class AuthService extends GetxService implements AuthRepository {
  final supabaseClient = Supabase.instance.client;

  late StreamSubscription<List<ConnectivityResult>> connectivitySubs;
  final connected = true.obs;
  final loadingStatus = 'Menghubungkan...'.obs;
  RxBool hasSynced = false.obs;

  late final account = Rx<AccountModel?>(null);
  late final store = Rx<StoreModel?>(null);
  late final cashiers = RxList<Cashier>(<Cashier>[]);
  late final selectedUser = Rx<Cashier?>(null);
  final selectedIndexMenu = 0.obs;
  // late final selectedUser = ''.obs;

  var isLogin = false;
  var isOwner = false.obs;

  void checkStats() {
    loadingStatus.value = '${db.currentStatus}';
  }

  Future<bool> checkAccess(String code) async {
    final accessList = selectedUser.value?.accessList ?? [];
    return isOwner.value || accessList.contains(code);
  }

  @override
  void onInit() async {
    connectivitySubs = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      print('connection change : $result');
      connected.value = !result.contains(ConnectivityResult.none);
    });
    super.onInit();
  }

  @override
  Future<bool> isLoggedIn() async {
    final dbUser = supabaseClient.auth.currentUser;
    return dbUser != null;
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      //! await Fetch Data
      Get.offAllNamed(Routes.SPLASH);
    } on AuthException catch (e) {
      print('AuthException: $e');
      Get.defaultDialog(
        title: 'Error',
        content: const Text('Email atau password yang anda masukkan salah'),
      );
    }
  }

  @override
  Future<AccountModel> getAccount() async {
    if (db.currentStatus.connecting == false) {
      while (db.currentStatus.lastSyncedAt == null) {
        await Future.delayed(const Duration(seconds: 2));
        print(db.currentStatus);
        print('Menunggu koneksi, ${db.currentStatus.lastSyncedAt}');
        loadingStatus.value = 'Menunggu koneksi ${db.currentStatus.anyError}';
        if (db.currentStatus.lastSyncedAt == null) {
          print('Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
          loadingStatus.value = 'Mencoba koneksi ulang, ${db.currentStatus}';
        }
      }
    }
    final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
        [supabaseClient.auth.currentUser!.id]);
    account.value = AccountModel.fromRow(row);
    print('AuthService: ${account.value}');
    hasSynced.value = true;
    return account.value!;
  }

  @override
  Future<StoreModel> getStore() async {
    loadingStatus.value =
        'Menghubungkan Toko, ${db.currentStatus.lastSyncedAt}';
    // while (db.currentStatus.lastSyncedAt == null) {
    await Future.delayed(const Duration(seconds: 2));
    print(db.currentStatus);
    print('menunggu koneksi');
    // if (db.currentStatus.lastSyncedAt == null) {
    //   print('mencoba koneksi ulang');
    // }
    // }
    final row = await db
        .get('SELECT * FROM stores WHERE id = ?', [account.value!.storeId!]);
    store.value = StoreModel.fromRow(row);
    return store.value!;
  }

  @override
  RxList<Cashier> getCashier() {
    loadingStatus.value =
        'Mengambil data Toko, ${db.currentStatus.lastSyncedAt}';
    if (account.value!.users.isNotEmpty) {
      print('account.value!.users ${account.value!.users.length}');
      cashiers.assignAll(
          account.value!.users..sort((a, b) => a.id!.compareTo(b.id!)));
    }
    return cashiers;
  }

  @override
  Cashier? getSelectedCashier(userName) {
    selectedUser.value =
        account.value!.users.firstWhereOrNull((user) => user.name == userName);
    isOwner.value = selectedUser.value == null;

    return selectedUser.value;
  }
}
