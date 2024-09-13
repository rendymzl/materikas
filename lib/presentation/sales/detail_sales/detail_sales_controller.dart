import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';

import '../../../infrastructure/dal/services/sales_service.dart';
import '../../../infrastructure/models/sales_model.dart';
import '../../global_widget/app_dialog_widget.dart';

class DetailSalesController extends GetxController {
  final SalesService _salesService = Get.find();
  final AuthService _authService = Get.find();

  late final sales = _salesService.sales;
  late final foundSales = _salesService.foundSales;
  late final lastSalesId = _salesService.lastSalesId;

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  final clickedField = {
    'id': false,
    'name': false,
    'phone': false,
    'address': false,
  }.obs;

  String? nameValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['name'] == true) {
      return 'Nama tidak boleh kosong';
    } else if (value.length < 3 && clickedField['name'] == true) {
      return 'Nama harus di isi minimal 3 karakter';
    }
    return null;
  }

  String? idValidator(String value) {
    value = value.trim();
    if (value.isEmpty && clickedField['id'] == true) {
      return 'ID tidak boleh kosong';
    }
    return null;
  }

  late String salesId;

  //! binding data
  void bindingEditData(SalesModel? foundSales) {
    int numberId = int.parse(lastSalesId.value.substring(2));

    SalesModel sales = foundSales ?? SalesModel(name: '');
    idController.text = sales.salesId ?? 'SL${numberId + 1}';
    nameController.text = sales.name!;
    phoneController.text = sales.phone ?? '';
    addressController.text = sales.address ?? '';
  }

  //! create
  Future addSales(SalesModel foundSales) async {
    bool isSalesExists =
        sales.any((item) => item.salesId == foundSales.salesId);
    if (isSalesExists) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'ID Sales sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      await _salesService.insert(foundSales);
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Sales berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      Get.back();
    }
  }

  //! update
  Future updateSales(
    SalesModel newSales,
    SalesModel currentSales,
  ) async {
    newSales.id = currentSales.id;
    await _salesService.update(newSales);
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Sales berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  //! delete
  destroyHandle(SalesModel foundSales) async {
    AppDialog.show(
      title: 'Hapus Sales',
      content: 'Hapus Sales ini?',
      confirmText: "Ya",
      cancelText: "Tidak",
      confirmColor: Colors.grey,
      cancelColor: Get.theme.primaryColor,
      onConfirm: () async {
        _salesService.delete(foundSales.id!);
        Get.back();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  //! handle save
  Future handleSave(SalesModel? curentSales) async {
    try {
      print(clickedField['id']);
      clickedField['id'] = true;
      clickedField['name'] = true;
      print(nameController.text);
      if (formkey.currentState!.validate()) {
        final sales = SalesModel(
            salesId: idController.text,
            createdAt: DateTime.now(),
            name: nameController.text,
            phone: phoneController.text,
            address: addressController.text,
            storeId: _authService.account.value!.storeId);
        print(sales.toJson());
        print(nameController.text);
        curentSales != null
            ? await updateSales(sales, curentSales)
            : await addSales(sales);
      }
    } catch (e) {
      Get.defaultDialog(
        title: 'cekError',
        middleText: 'err: $e',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }
}
