import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:powersync/powersync.dart' as powersync;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/database/powersync_attachment.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/log_stock_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/hive_boxex.dart';

class ProductController extends GetxController {
  final authService = Get.find<AuthService>();
  final productService = Get.find<ProductService>();
  final invoiceService = Get.find<InvoiceService>();

  final isLoadingFetch = false.obs;
  final isInitLoading = false.obs;
  // final loadingNewImage = false.obs;
  var displayedItems = <ProductModel>[].obs;
  late final lastCode = productService.lastCode;
  late final productsLenght = productService.productsLenght;
  final editProduct = true.obs;
  final destroyProduct = true.obs;
  final selectedDate = DateTime.now().obs;

  // Future<void> setStock() async {
  //   await productService.firstStock();
  // }
  var dailyLogStock = <LogStock>[].obs;
  var logStock = <LogStock>[].obs;

  @override
  void onInit() async {
    isInitLoading.value = true;
    print('productC init');
    showImage.value = await HiveBox.getImageShow() ?? false;
    displayedItems.assignAll(productService.products);
    for (var aa in productService.products) {
      print('productC init ${aa.productName}');
      print('productC init ${aa.finalStock.value}');
    }
    editProduct.value = await authService.checkAccess('editProduct');
    destroyProduct.value = await authService.checkAccess('destroyProduct');
    dailyLogStock.assignAll(await productService.getLogNow());
    isInitLoading.value = false;
    everAll([
      isLowStock,
      productService.products,
      searchQuery,
    ], (_) async {
      if (isFiltered()) {
        print('isFiltered');
        var dataProduct = await fetch(isClean: true);
        displayedItems.assignAll(dataProduct);
      } else {
        print('noFilter');
        Timer(Duration(milliseconds: 200), () {
          displayedItems.assignAll(productService.products);
        });
      }
    });

    super.onInit();
  }

  bool isFiltered() {
    return searchQuery.isNotEmpty || isLowStock.value;
  }

  //! Scroll
  ScrollController scrollC = ScrollController();

  void onScroll() {
    double maxScroll = scrollC.position.maxScrollExtent;
    double currentScroll = scrollC.position.pixels;
    print('scroll debug maxScroll $maxScroll');
    print('scroll debug  currentScroll $currentScroll');
    if (maxScroll - 500 <= currentScroll &&
        hasMore.value &&
        isLoadingFetch.value == false) {
      // fetch();
      isLoadingFetch.value = true;
      loadProduct();
    }
  }

  void loadProduct() async {
    displayedItems.addAll(await fetch());
    isLoadingFetch.value = false;
  }

  //! Filter Product
  final hasMore = true.obs;
  int offset = 0;
  final int limit = 30;
  Future<List<ProductModel>> fetch({bool isClean = false}) async {
    if (isClean) {
      hasMore.value = true;
      offset = 0;
    }

    if (hasMore.value) {
      final results = await productService.fetch(
        isLowStock: isLowStock.value,
        limit: limit,
        offset: offset,
        search: searchQuery.value,
      );
      print(results.length);
      if (results.isEmpty) {
        hasMore.value = false;
        return <ProductModel>[];
      } else {
        offset += limit;
        return results;
      }
    } else {
      return <ProductModel>[];
    }
  }

  //! HEADER ================================
  //! - Search Product
  final searchQuery = ''.obs;

  void asignSearchTextC(TextEditingController serchTextC) {
    serchTextC.text = searchQuery.value;
  }

