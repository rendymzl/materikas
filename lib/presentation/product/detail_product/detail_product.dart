import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/product_model.dart';
import '../../global_widget/popup_page_widget.dart';
import 'detail_product_controller.dart';

void detailProduct({ProductModel? foundProduct}) {
  DetailProductController controller = Get.put(DetailProductController());

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
      title: foundProduct != null ? 'Edit Barang' : 'Tambah Barang',
      iconButton: foundProduct != null
          ? IconButton(
              onPressed: () => controller.destroyHandle(foundProduct),
              icon: Icon(
                Symbols.delete,
                color: Colors.red,
              ))
          : null,
      height: MediaQuery.of(Get.context!).size.height * (3 / 4),
      width: MediaQuery.of(Get.context!).size.width * (5 / 16),
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: controller.formkey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                buildTextFormField(
                  controller: controller.codeTextC,
                  labelText: 'Kode Barang',
                  onChanged: (value) => controller.onTextChange(value, 'code'),
                  validator: (value) => controller.fieldValidator(
                      value!, 'code', 'Kode tidak boleh kosong'),
                  onFieldSubmitted: (_) => controller.handleSave(foundProduct),
                ),
                buildTextFormField(
                  controller: controller.productNameTextC,
                  labelText: 'Nama Barang',
                  onChanged: (value) =>
                      controller.onTextChange(value, 'productName'),
                  validator: (value) => controller.fieldValidator(
                      value!, 'productName', 'Nama barang tidak boleh kosong'),
                  onFieldSubmitted: (_) => controller.handleSave(foundProduct),
                ),
                buildTextFormField(
                  controller: controller.costPriceTextC,
                  labelText: 'Harga Sales',
                  prefixText: 'Rp. ',
                  onChanged: (value) =>
                      controller.onCurrencyChanged(value, 'cost'),
                  validator: (value) => controller.fieldValidator(
                      value!, 'cost', 'Harga sales tidak boleh kosong'),
                  onFieldSubmitted: (_) => controller.handleSave(foundProduct),
                  isCurrency: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: buildTextFormField(
                        controller: controller.sellPriceTextC1,
                        labelText: 'Harga Jual 1',
                        prefixText: 'Rp. ',
                        onChanged: (value) =>
                            controller.onCurrencyChanged(value, 'sell1'),
                        validator: (value) => controller.fieldValidator(
                            value!, 'sell1', 'Harga jual 1 tidak boleh kosong'),
                        onFieldSubmitted: (_) =>
                            controller.handleSave(foundProduct),
                        isCurrency: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildTextFormField(
                        controller: controller.sellPriceTextC2,
                        labelText: 'Harga Jual 2',
                        prefixText: 'Rp. ',
                        onChanged: (value) =>
                            controller.onCurrencyChanged(value, 'sell2'),
                        onFieldSubmitted: (_) =>
                            controller.handleSave(foundProduct),
                        isCurrency: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildTextFormField(
                        controller: controller.sellPriceTextC3,
                        labelText: 'Harga Jual 3',
                        prefixText: 'Rp. ',
                        onChanged: (value) =>
                            controller.onCurrencyChanged(value, 'sell3'),
                        onFieldSubmitted: (_) =>
                            controller.handleSave(foundProduct),
                        isCurrency: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: buildTextFormField(
                        controller: controller.unitTextC,
                        labelText: 'Satuan',
                        onChanged: (value) =>
                            controller.onTextChange(value, 'unit'),
                        validator: (value) => controller.fieldValidator(
                            value!, 'unit', 'Satuan tidak boleh kosong'),
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
                        onChanged: (value) =>
                            controller.onTextChange(value, 'min_stock'),
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
  required Function(String) onFieldSubmitted,
  String prefixText = '',
  bool isCurrency = false,
  bool isNumeric = false,
}) {
  return Container(
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
        fillColor: Colors.grey[200],
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
