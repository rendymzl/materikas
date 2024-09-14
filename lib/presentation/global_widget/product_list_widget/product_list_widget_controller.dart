import 'dart:async';

import 'package:get/get.dart';

import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/product_model.dart';

class ProductListWidgetController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  late final product = _productService.products;
  late final foundProducts = _productService.foundProducts;

  final priceType = 1.obs;

  var displayedItems = <ProductModel>[].obs; // Data yang ditampilkan saat ini
  var isLoading = false.obs; // Untuk memantau status loading
  var hasMore = true.obs; // Memantau apakah masih ada data lagi
  var page = 1; // Halaman data saat ini

  final int limit = 20; // Batas data per halaman

  @override
  void onInit() {
    super.onInit();
    loadMore(); // Memuat data awal
    ever(foundProducts, (value) {
      hasMore.value = true;
      page = 1;
      displayedItems.clear();
      loadMore();
    });
  }

  void loadMore() {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    // Ambil data dari list yang ada berdasarkan pagination
    int startIndex = (page - 1) * limit;
    int endIndex = startIndex + limit;

    List<ProductModel> newData = [];
    if (startIndex < foundProducts.length) {
      newData = foundProducts.sublist(startIndex,
          endIndex > foundProducts.length ? foundProducts.length : endIndex);
    }

    if (newData.isEmpty) {
      hasMore.value = false; // Tidak ada data lagi
    } else {
      displayedItems
          .addAll(newData); // Tambahkan data baru ke list yang ditampilkan
      page++; // Naikkan halaman
    }
    print(displayedItems.length);
    isLoading.value = false;
  }

  Timer? debounceTimer;
  void filterProducts(String productName) {
    if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _productService.search(productName);
      hasMore.value = true;
      page = 1;
      displayedItems.assignAll(foundProducts);
      print(displayedItems.length);
    });
  }
}
