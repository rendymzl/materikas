import 'package:get/get.dart';

import '../../../../presentation/operating_cost/controllers/operating_cost.controller.dart';

class OperatingCostControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OperatingCostController>(
      () => OperatingCostController(),
    );
  }
}
