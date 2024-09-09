import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/models/customer_model.dart';
import '../../global_widget/menu_widget/menu_controller.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = Get.find<CustomerService>();
  final MenuWidgetController _menuC = Get.find<MenuWidgetController>();

  late final customers = _customerService.customers;
  late final foundCustomers = _customerService.foundCustomers;
  late final isAdmin = _menuC.isAdmin.value;

  void filterCustomers(String customerName) {
    _customerService.search(customerName);
  }

  @override
  void onInit() {
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
