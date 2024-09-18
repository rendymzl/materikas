import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';

class DetailProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final AuthService _authService = Get.find();

  late final products = _productService.products;
  late final lastCode = _productService.lastProductCode;

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

  @override
  void onInit() async {
    super.onInit();
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
    if ((value.isEmpty || value == '0') && clickedField[fieldKey] == true) {
      return errorMessage;
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
    stockTextC.text =
        product.stock.value == 0 ? '' : number.format(product.stock.value);
    minStockTextC.text = product.stockMin.value == 0
        ? ''
        : number.format(product.stockMin.value);
    soldTextC.text = product.sold?.value == null || product.sold!.value == 0
        ? ''
        : currency.format(product.sold!.value);
  }

//! create
  Future addProduct(ProductModel product, bool isPopUp) async {
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
      if (!isPopUp) Get.back();
    }
  }

  //! update
  Future updateProduct(
    ProductModel newProduct,
    ProductModel currentProduct,
  ) async {
    newProduct.id = currentProduct.id;
    await _productService.update(newProduct);
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

  //! handle save
  Future handleSave(ProductModel? currentProduct,
      {bool isPopUp = false}) async {
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
      final newProduct = ProductModel(
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
      );

      currentProduct == null
          ? addProduct(newProduct, isPopUp)
          : updateProduct(newProduct, currentProduct);
    }
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
}
