import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/models/customer_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';

class CustomerInputFieldController extends GetxController {
  late CustomerService _customerService = Get.find();
  late final customers = _customerService.customers;

  final displayName = ''.obs;
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final showSuffixClear = false.obs;
  Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);

  void asignCustomer(CustomerModel customer) {
    customerNameController.text = customer.name;
    customerPhoneController.text = customer.phone ?? '';
    customerAddressController.text = customer.address ?? '';
    selectedCustomer.value = customer;
  }

  void updateSelectedCustomer(CustomerModel customer) {
    customer.name = customerNameController.text;
    customer.phone = customerPhoneController.text;
    customer.address = customerAddressController.text;
    selectedCustomer.value = customer;
  }

  void clear() {
    showSuffixClear.value = false;
    displayName.value = '';
    customerNameController.text = '';
    customerPhoneController.text = '';
    customerAddressController.text = '';
    CustomerModel customer = CustomerModel(
        name: customerNameController.text,
        phone: customerPhoneController.text,
        address: customerAddressController.text);
    selectedCustomer.value = customer;
  }

  bool validateCustomer() {
    return customerNameController.text == '' ||
        customerPhoneController.text == '' ||
        customerAddressController.text == '';
  }

  Future addCustomer(InvoiceModel invoice) async {
    invoice.customer.value = selectedCustomer.value;
  }
}
