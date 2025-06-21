import 'package:get/get.dart';

import '../../../infrastructure/models/account_model.dart';
// import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/models/user_model.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> login(String email, String password);
  Future<void> insert(AccountModel account);
  RxList<Cashier> getCashier();
  Future<Cashier?> getSelectedCashier();
}
