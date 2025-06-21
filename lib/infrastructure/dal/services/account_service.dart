import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/account_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/account_repository.dart';
import '../database/powersync.dart';

class AccountService extends GetxService implements AccountRepository {
  final supabaseClient = Supabase.instance.client;

  Future<AccountModel> get() async {
    AccountModel? account;
    int retryCount = 0;
    const maxRetries = 5;
    const retryDelay = Duration(seconds: 3);

    while (account == null && retryCount < maxRetries) {
      try {
        print('retryCount percobaan ke-${retryCount}');
        final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
            [supabaseClient.auth.currentUser!.id]);
        account = AccountModel.fromRow(row);
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          print('retryCount ${retryCount}');
          // Handle the error appropriately, e.g., throw an exception or return a default value.
          throw Exception(
              'Gagal mengambil data akun setelah beberapa kali percobaan: $e');
        }
      }
    }
    return account!;
  }

  @override
  Future<void> insert(AccountModel account) async {
    try {
      db.execute('''
      INSERT INTO accounts(
      id, account_id, created_at, name, email, role, store_id, users, password, account_type, start_date, end_date, is_active, updated_at, affiliate_id, token)
      VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        account.accountId,
        account.createdAt.toIso8601String(),
        account.name,
        account.email,
        account.role,
        account.storeId,
        account.users.map((e) => e.toJson()).toList(),
        account.password,
        account.accountType,
        account.startDate?.toIso8601String(),
        account.endDate?.toIso8601String(),
        account.isActive,
        DateTime.now().toIso8601String(),
        account.affiliateId,
        account.token
      ]);
      // await Supabase.instance.client
      //     .from('accounts')
      //     .insert([account.toJson()]);
    } catch (e) {
      print(e);
    }
  }

  Future<void> directInsert(AccountModel account) async {
    try {
      await Supabase.instance.client
          .from('accounts')
          .insert([account.toJson()]);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> update(AccountModel updatedAccount) async {
    await db.execute('''
      UPDATE accounts
      SET account_id = ?, created_at = ?, name = ?, email = ?, role = ?, store_id = ?, users = ?, password = ?, account_type = ?, start_date = ?, end_date = ?, is_active = ?, updated_at = ?, affiliate_id = ?, token = ?
      WHERE id = ?
    ''', [
      updatedAccount.accountId,
      updatedAccount.createdAt.toIso8601String(),
      updatedAccount.name,
      updatedAccount.email,
      updatedAccount.role,
      updatedAccount.storeId,
      updatedAccount.users.map((e) => e.toJson()).toList(),
      updatedAccount.password,
      updatedAccount.accountType,
      updatedAccount.startDate?.toIso8601String(),
      updatedAccount.endDate?.toIso8601String(),
      updatedAccount.isActive,
      DateTime.now().toIso8601String(),
      updatedAccount.affiliateId,
      updatedAccount.token,
      updatedAccount.id
    ]);
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM accounts WHERE id = ?', [id]);
  }
}
