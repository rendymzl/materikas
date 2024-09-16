import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/account_model.dart';

import '../../../domain/core/interfaces/account_repository.dart';
import '../database/powersync.dart';

class AccountService extends GetxService implements AccountRepository {
  @override
  Future<void> insert(AccountModel account) async {
    await db.execute('''
      INSERT INTO accounts (id, account_id, created_at, name, email, role, store_id, users, password)
      VALUES (uuid(), ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      // id,
      account.accountId,
      account.createdAt.toIso8601String(),
      account.name,
      account.email,
      account.role,
      account.storeId,
      account.users.map((e) => e.toJson()).toList(),
      account.password
    ]);
  }

  @override
  Future<void> update(AccountModel updatedAccount) async {
    await db.execute('''
      UPDATE accounts
      SET account_id = ?, created_at = ?, name = ?, email = ?, role = ?, store_id = ?, users = ?, password = ?
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
      updatedAccount.id
    ]);
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM accounts WHERE id = ?', [id]);
  }
}
