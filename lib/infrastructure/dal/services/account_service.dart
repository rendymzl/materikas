import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/account_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/account_repository.dart';
import '../database/powersync.dart';

class AccountService extends GetxService implements AccountRepository {
  @override
  Future<void> insert(AccountModel account) async {
    try {
      print('acc1');
      // await db.execute('''
      //   INSERT INTO accounts(id, account_id, created_at, name, email, role, store_id, users, password, account_type, start_date, end_date, is_active, updated_at)
      //   VALUES (uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      // ''', [
      //   // account.id,
      //   account.accountId,
      //   account.createdAt.toIso8601String(),
      //   account.name,
      //   account.email,
      //   account.role,
      //   account.storeId,
      //   account.users.map((e) => e.toJson()).toList(),
      //   account.password,
      //   account.accountType,
      //   account.startDate?.toIso8601String(),
      //   account.endDate?.toIso8601String(),
      //   account.isActive! ? 1 : 0,
      //   DateTime.now().toIso8601String()
      // ]);
      await Supabase.instance.client
          .from('accounts')
          .insert([account.toJson()]);

      // await db.execute('''
      //   INSERT INTO accounts(id, account_id, created_at, name, email, role, store_id, users, password, account_type, start_date, end_date, is_active, updated_at)
      //   VALUES (uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      // ''', [
      //   // account.id,
      //   account.accountId,
      //   account.createdAt.toIso8601String(),
      //   account.name,
      //   account.email,
      //   account.role,
      //   account.storeId,
      //   account.users.map((e) => e.toJson()).toList(),
      //   account.password,
      //   account.accountType,
      //   account.startDate?.toIso8601String(),
      //   account.endDate?.toIso8601String(),
      //   account.isActive! ? 1 : 0,
      //   DateTime.now().toIso8601String()
      // ]);
      print('acc2');
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> update(AccountModel updatedAccount) async {
    await db.execute('''
      UPDATE accounts
      SET account_id = ?, created_at = ?, name = ?, email = ?, role = ?, store_id = ?, users = ?, password = ?, account_type = ?, start_date = ?, end_date = ?, is_active = ?, updated_at = ?
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
      updatedAccount.id
    ]);
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM accounts WHERE id = ?', [id]);
  }
}
