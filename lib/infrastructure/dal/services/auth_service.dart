import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:materikas/infrastructure/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/auth_repository.dart';
import '../../models/account_model.dart';
import '../../models/store_model.dart';
import '../../navigation/routes.dart';
import '../database/powersync.dart';

class AuthService extends GetxService implements AuthRepository {
  final supabaseClient = Supabase.instance.client;

  late StreamSubscription<List<ConnectivityResult>> connectivitySubs;
  final connected = true.obs;
  RxBool hasSynced = false.obs;

  late final account = Rx<AccountModel?>(null);
  late final store = Rx<StoreModel?>(null);
  late final cashiers = RxList<Cashier>(<Cashier>[]);
  late final selectedUser = Rx<Cashier?>(null);
  final selectedIndexMenu = 0.obs;

  var isLogin = false;
  var isOwner = false.obs;

  late final Box<dynamic> box;

  Future<bool> checkAccess(String code) async {
    final accessList = selectedUser.value?.accessList ?? [];
    return isOwner.value || accessList.contains(code);
  }

  @override
  void onInit() async {
    box = await Hive.openBox('midtrans');
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
      if (e.message.contains('Invalid login credentials')) {
        Get.defaultDialog(
          title: 'Error',
          content: const Text('Email atau password salah'),
        );
      } else {
        Get.defaultDialog(
          title: 'Error',
          content: const Text('Terjadi kesalahan, silakan coba lagi'),
        );
      }
    }
  }

  @override
  Future<AccountModel> getAccount() async {
    if (db.currentStatus.connecting == false) {
      while (db.currentStatus.lastSyncedAt == null) {
        await Future.delayed(const Duration(seconds: 2));
        print(db.currentStatus);
        print('Menunggu koneksi, ${db.currentStatus.lastSyncedAt}');

        if (db.currentStatus.lastSyncedAt == null) {
          print('Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
        }
      }
    }
    final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
        [supabaseClient.auth.currentUser!.id]);
    account.value = AccountModel.fromRow(row);
    hasSynced.value = true;
    return account.value!;
  }

  @override
  Future<StoreModel> getStore() async {
    if (db.currentStatus.connecting == false) {
      while (db.currentStatus.lastSyncedAt == null) {
        await Future.delayed(const Duration(seconds: 2));
        print(db.currentStatus);
        print('Menunggu koneksi, ${db.currentStatus.lastSyncedAt}');
        if (db.currentStatus.lastSyncedAt == null) {
          print('Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
        }
      }
    }

    print('MENGAMBIL DATA STORE : ${supabaseClient.auth.currentUser!.id}');
    final row = await db
        .get('SELECT * FROM stores WHERE id = ?', [account.value!.storeId]);
    store.value = StoreModel.fromRow(row);
    return store.value!;
  }

  @override
  RxList<Cashier> getCashier() {
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

  @override
  Future<void> insert(AccountModel account) {
    // TODO: implement insert
    throw UnimplementedError();
  }
}
