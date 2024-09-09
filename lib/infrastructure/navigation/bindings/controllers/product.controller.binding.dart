import 'package:get/get.dart';

import '../../../../presentation/product/controllers/product.controller.dart';

class ProductControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(
      () => ProductController(),
    );
  }
}
