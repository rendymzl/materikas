import 'package:get/get.dart';

import '../../../../presentation/graph/controllers/graph.controller.dart';

class GraphControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GraphController>(
      () => GraphController(),
    );
  }
}
