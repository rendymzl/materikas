import 'package:get/get.dart';

import '../../../infrastructure/dal/services/product_service.dart';

class ProductListWidgetController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  late final product = _productService.products;
  late final foundProducts = _productService.foundProducts;

  final priceType = 1.obs;

  void filterProducts(String productName) {
    _productService.search(productName);
  }

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  // @override
  // void onClose() {
  //   super.onClose();
  // }
}
