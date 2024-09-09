import 'package:get/get.dart';

import '../../../../presentation/sales/controllers/sales.controller.dart';

class SalesControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesController>(
      () => SalesController(),
    );
  }
}
