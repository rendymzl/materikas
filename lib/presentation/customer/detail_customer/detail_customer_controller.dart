import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/models/customer_model.dart';
import '../../global_widget/app_dialog_widget.dart';

class DetailCustomerController extends GetxController {
  final CustomerService _customerService = Get.find();
  final AuthService _authService = Get.find();

  late final customers = _customerService.customers;
  late final foundCustomers = _customerService.foundCustomers;
  late final lastCustomersId = _customerService.lastCustomersId;

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

  late String customerId;

  //! binding data
  void bindingEditData(CustomerModel? foundCustomer) {
    int numberId = int.parse(lastCustomersId.value.substring(3));

    CustomerModel customer = foundCustomer ?? CustomerModel(name: '');
    idController.text = customer.customerId ?? 'CST${numberId + 1}';
    nameController.text = customer.name;
    phoneController.text = customer.phone ?? '';
    addressController.text = customer.address ?? '';
  }

  //! create
  Future addCustomer(CustomerModel customer) async {
    print('customer harusnya di save');
    bool isCustomerExists =
        customers.any((item) => item.customerId == customer.customerId);
    if (isCustomerExists) {
      await Get.defaultDialog(
        title: 'Gagal',
        middleText: 'ID Pelanggan sudah ada',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    } else {
      await _customerService.insert(customer);
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Pelanggan berhasil ditambahkan',
        confirm: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      Get.back();
    }
  }

  //! update
  Future updateCustomer(
    CustomerModel newCustomer,
    CustomerModel currentCustomer,
  ) async {
    newCustomer.id = currentCustomer.id;
    await _customerService.update(newCustomer);
    await Get.defaultDialog(
      title: 'Berhasil',
      middleText: 'Pelanggan berhasil diupdate',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
    Get.back();
  }

  //! delete
  destroyHandle(CustomerModel customer) async {
    AppDialog.show(
      title: 'Hapus Pelanggan',
      content: 'Hapus Pelanggan ini?',
      confirmText: "Ya",
      cancelText: "Tidak",
      confirmColor: Colors.grey,
      cancelColor: Get.theme.primaryColor,
      onConfirm: () async {
        _customerService.delete(customer.id!);
        Get.back();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  //! handle save
  Future handleSave(CustomerModel? curentCustomer) async {
    try {
      print(clickedField['id']);
      clickedField['id'] = true;
      clickedField['name'] = true;
      print(nameController.text);
      if (formkey.currentState!.validate()) {
        final customer = CustomerModel(
            customerId: idController.text,
            createdAt: DateTime.now(),
            name: nameController.text,
            phone: phoneController.text,
            address: addressController.text,
            storeId: _authService.account.value!.storeId);
        print(customer.toJson());
        print(nameController.text);
        curentCustomer != null
            ? await updateCustomer(customer, curentCustomer)
            : await addCustomer(customer);
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
