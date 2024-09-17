import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/models/customer_model.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = Get.find<CustomerService>();
  late final AuthService _authService = Get.find();

  late final customers = _customerService.customers;
  late final foundCustomers = _customerService.foundCustomers;

  void filterCustomers(String customerName) {
    _customerService.search(customerName);
  }

  final addCustomer = true.obs;
  final editCustomer = true.obs;
  final destroyCustomer = true.obs;

  @override
  void onInit() async {
    addCustomer.value = await _authService.checkAccess('addCustomer');
    editCustomer.value = await _authService.checkAccess('editCustomer');
    destroyCustomer.value = await _authService.checkAccess('destroyCustomer');

    super.onInit();
  }

  destroyHandle(CustomerModel customer) async {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Hapus Customer ini?',
      confirm: TextButton(
        onPressed: () async {
          await _customerService.delete(customer.id!);
          Get.back();
        },
        child: const Text('OK'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
