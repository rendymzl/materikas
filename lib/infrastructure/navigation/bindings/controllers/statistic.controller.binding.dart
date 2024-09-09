import 'package:get/get.dart';

import '../../../../presentation/statistic/controllers/statistic.controller.dart';

class StatisticControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticController>(
      () => StatisticController(),
    );
  }
}
