import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/navigation/routes.dart';

class SplashController extends GetxController {
  late final AuthService _authService = Get.put(AuthService());

  void Init() async {
    print('SplashController INIT');
    print('SplashController: checking login...');
    final isLoggedIn = await _authService.isLoggedIn();
    print('SplashController: isLoggedIn $isLoggedIn');
    if (isLoggedIn) {
      print('SplashController: Get Account');
      await _authService.getAccount();
      print('SplashController: ${_authService.getAccount()}');
      Get.offAllNamed(Routes.SELECT_USER);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
    ;
  }

  // Future<bool> checkLoginStatus() async {
  //   return await _authService.isLoggedIn();
  // }

  // Future<AccountModel?> getAccount() async {
  //   return await _authService.getAccount();
  // }
}
