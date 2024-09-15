import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/auth_repository.dart';
import '../../models/account_model.dart';
import '../../models/store_model.dart';
import '../database/powersync.dart';

class AuthService extends GetxService implements AuthRepository {
  final supabaseClient = Supabase.instance.client;
  late final account = Rx<AccountModel?>(null);
  late final store = Rx<StoreModel?>(null);
  var isLogin = false;

  // @override
  // void onInit() async {
  //   super.onInit();
  // }

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
    } on AuthException catch (e) {
      print('AuthException: $e');
    }
  }

  @override
  Future<AccountModel> getAccount() async {
    while (db.currentStatus.lastSyncedAt == null) {
      await Future.delayed(const Duration(seconds: 2));
      print(db.currentStatus);
      print('menunggu koneksi');
      if (db.currentStatus.lastSyncedAt == null) {
        print('mencoba koneksi ulang');
      }
    }
    final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
        [supabaseClient.auth.currentUser!.id]);
    account.value = AccountModel.fromRow(row);
    print('AuthService: ${account.value}');
    return account.value!;
  }

  @override
  Future<StoreModel> getStore() async {
    while (db.currentStatus.lastSyncedAt == null) {
      await Future.delayed(const Duration(seconds: 2));
      print(db.currentStatus);
      print('menunggu koneksi');
      if (db.currentStatus.lastSyncedAt == null) {
        print('mencoba koneksi ulang');
      }
    }
    final row = await db
        .get('SELECT * FROM stores WHERE id = ?', [account.value!.storeId!]);
    store.value = StoreModel.fromRow(row);
    return store.value!;
  }
}
