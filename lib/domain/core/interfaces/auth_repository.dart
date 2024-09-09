import '../../../infrastructure/models/account_model.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> login(String email, String password);
  Future<AccountModel> getAccount();
}
