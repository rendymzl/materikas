import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/customer_model.dart';
import '../../global_widget/popup_page_widget.dart';
import '../controllers/customer.controller.dart';
import 'detail_customer_controller.dart';

void detailCustomer({CustomerModel? foundCustomer}) {
  DetailCustomerController controller = Get.put(DetailCustomerController());
  CustomerController customerC = Get.find();

  controller.bindingEditData(foundCustomer);

  controller.clickedField['name'] = false;
  controller.clickedField['phone'] = false;
  controller.clickedField['address'] = false;

  final outlineRed =
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

  showPopupPageWidget(
      title: foundCustomer != null ? 'Edit Pelanggan' : 'Tambah Pelanggan',
      iconButton: (foundCustomer != null)
          ? IconButton(
              onPressed: () => customerC.destroyCustomer.value
                  ? controller.destroyHandle(foundCustomer)
                  : null,
              icon: const Icon(
                Symbols.delete,
                color: Colors.red,
              ))
          : null,
      height: MediaQuery.of(Get.context!).size.height * (3 / 4),
      width: MediaQuery.of(Get.context!).size.width * (3 / 10),
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
                  controller: controller.idController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'ID Pelanggan',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary),
                    focusedErrorBorder: outlineRed,
                    errorBorder: outlineRed,
                  ),
                  onChanged: (value) => controller.clickedField['id'] = true,
                  validator: (value) => controller.idValidator(value!),
                  onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Nama Pelanggan',
                    labelStyle: const TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.primary),
                    focusedErrorBorder: outlineRed,
                    errorBorder: outlineRed,
                  ),
                  onChanged: (value) => controller.clickedField['name'] = true,
                  validator: (value) => controller.nameValidator(value!),
                  onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'No.Telp',
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
                  onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.addressController,
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
                  onFieldSubmitted: (_) => controller.handleSave(foundCustomer),
                ),
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
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () async => await controller.handleSave(foundCustomer),
            child: const Text('Simpan'),
          ),
        ),
      ]);
}
