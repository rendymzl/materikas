import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:permission_handler/permission_handler.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/product_model.dart';
import '../detail_product/detail_product_controller.dart';

class ProductController extends GetxController {
  late final AuthService _authService = Get.find();
  final ProductService _productService = Get.find<ProductService>();
  DetailProductController controller = Get.put(DetailProductController());

  late final products = _productService.products;
  late final foundProducts = _productService.foundProducts;
  late final lastCode = _productService.lastProductCode;
  late final lowStockProduct = _productService.lowStockProducts;

  final processSequence = 1.obs;
  final isAddExcelLoading = false.obs;
  final processMessage = ''.obs;

  var displayedItems = <ProductModel>[].obs; // Data yang ditampilkan saat ini
  var isLoading = false.obs; // Untuk memantau status loading
  var hasMore = true.obs; // Memantau apakah masih ada data lagi
  var page = 1; // Halaman data saat ini

  final int limit = 20; // Batas data per halaman

  final editProduct = true.obs;
  final destroyProduct = true.obs;

  Rx<File?> file = Rx<File?>(null);

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

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      file.value = File(result.files.single.path!);
    }
  }

  Future<void> downloadExcelTemplate() async {
    print('download...');
    // Meminta izin penyimpanan
    if (await Permission.storage.request().isGranted) {
      try {
        String? selectedDirectory =
            await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory == null) {
          return;
        }

        // Path relatif file dari root proyek
        String projectRelativePath =
            'assets/template_tambah_barang_materikas.xlsx';

        // Baca file dari path relatif
        File file = File(projectRelativePath);
        if (!file.existsSync()) {
          throw Exception('File tidak ditemukan pada path tersebut.');
        }

        // Baca byte dari file
        List<int> bytes = file.readAsBytesSync();

        // Mendapatkan path untuk menyimpan file di penyimpanan perangkat
        // Directory? directory = await getExternalStorageDirectory();
        String downloadPath =
            '$selectedDirectory/template_tambah_barang_materikas.xlsx';

        // Simpan file ke penyimpanan perangkat
        File(downloadPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);

        // Menampilkan pesan berhasil
        Get.defaultDialog(
          title: 'Berhasil',
          middleText: 'File template telah diunduh: $downloadPath',
        );
      } catch (e) {
        // Menampilkan pesan jika terjadi kesalahan
        Get.defaultDialog(
          title: 'Gagal',
          middleText: 'Gagal mengunduh file: $e',
        );
      }
    } else {
      // Menampilkan pesan jika izin tidak diberikan
      Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Izin penyimpanan tidak diberikan.',
      );
    }
  }

  Future<void> readAndUploadExcel() async {
    if (file.value == null) return;

    var bytes = file.value!.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Ambil sheet pertama
    Sheet sheet = excel.sheets.values.first;

    var updatedProductList = <ProductModel>[];

    // Menampilkan data di console (atau kirim ke Supabase)
    int numberId =
        (lastCode.value != '') ? int.parse(lastCode.value.substring(2)) : 0;

    isAddExcelLoading.value = true;
    int dataLenght = sheet.rows.skip(1).length;
    for (var row in sheet.rows.skip(1)) {
      processMessage.value =
          'Menambahkan Barang ke ${processSequence.value} dari $dataLenght';
      String? barcode = row[0]?.value?.toString();
      RxDouble sold =
          (double.tryParse(row[1]?.value?.toString() ?? '0') ?? 0).obs;
      String? productName = row[2]?.value?.toString() ?? '';
      RxDouble costPrice =
          (double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0).obs;
      RxDouble sellPrice1 =
          (double.tryParse(row[4]?.value?.toString() ?? '0') ?? 0).obs;
      RxDouble sellPrice2 =
          (double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0).obs;
      RxDouble sellPrice3 =
          (double.tryParse(row[6]?.value?.toString() ?? '0') ?? 0).obs;
      RxDouble stock = (double.tryParse(
                  row[7]?.value?.toString().replaceAll(',', '.') ?? '0') ??
              0)
          .obs;
      String? unit = row[8]?.value?.toString() ?? '';
      RxDouble stockMin =
          (double.tryParse(row[9]?.value?.toString() ?? '0') ?? 0).obs;
      print(unit);
      var product = ProductModel(
        storeId: _authService.store.value!.id!,
        productId:
            'BR${controller.generateNumberId(numberId + processSequence.value)}',
        barcode: barcode,
        productName: productName,
        unit: unit,
        costPrice: costPrice,
        sellPrice1: sellPrice1,
        sellPrice2: sellPrice2,
        sellPrice3: sellPrice3,
        stock: stock,
        sold: sold,
        stockMin: stockMin,
      );
      updatedProductList.add(product);
      processSequence.value++;
    }
    await _productService.insertList(updatedProductList);
    print('tambah barang dimulai ${updatedProductList.length} ');
    processSequence.value = 1;
    processMessage.value = '';
    isAddExcelLoading.value = false;
  }

  // exportHandle() async {
  //   try {
  //     AppDialog.show(
  //       title: 'Export Barang',
  //       content: 'Export daftar barang?',
  //       confirmText: "Ya",
  //       cancelText: "Tidak",
  //       onConfirm: () async {
  //         _productService.backup(_authService.store.value!.id!);
  //         Get.back();
  //       },
  //       onCancel: () => Get.back(),
  //     );
  //   } catch (e) {
  //     Get.defaultDialog(
  //       title: 'Error',
  //       middleText: e.toString(),
  //     );
  //   }
  // }
}
