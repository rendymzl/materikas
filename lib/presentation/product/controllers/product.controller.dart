import 'dart:async';

import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../global_widget/app_dialog_widget.dart';

class ProductController extends GetxController {
  late final AuthService _authService = Get.find();
  final ProductService _productService = Get.find<ProductService>();

  late final products = _productService.products;
  late final foundProducts = _productService.foundProducts;
  late final lastCode = _productService.lastProductCode;
  late final lowStockProduct = _productService.lowStockProducts;

  var displayedItems = <ProductModel>[].obs; // Data yang ditampilkan saat ini
  var isLoading = false.obs; // Untuk memantau status loading
  var hasMore = true.obs; // Memantau apakah masih ada data lagi
  var page = 1; // Halaman data saat ini

  final int limit = 20; // Batas data per halaman

  final editProduct = true.obs;
  final destroyProduct = true.obs;

  @override
  void onInit() async {
    super.onInit();
    loadMore(); // Memuat data awal
    ever(foundProducts, (value) {
      hasMore.value = true;
      page = 1;
      displayedItems.clear();
      loadMore();
    });
    editProduct.value = await _authService.checkAccess('editProduct');
    destroyProduct.value = await _authService.checkAccess('destroyProduct');
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
    });
  }

  final isLowStock = false.obs;
  void toggleLowStock() {
    isLowStock.value = !isLowStock.value;
  }

  exportHandle() async {
    try {
      AppDialog.show(
        title: 'Export Barang',
        content: 'Export daftar barang?',
        confirmText: "Ya",
        cancelText: "Tidak",
        onConfirm: () async {
          _productService.backup(_authService.store.value!.id!);
          Get.back();
        },
        onCancel: () => Get.back(),
      );
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.toString(),
      );
    }
  }
}