  Timer? debounceTimer;
  Future<void> searchProducts(String productName) async {
    if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 200), () async {
      searchQuery.value = productName;
    });
  }

  //! - Stock Product
  final isLowStock = false.obs;

  void toggleLowStock() async {
    isLowStock.value = !isLowStock.value;
  }

  //! - Show Image Product
  final showImage = false.obs;
  final isGridLayout = false.obs;

  void toggleShowImage() async {
    showImage.value = !showImage.value;
    await HiveBox.deleteImageShow();
    await HiveBox.saveImageShow(showImage.value);
  }

  void toggleGridLayout() async {
    isGridLayout.value = !isGridLayout.value;
    await HiveBox.deleteGridLayout();
    await HiveBox.saveGridLayout(isGridLayout.value);
  }

  //! -----------------------------------------------------------------------

  final processSequence = 1.obs;
  final isAddExcelLoading = false.obs;
  final processMessage = ''.obs;

  Rx<File?> file = Rx<File?>(null);

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
        print(file);
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

  Future<void> downloadProductExcel() async {
    try {
      var excel = Excel.createExcel();
      var sheetObject = excel.sheets[
          excel.sheets.keys.first]; // Menggunakan sheet pertama yang ada

      // Menambahkan header
      sheetObject!.appendRow([
        // TextCellValue('ID'),
        TextCellValue('Nama Produk'),
        TextCellValue('Ukuran'),
        TextCellValue('Barcode'),
        TextCellValue('Harga Beli'),
        TextCellValue('Harga Jual 1'),
        TextCellValue('Harga Jual 2'),
        TextCellValue('Harga Jual 3'),
        TextCellValue('Stok'),
      ]);

      // Menambahkan data produk
      for (var product in productService.products) {
        sheetObject.appendRow([
          // TextCellValue(product.id ?? ''),
          TextCellValue(product.productName),
          TextCellValue(product.unit),
          TextCellValue(product.barcode ?? ''),
          IntCellValue(product.costPrice.value.toInt()),
          IntCellValue(product.sellPrice1.value.toInt()),
          IntCellValue(product.sellPrice2?.value.toInt() ?? 0),
          IntCellValue(product.sellPrice3?.value.toInt() ?? 0),
          DoubleCellValue(product.finalStock.value),
        ]);
      }

      // Meminta izin penyimpanan
      PermissionStatus permissionStatus = await Permission.storage.request();

      // Memeriksa apakah izin diberikan
      if (permissionStatus.isGranted) {
        // Menyimpan file ke direktori yang dipilih pengguna
        String? directory = await FilePicker.platform.getDirectoryPath();
        if (directory == null) {
          return;
        }

        final now = DateTime.now();
        final formattedDate = "${now.year}-${now.month}-${now.day}";
        String filePath = '${directory}/daftar_barang_$formattedDate.xlsx';
        File file = File(filePath)..writeAsBytesSync(excel.encode()!);
        Get.defaultDialog(
          title: 'Berhasil',
          middleText: 'File Excel berhasil dibuat di: $filePath',
        );
      } else {
        // Menampilkan pesan jika izin tidak diberikan
        Get.defaultDialog(
          title: 'Gagal',
          middleText: 'Izin penyimpanan tidak diberikan.',
        );
      }
    } catch (e) {
      Get.defaultDialog(
        title: 'Gagal',
        middleText: 'Gagal membuat file Excel: $e',
      );
    }
  }

  // Fungsi untuk mengunggah gambar ke server
  late String imageUrl;
  Future<RxString?> uploadImage(
      ProductModel? currentProduct, String imageUrl) async {
    try {
      String imageId = powersync.uuid.v4();
      String storageDirectory = await attachmentQueue.getStorageDirectory();

      // Download gambar dari URL
      final response = await http.get(Uri.parse(imageUrl));
      print('response $response');
      if (response.statusCode == 200) {
        await File('$storageDirectory/$imageId.jpg')
            .writeAsBytes(response.bodyBytes);

        int photoSize = response.contentLength ?? 0;

        if (currentProduct != null && currentProduct.imageUrl != null) {
          await attachmentQueue.deleteFile(currentProduct.imageUrl!.value);
        }
        await attachmentQueue.saveFile(imageId, photoSize);

        return imageId.obs;
      }
      return null;
    } catch (e) {
      return null;
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
      String? imgUrl = row[10]?.value?.toString();
      RxString? imageUrl;
      if (imgUrl != null) {
        imageUrl = await uploadImage(null, imgUrl);
      }

      var product = ProductModel(
        id: powersync.uuid.v4(),
        storeId: authService.store.value!.id!,
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
        imageUrl: imageUrl,
      );
      updatedProductList.add(product);
      processSequence.value++;
    }
    await productService.insertList(updatedProductList);
    print('tambah barang dimulai ${updatedProductList.length} ');
    processSequence.value = 1;
    processMessage.value = '';
    isAddExcelLoading.value = false;
  }

  final loadingTest = false.obs;
  void gooooooo() async {
    loadingTest(true);
    var allProduct = await productService.getAllProduct();
    var count = 0;
    var updatedP = <ProductModel>[];
    for (var p in allProduct) {
      var stockByP = await productService.getLogByProduct(p);
      stockByP.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      var stokCreateAt = stockByP.firstWhereOrNull(
          (ls) => ls.label == 'Stok Awal' || ls.label == 'Update');
      print('goooooooooooooo ${allProduct.length}');
      print('goooooooooooooo ===');
      print('goooooooooooooo ${p.productName}');
      print('goooooooooooooo ${stokCreateAt?.productName}');
      print('goooooooooooooo ${stokCreateAt?.label}');
      print('goooooooooooooo createdAt ${stokCreateAt?.createdAt}');
      print('goooooooooooooo lastUpdated ${p.lastUpdated}');

      if (stokCreateAt != null) {
        var aaaa = DateTime(
          stokCreateAt.createdAt!.year,
          stokCreateAt.createdAt!.month,
          stokCreateAt.createdAt!.day,
          stokCreateAt.createdAt!.hour,
          stokCreateAt.createdAt!.minute,
          stokCreateAt.createdAt!.second,
          stokCreateAt.createdAt!.microsecond,
          stokCreateAt.createdAt!.microsecond,
        );
        var bbbb = DateTime(
          p.lastUpdated!.year,
          p.lastUpdated!.month,
          p.lastUpdated!.day,
          p.lastUpdated!.hour,
          p.lastUpdated!.minute,
          p.lastUpdated!.second,
          p.lastUpdated!.microsecond,
          p.lastUpdated!.microsecond,
        );
        if (aaaa != bbbb) {
          p.lastUpdated = stokCreateAt.createdAt;
          if (p.stock.value != stokCreateAt.amount) {
            print(
                'goooooooooooooo beda nih ${p.stock.value} ${stokCreateAt.amount}');
          }
          updatedP.add(p);
          // await productService.update(p);
        }
        count++;
      }
      print('goooooooooooooo updatedP lenght ${updatedP.length}');
      print('goooooooooooooo updatedP count ${count}');
    }
    // await productService.updateList(updatedP);
    loadingTest(false);
  }

  final startFilteredDate = ''.obs;
  final endFilteredDate = ''.obs;
  final displayFilteredDate = ''.obs;
  final dateIsSelected = false.obs;
  final selectedFilteredDate = DateTime.now().obs;
  final selectedRangeDate = PickerDateRange(DateTime.now(), DateTime.now()).obs;

  handleFilteredDate(BuildContext context) {
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    // displayFilteredDate.value = '';
    Get.defaultDialog(
      title: 'Pilih Tanggal',
      backgroundColor: Colors.white,
      content: Column(
        children: [
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$startFilteredDate',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Text('sampai',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  '$endFilteredDate',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
          SizedBox(
            width: 400,
            height: 350,
            child: SfDateRangePicker(
              headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Colors.white,
                  textStyle: context.textTheme.bodyLarge),
              showNavigationArrow: true,
              backgroundColor: Colors.white,
              monthViewSettings: const DateRangePickerMonthViewSettings(
                firstDayOfWeek: 1,
              ),
              initialSelectedDate: selectedFilteredDate.value,
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: DateTime(2000),
              maxDate: DateTime.now(),
              showActionButtons: true,
              cancelText: 'Batal',
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                startFilteredDate.value =
                    DateFormat('dd MMM y', 'id').format(args.value.startDate!);
                if (args.value.endDate != null) {
                  endFilteredDate.value =
                      DateFormat('dd MMM y', 'id').format(args.value.endDate!);
                }
              },
              onCancel: () => Get.back(),
              onSubmit: (value) async {
                if (value is PickerDateRange) {
                  dateIsSelected.value = false;
                  final newSelectedPickerRange = PickerDateRange(
                      value.startDate,
                      value.endDate != null
                          ? value.endDate!.add(const Duration(days: 1))
                          : value.startDate!.add(const Duration(days: 1)));

                  selectedFilteredDate.value =
                      newSelectedPickerRange.startDate!;
                  displayFilteredDate.value = value.endDate != null
                      ? '$startFilteredDate s/d $endFilteredDate'
                      : '$startFilteredDate';
                  logStock.value =
                      await productService.getLogByDate(newSelectedPickerRange);
                  selectedRangeDate.value = newSelectedPickerRange;
                  dateIsSelected.value = true;
                  Get.back();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<InvoiceModel>> getInvByDate() async {
    return await invoiceService.getInvByDate(
        selectedRangeDate.value.startDate!, selectedRangeDate.value.endDate!);
  }

  void clearHandle() async {
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    displayFilteredDate.value = '';
    dateIsSelected.value = false;
    // filterInvoices('');
  }
}
