import 'package:get/get.dart';

import '../../../../presentation/select_user/controllers/select_user.controller.dart';

class SelectUserControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectUserController>(
      () => SelectUserController(),
    );
  }
}
