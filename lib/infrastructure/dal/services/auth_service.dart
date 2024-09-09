import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/auth_repository.dart';
import '../../models/account_model.dart';
import '../database/powersync.dart';

class AuthService extends GetxService implements AuthRepository {
  final supabaseClient = Supabase.instance.client;
  late final account = Rx<AccountModel?>(null);
  var isLogin = false;

  @override
  void onInit() async {
    print('AuthService INIT');
    super.onInit();
  }

  @override
  Future<bool> isLoggedIn() async {
    final dbUser = await supabaseClient.auth.currentUser;
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
    final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
        [supabaseClient.auth.currentUser!.id]);
    account.value = await AccountModel.fromRow(row);
    print('AuthService: ${account.value}');
    return account.value!;
  }

  static Future<Stream<List<AccountModel>>> subscribe(String id) async {
    try {
      return db.watch('SELECT * FROM accounts WHERE account_id = ?',
          parameters: [
            id
          ]).map(
          (data) => data.map((json) => AccountModel.fromJson(json)).toList());
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }
}
