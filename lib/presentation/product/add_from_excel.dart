import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../global_widget/popup_page_widget.dart';
import 'controllers/product.controller.dart';

void addFromExcel() {
  ProductController productC = Get.put(ProductController());

  showPopupPageWidget(
    title: 'Tambah Barang dari Excel',
    height: MediaQuery.of(Get.context!).size.height * (0.5),
    width: MediaQuery.of(Get.context!).size.width * (8 / 16),
    content: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () => productC.isLoading.value
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    productC.processMessage.value,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    productC.file.value == null
                        ? 'Belum ada file yang dipilih'
                        : 'File: ${productC.file.value!.path.split('/').last}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: productC.pickFile,
                          child: Text('Pilih File Excel'),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => productC.downloadExcelTemplate(),
                          child: Text('Download Template Excel'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: productC.file.value == null
                        ? null
                        : productC.readAndUploadExcel,
                    child: Text('Tambah Barang'),
                  ),
                ],
              ),
      ),
    ),
  );
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
