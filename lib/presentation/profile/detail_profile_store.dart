import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/store_model.dart';
import '../global_widget/popup_page_widget.dart';
import 'detail_store.controller.dart';

Future<void> detailStore(
    {StoreModel? foundStore, bool setup = false, bool isMobile = false}) async {
  DetailStoreController controller = Get.put(DetailStoreController());

  controller.bindingEditData(foundStore);

  controller.clickedField['name'] = false;
  controller.clickedField['phone'] = false;
  controller.clickedField['address'] = false;

  const outlineRed =
      OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

  await showPopupPageWidget(
      title: (foundStore != null)
          ? (!setup ? 'Edit Toko' : 'Detail Toko')
          : 'Tambah Toko',
      // iconButton: foundStore != null
      //     ? IconButton(
      //         onPressed: () => controller.destroyHandle(foundStore),
      //         icon: const Icon(
      //           Symbols.delete,
      //           color: Colors.red,
      //         ))
      //     : null,
      // height:
      //     MediaQuery.of(Get.context!).size.height * (isMobile ? 0.65 : 3 / 4),
      // width: MediaQuery.of(Get.context!).size.width * (isMobile ? 0.9 : 3 / 10),
      barrierDismissible: !setup,
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: controller.formkey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                TextFormField(
                  controller: controller.storeNameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Nama toko',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary),
                    focusedErrorBorder: outlineRed,
                    errorBorder: outlineRed,
                  ),
                  onChanged: (value) => controller.clickedField['name'] = true,
                  validator: (value) => controller.nameValidator(value!),
                  onFieldSubmitted: (_) => controller.handleSave(foundStore),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.storeAddressController,
                  minLines: 1,
                  maxLines: 7,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Alamat',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary),
                    focusedErrorBorder: outlineRed,
                    errorBorder: outlineRed,
                  ),
                  onChanged: (value) =>
                      controller.clickedField['address'] = true,
                  onFieldSubmitted: (_) => controller.handleSave(foundStore),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.storePhoneController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'No Handphone',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary),
                    focusedErrorBorder: outlineRed,
                    errorBorder: outlineRed,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  onChanged: (value) => controller.clickedField['phone'] = true,
                  onFieldSubmitted: (_) => controller.handleSave(foundStore),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.storeTelpController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'No.Telp (Opsional)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary),
                    focusedErrorBorder: outlineRed,
                    errorBorder: outlineRed,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  onChanged: (value) => controller.clickedField['telp'] = true,
                  onFieldSubmitted: (_) => controller.handleSave(foundStore),
                ),
              ],
            ),
          ),
        ],
      ),
      buttonList: [
        if (!setup)
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
          ),
        if (!setup) const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () async => await controller.handleSave(foundStore),
            child: const Text('Simpan'),
          ),
        ),
      ]);
}
