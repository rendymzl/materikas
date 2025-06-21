import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:materikas/infrastructure/dal/database/powersync_attachment.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:powersync/powersync.dart' as powersync;

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/log_stock_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../controllers/product.controller.dart';

class DetailProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final ProductController _productC = Get.put(ProductController());
  final AuthService _authService = Get.find();
  final InternetService internetService = Get.find();

  late final products = _productC.displayedItems;
  late final lastCode = _productC.lastCode;

  final formkey = GlobalKey<FormState>();

  final TextEditingController codeTextC = TextEditingController();
  final TextEditingController barcodeTextC = TextEditingController();
  final TextEditingController productNameTextC = TextEditingController();
  final TextEditingController unitTextC = TextEditingController();
  final TextEditingController salesTextC = TextEditingController();
  final TextEditingController costPriceTextC = TextEditingController();
  final TextEditingController sellPriceTextC1 = TextEditingController();
  final TextEditingController sellPriceTextC2 = TextEditingController();
  final TextEditingController sellPriceTextC3 = TextEditingController();
  final TextEditingController stockTextC = TextEditingController();
  final TextEditingController minStockTextC = TextEditingController();
  final TextEditingController soldTextC = TextEditingController();

  late final Map<String, TextEditingController> textControllers;

  var selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  late XFile image;

  // Fungsi untuk memilih gambar dari galeri
  Future<void> pickImage() async {
    var status = await Permission.camera.request();
    if (internetService.isConnected.value || windows) {
      if (status.isGranted) {
        final XFile? pickedImage =
            await _picker.pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          image = pickedImage;
          selectedImage.value = File(image.path);

          // Gunakan gambar yang dipilih
        }
      } else {
        Get.snackbar("Izin ditolak", "izinkan akses kamera.");
      }
    } else {
      Get.snackbar("Aktifkan Internet", "Izin kamera diperlukan.");
    }
  }

  @override
  void onInit() async {
    super.onInit();
    selectedImage.value = null;
    textControllers = {
      'code': codeTextC,
      'barcode': codeTextC,
      'productName': productNameTextC,
      'unit': unitTextC,
      'sales': salesTextC,
      'cost': costPriceTextC,
      'sell1': sellPriceTextC1,
      'sell2': sellPriceTextC2,
      'sell3': sellPriceTextC3,
      'stock': stockTextC,
      'min_stock': stockTextC,
      'sold': soldTextC,
    };
  }

  void onTextChange(String value, String field) {
    clickedField[field] = true;
  }

  String? fieldValidator(String value, String fieldKey, String errorMessage) {
    value = value.trim();
    if ((value.isEmpty) && clickedField[fieldKey] == true) {
      return errorMessage;
    }
    if (fieldKey == 'cost' &&
        clickedField[fieldKey] == true &&
        (int.parse(sellPriceTextC1.text.isNotEmpty
                ? sellPriceTextC1.text.replaceAll('.', '')
                : '0') !=
            0) &&
        (int.parse(costPriceTextC.text.isNotEmpty
                ? costPriceTextC.text.replaceAll('.', '')
                : '0') >
            int.parse(sellPriceTextC1.text.isNotEmpty
                ? sellPriceTextC1.text.replaceAll('.', '')
                : '0'))) {
      return 'Harga modal harus lebih rendah dari harga jual.';
    }

    return null;
  }

  void onCurrencyChanged(String value, String field) {
    clickedField[field] = true;

    if (value.isNotEmpty) {
      String newValue = currency.format(int.parse(value.replaceAll('.', '')));
      final textController = textControllers[field];

      if (textController != null && newValue != textController.text) {
        textController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
  }

  final RxMap<String, bool> clickedField = {
    'code': false,
    'productName': false,
    'sales': false,
    'cost': false,
    'sell1': false,
    'sell2': false,
    'sell3': false,
    'stock': false,
    'min_stock': false,
    'sold': false,
  }.obs;

  //! binding data
  String generateNumberId(int number) {
    return number.toString().padLeft(4, '0');
  }

  void bindingEditData(ProductModel? foundProduct) {
    int numberId =
        (lastCode.value != '') ? int.parse(lastCode.value.substring(2)) : 0;
    // numberId = generateNumberId(numberId);
    selectedImage.value = null;
    print('bbbbb ${foundProduct?.imageUrl ?? 'ds'}');
    ProductModel product = foundProduct ??
        ProductModel(
          id: '',
          productId: 'BR${generateNumberId(numberId + 1)}',
          storeId: _authService.account.value!.storeId!,
          productName: '',
          unit: '',
          costPrice: 0.0.obs,
          sellPrice1: 0.0.obs,
          sellPrice2: 0.0.obs,
          sellPrice3: 0.0.obs,
          stock: 0.0.obs,
          stockMin: 0.0.obs,
          sold: 0.0.obs,
        );

    codeTextC.text = product.productId;
    barcodeTextC.text = product.barcode ?? '';
    productNameTextC.text = product.productName;
    unitTextC.text = product.unit;
    costPriceTextC.text = product.costPrice.value == 0
        ? ''
        : currency.format(product.costPrice.value);
    sellPriceTextC1.text = product.sellPrice1 == 0.0.obs
        ? ''
        : currency.format(product.sellPrice1.value);
    sellPriceTextC2.text =
        product.sellPrice2?.value == null || product.sellPrice2!.value == 0
            ? ''
            : currency.format(product.sellPrice2!.value);
    sellPriceTextC3.text =
        product.sellPrice3?.value == null || product.sellPrice3!.value == 0
            ? ''
            : currency.format(product.sellPrice3!.value);
    stockTextC.text = product.finalStock.value == 0
        ? ''
        : number.format(product.finalStock.value).replaceAll('.', '');
    minStockTextC.text = product.stockMin.value == 0
        ? ''
        : number.format(product.stockMin.value);
    soldTextC.text = product.sold?.value == null || product.sold!.value == 0
        ? ''
        : currency.format(product.sold!.value);
  }

//! create
  Future addProduct(ProductModel product) async {
    bool isProductExist =
        products.any((item) => item.productId == product.productId);
    if (isProductExist) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'ID barang sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      var log = LogStock(
        productId: product.productId,
        productUuid: product.id!,
        productName: product.productName,
        storeId: product.storeId,
        label: 'Stok Awal',
        amount: product.stock.value,
        createdAt: DateTime.now(),
      );
      print('newLog ${log.toJson()}');
      // Future.delayed(
      //     Duration(seconds: 5), () => _productService.insertLog(log));
      await _productService.insert(product);
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Barang berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        ),
      );
    }
  }

  //! update
  Future updateProduct(
    ProductModel newProduct,
    ProductModel currentProduct,
  ) async {
    DateTime now = DateTime.now();
    newProduct.id = currentProduct.id;
    newProduct.imageUrl ??= currentProduct.imageUrl;
    currentProduct.imageUrl = newProduct.imageUrl;

    newProduct.lastUpdated = now;
    await _productService.update(newProduct);

    var log = LogStock(
      productId: newProduct.productId,
      productUuid: newProduct.id!,
      productName: newProduct.productName,
      storeId: newProduct.storeId,
      label: 'Update',
      amount: newProduct.stock.value,
      createdAt: now,
    );
    await _productService.insertLog(log);
    currentProduct.currentStock!.value = currentProduct.stock.value;
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Product berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  //! delete
  destroyHandle(ProductModel product) async {
    try {
      AppDialog.show(
        title: 'Hapus Barang',
        content: 'Hapus barang ini?',
        confirmText: "Ya",
        cancelText: "Tidak",
        confirmColor: Colors.grey,
        cancelColor: Get.theme.primaryColor,
        onConfirm: () async {
          _productService.delete(product.id!);
          Get.back();
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

  // Fungsi untuk mengunggah gambar ke server
  Future<RxString?> uploadImage(ProductModel? currentProduct) async {
    if (selectedImage.value != null) {
      try {
        String imageId = powersync.uuid.v4();
        String storageDirectory = await attachmentQueue.getStorageDirectory();
        await attachmentQueue.localStorage
            .copyFile(image.path, '$storageDirectory/$imageId.jpg');

        int photoSize = await image.length();

        if (currentProduct != null && currentProduct.imageUrl != null) {
          await attachmentQueue.deleteFile(currentProduct.imageUrl!.value);
        }
        await attachmentQueue.saveFile(imageId, photoSize);

        return imageId.obs;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  //! handle save
  Future handleSave(ProductModel? currentProduct) async {
    // _productC.loadingNewImage.value = true;
    clickedField.assignAll({
      'code': true,
      'productName': true,
      'unit': true,
      'sales': true,
      'cost': true,
      'sell1': true,
      'sell2': true,
      'sell3': true,
      'stock': true,
      'min_stock': true,
      'sold': true,
    });

    if (formkey.currentState!.validate()) {
      // double? stock = double.tryParse(stockTextC.text);
      // stock ??= 0;
      final imgUrl = await uploadImage(currentProduct);

      print('imgUrl save $imgUrl');

      final newProduct = ProductModel(
        id: powersync.uuid.v4(),
        productId: codeTextC.text.toUpperCase(),
        createdAt: DateTime.now(),
        storeId: _authService.account.value!.storeId!,
        barcode: barcodeTextC.text,
        featured: false,
        productName: productNameTextC.text,
        unit: unitTextC.text,
        costPrice: costPriceTextC.text == ''
            ? 0.0.obs
            : (double.parse(costPriceTextC.text.replaceAll('.', ''))).obs,
        sellPrice1: sellPriceTextC1.text == ''
            ? 0.0.obs
            : (double.parse(sellPriceTextC1.text.replaceAll('.', ''))).obs,
        sellPrice2: sellPriceTextC2.text == ''
            ? 0.0.obs
            : (double.parse(sellPriceTextC2.text.replaceAll('.', ''))).obs,
        sellPrice3: sellPriceTextC3.text == ''
            ? 0.0.obs
            : (double.parse(sellPriceTextC3.text.replaceAll('.', ''))).obs,
        stock: (double.tryParse(stockTextC.text.replaceAll(',', '.')) ?? 0).obs,
        stockMin: minStockTextC.text == ''
            ? 0.0.obs
            : (double.parse(minStockTextC.text.replaceAll('.', ''))).obs,
        sold:
            soldTextC.text == '' ? 0.0.obs : (double.parse(soldTextC.text)).obs,
        imageUrl: imgUrl,
        lastUpdated: DateTime.now(),
      );

      currentProduct == null
          ? await addProduct(newProduct)
          : await updateProduct(newProduct, currentProduct);

      selectedImage.value = null;
    }
    // _productC.loadingNewImage.value = false;
  }

  var scannedData = ''.obs; // Observable untuk menyimpan hasil scan

  // Fungsi untuk memproses input dari scanner
  void processBarcode(String barcode) {
    print('Memproses barcode: $barcode');
    // Tambahkan logika pemrosesan barcode, misalnya mencari produk dari barcode
    scannedData.value = barcode; // Update UI dengan hasil scan
  }

  // Reset data setelah diproses
  void resetScannedData() {
    scannedData.value = '';
  }

  Future<void> scanBarcode() async {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Warna garis pemindai
      'Batal', // Teks tombol batal
      true, // Apakah lampu kilat aktif
      ScanMode.BARCODE, // Mode pemindaian
    );

    if (barcode != '-1') {
      barcodeTextC.text = barcode;
      // scannedData.value = barcode;
      // textC.text = barcode;
      processBarcode(barcode);
      // processBarcode(barcode);
      resetScannedData();
    }
  }
}
