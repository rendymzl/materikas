import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/product_model.dart';
import '../detail_product/detail_product_controller.dart';

class ProductController extends GetxController {
  late final AuthService _authService = Get.find();
  final ProductService _productService = Get.find<ProductService>();
  // late final DetailProductController controller =
  //     Get.put(DetailProductController());

  late final lastCode = _productService.lastCode;
  late final productsLenght = _productService.productsLenght;
  late final searchValue = ''.obs;

  final processSequence = 1.obs;
  final isAddExcelLoading = false.obs;
  final processMessage = ''.obs;

  var displayedItems = <ProductModel>[].obs;
  var isLoading = false.obs;
  var hasMore = true.obs;
  var offset = 0;

  final int limit = 25;
  final isLowStock = false.obs;

  final editProduct = true.obs;
  final destroyProduct = true.obs;

  Rx<File?> file = Rx<File?>(null);

  @override
  void onInit() async {
    await fetch(isClean: true);
    ever(_productService.updatedCount, (_) async {
      await fetch();
    });
    editProduct.value = await _authService.checkAccess('editProduct');
    destroyProduct.value = await _authService.checkAccess('destroyProduct');
    super.onInit();
  }

  Future<void> fetch({bool isClean = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    print('isClean $isClean');
    print('offset $offset');
    if (isClean) {
      hasMore.value = true;
      offset = 0;
      displayedItems.clear();
    }

    if (!hasMore.value) return;

    List<ProductModel> results = await _productService.fetch(
      offset: offset,
      limit: limit,
      search: searchValue.value,
      isLowStockFilter: isLowStock.value,
    );

    if (results.isEmpty) {
      hasMore.value = false;
    } else {
      displayedItems.addAll(results);
      offset += limit;
    }
    isLoading.value = false;
  }

  Timer? debounceTimer;
  Future<void> filterProducts(String productName) async {
    if (!isLoading.value) {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        searchValue.value = productName;
        print('searchValue.value ${searchValue.value}');
        await fetch(isClean: true);
      });
    }
  }

  void toggleLowStock() async {
    isLowStock.value = !isLowStock.value;
    await fetch(isClean: true);
    // if (isLowStock.value) {
    //   displayedItems.sort((a, b) => (a.stock.value - a.stockMin.value)
    //       .compareTo(b.stock.value - b.stockMin.value));
    // } else {
    //   displayedItems.sort((a, b) => a.productName.compareTo(b.productName));
    // }
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
            'BR${(numberId + processSequence.value).toString().padLeft(4, '0')}',
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
