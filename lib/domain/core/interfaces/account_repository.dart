import '../../../infrastructure/models/account_model.dart';

abstract class AccountRepository {
  Future<void> insert(AccountModel account);
  Future<void> update(AccountModel updatedAccount);
  Future<void> delete(String id);
}
