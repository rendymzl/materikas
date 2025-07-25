import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/popup_page_widget.dart';
import '../controllers/product.controller.dart';
import 'detail_product_controller.dart';

void detailProduct({ProductModel? foundProduct}) {
  DetailProductController controller = Get.put(DetailProductController());
  ProductController productC = Get.put(ProductController());

  final FocusNode focusNode = FocusNode();

  void handleKeyPress(KeyEvent event) {
    // Cek apakah key event merupakan input karakter
    if (event is KeyDownEvent) {
      final String key = event.logicalKey.keyLabel;

      // Jika key adalah Enter, kita anggap selesai menerima input barcode
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        controller.processBarcode(controller.scannedData.value);
        controller.resetScannedData();
      } else {
        // Jika bukan Enter, tambahkan ke scannedData
        controller.scannedData.value += key;
      }
    }
  }

  controller.bindingEditData(foundProduct);

  controller.clickedField['code'] = false;
  controller.clickedField['productName'] = false;
  controller.clickedField['unit'] = false;
  controller.clickedField['sell1'] = false;
  controller.clickedField['sell2'] = false;
  controller.clickedField['sell3'] = false;
  controller.clickedField['stock'] = false;
  controller.clickedField['min_stock'] = false;
  controller.clickedField['cost'] = false;

  showPopupPageWidget(
      focusNode: focusNode,
      title: foundProduct != null ? 'Edit Barang' : 'Tambah Barang',
      iconButton: foundProduct != null
          ? IconButton(
              onPressed: () => productC.destroyProduct.value
                  ? controller.destroyHandle(foundProduct)
                  : null,
              icon: Icon(
                Symbols.delete,
                color: Colors.red,
              ))
          : null,
      height:
          MediaQuery.of(Get.context!).size.height * (vertical ? 0.65 : 3 / 4),
      width: vertical ? MediaQuery.of(Get.context!).size.width : 500,
      content: Expanded(
        child: KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: handleKeyPress,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: controller.formkey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: buildTextFormField(
                            controller: controller.codeTextC,
                            labelText: 'Kode Barang',
                            onChanged: (value) =>
                                controller.onTextChange(value, 'code'),
                            validator: (value) => controller.fieldValidator(
                                value!, 'code', 'Kode tidak boleh kosong'),
                            onFieldSubmitted: (_) =>
                                controller.handleSave(foundProduct),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: buildTextFormField(
                            controller: controller.barcodeTextC,
                            labelText: 'Barcode (Opsional)',
                            onChanged: (value) =>
                                controller.onTextChange(value, 'barcode'),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Symbols.barcode_scanner),
                          onPressed: controller.scanBarcode,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            controller: controller.productNameTextC,
                            labelText: 'Nama Barang',
                            onChanged: (value) =>
                                controller.onTextChange(value, 'productName'),
                            validator: (value) => controller.fieldValidator(
                                value!,
                                'productName',
                                'Nama barang tidak boleh kosong'),
                            onFieldSubmitted: (_) =>
                                controller.handleSave(foundProduct),
                          ),
                        ),
                        SizedBox(width: 12),
                        Obx(
                          () {
                            return controller.selectedImage.value != null
                                ? Stack(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.file(
                                            controller.selectedImage.value!),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          tooltip: 'Hapus Gambar',
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.red.withOpacity(0.5),
                                            size: 16,
                                          ),
                                          onPressed: () => controller
                                              .selectedImage.value = null,
                                        ),
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: Icon(Symbols.image_search),
                                    onPressed: controller.pickImage,
                                  );
                          },
                        ),
                      ],
                    ),
                    buildTextFormField(
                      controller: controller.costPriceTextC,
                      labelText: 'Harga Modal',
                      prefixText: 'Rp. ',
                      onChanged: (value) =>
                          controller.onCurrencyChanged(value, 'cost'),
                      validator: (value) => controller.fieldValidator(
                          value!, 'cost', 'Harga modal tidak boleh kosong'),
                      onFieldSubmitted: (_) =>
                          controller.handleSave(foundProduct),
                      isCurrency: true,
                    ),
                    vertical
                        ? Column(
                            children: [
                              buildTextFormField(
                                controller: controller.sellPriceTextC1,
                                labelText: 'Harga Jual 1',
                                prefixText: 'Rp. ',
                                onChanged: (value) => controller
                                    .onCurrencyChanged(value, 'sell1'),
                                validator: (value) => controller.fieldValidator(
                                    value!,
                                    'sell1',
                                    'Harga jual 1 tidak boleh kosong'),
                                onFieldSubmitted: (_) =>
                                    controller.handleSave(foundProduct),
                                isCurrency: true,
                              ),
                              buildTextFormField(
                                controller: controller.sellPriceTextC2,
                                labelText: 'Harga Jual 2 (Opsional)',
                                prefixText: 'Rp. ',
                                onChanged: (value) => controller
                                    .onCurrencyChanged(value, 'sell2'),
                                onFieldSubmitted: (_) =>
                                    controller.handleSave(foundProduct),
                                isCurrency: true,
                              ),
                              buildTextFormField(
                                controller: controller.sellPriceTextC3,
                                labelText: 'Harga Jual 3 (Opsional)',
                                prefixText: 'Rp. ',
                                onChanged: (value) => controller
                                    .onCurrencyChanged(value, 'sell3'),
                                onFieldSubmitted: (_) =>
                                    controller.handleSave(foundProduct),
                                isCurrency: true,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: buildTextFormField(
                                  controller: controller.sellPriceTextC1,
                                  labelText: 'Harga Jual 1',
                                  prefixText: 'Rp. ',
                                  onChanged: (value) => controller
                                      .onCurrencyChanged(value, 'sell1'),
                                  validator: (value) =>
                                      controller.fieldValidator(value!, 'sell1',
                                          'Harga jual 1 tidak boleh kosong'),
                                  onFieldSubmitted: (_) =>
                                      controller.handleSave(foundProduct),
                                  isCurrency: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextFormField(
                                  controller: controller.sellPriceTextC2,
                                  labelText: 'Harga Jual 2 (Opsional)',
                                  prefixText: 'Rp. ',
                                  onChanged: (value) => controller
                                      .onCurrencyChanged(value, 'sell2'),
                                  onFieldSubmitted: (_) =>
                                      controller.handleSave(foundProduct),
                                  isCurrency: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextFormField(
                                  controller: controller.sellPriceTextC3,
                                  labelText: 'Harga Jual 3 (Opsional)',
                                  prefixText: 'Rp. ',
                                  onChanged: (value) => controller
                                      .onCurrencyChanged(value, 'sell3'),
                                  onFieldSubmitted: (_) =>
                                      controller.handleSave(foundProduct),
                                  isCurrency: true,
                                ),
                              ),
                            ],
                          ),
                    vertical
                        ? Column(
                            children: [
                              buildTextFormField(
                                controller: controller.unitTextC,
                                labelText: 'Satuan (Contoh: pcs)',
                                onChanged: (value) =>
                                    controller.onTextChange(value, 'unit'),
                                validator: (value) => controller.fieldValidator(
                                    value!,
                                    'unit',
                                    'Satuan tidak boleh kosong'),
                                onFieldSubmitted: (_) =>
                                    controller.handleSave(foundProduct),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildTextFormField(
                                      controller: controller.stockTextC,
                                      labelText: 'Stok',
                                      onChanged: (value) => controller
                                          .onTextChange(value, 'stock'),
                                      onFieldSubmitted: (_) =>
                                          controller.handleSave(foundProduct),
                                      isNumeric: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: buildTextFormField(
                                      controller: controller.minStockTextC,
                                      labelText: 'Minimal Stok',
                                      onChanged: (value) => controller
                                          .onTextChange(value, 'min_stock'),
                                      onFieldSubmitted: (_) =>
                                          controller.handleSave(foundProduct),
                                      isNumeric: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: buildTextFormField(
                                  controller: controller.unitTextC,
                                  labelText: 'Satuan (Contoh: pcs)',
                                  onChanged: (value) =>
                                      controller.onTextChange(value, 'unit'),
                                  validator: (value) =>
                                      controller.fieldValidator(value!, 'unit',
                                          'Satuan tidak boleh kosong'),
                                  onFieldSubmitted: (_) =>
                                      controller.handleSave(foundProduct),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextFormField(
                                  controller: controller.stockTextC,
                                  labelText: 'Stok',
                                  onChanged: (value) =>
                                      controller.onTextChange(value, 'stock'),
                                  onFieldSubmitted: (_) =>
                                      controller.handleSave(foundProduct),
                                  isNumeric: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextFormField(
                                  controller: controller.minStockTextC,
                                  labelText: 'Minimal Stok',
                                  onChanged: (value) => controller.onTextChange(
                                      value, 'min_stock'),
                                  onFieldSubmitted: (_) =>
                                      controller.handleSave(foundProduct),
                                  isNumeric: true,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      buttonList: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () async => await controller.handleSave(foundProduct),
            child: const Text('Simpan'),
          ),
        ),
      ]);
}

Widget buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required Function(String) onChanged,
  String? Function(String?)? validator,
  Function(String)? onFieldSubmitted,
  String prefixText = '',
  bool isCurrency = false,
  bool isNumeric = false,
}) {
  return Container(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        border: InputBorder.none,
        fillColor: Colors.blueGrey[50],
        filled: true,
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle:
            TextStyle(color: Theme.of(Get.context!).colorScheme.primary),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red)),
        prefixText: prefixText,
        prefixStyle: prefixText.isNotEmpty ? const TextStyle() : null,
      ),
      keyboardType: isNumeric || isCurrency
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumeric || isCurrency
          ? isCurrency
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
              : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*'))]
          : [],
      onChanged: onChanged,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    ),
  );
}
