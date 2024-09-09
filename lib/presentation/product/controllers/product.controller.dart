import 'package:get/get.dart';

import '../../../infrastructure/dal/services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  late final products = _productService.products;
  late final foundProducts = _productService.foundProducts;
  late final lastCode = _productService.lastProductCode;
  late final lowStockProduct = _productService.lowStockProducts;

  void filterProducts(String productName) {
    _productService.search(productName);
  }

  final isLowStock = false.obs;
  void toggleLowStock() {
    isLowStock.value = !isLowStock.value;
  }
}
