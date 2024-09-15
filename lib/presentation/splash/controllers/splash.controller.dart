import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class SplashController extends GetxController {
  late final AuthService _authService = Get.put(AuthService());

  void init() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await _authService.getAccount();
      await _authService.getStore();
      Get.offAllNamed(Routes.SELECT_USER);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
