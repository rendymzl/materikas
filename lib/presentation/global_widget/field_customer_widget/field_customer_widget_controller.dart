import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/models/customer_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../customer/detail_customer/detail_customer_controller.dart';

class CustomerInputFieldController extends GetxController {
  late final CustomerService _customerService = Get.find();
  // late final DetailCustomerController _detailCustC = Get.find();
  final AuthService _authService = Get.find();
  late final customers = _customerService.customers;
  late final lastCustomersId = _customerService.lastCustomersId;

  final displayName = ''.obs;
  final saveCust = false.obs;
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final showSuffixClear = false.obs;
  Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);

  void asignCustomer(CustomerModel customer) {
    customer.customerId =
        customer.customerId == 'null' ? null : customer.customerId;
    customerNameController.text = customer.name;
    customerPhoneController.text = customer.phone ?? '';
    customerAddressController.text = customer.address ?? '';
    customer.storeId = customer.storeId == 'null' ? null : customer.storeId;
    selectedCustomer.value = customer;
    showSuffixClear.value = customer.name != '';
  }

  void updateSelectedCustomer(CustomerModel? customer) {
    customer?.name = customerNameController.text;
    customer?.phone = customerPhoneController.text;
    customer?.address = customerAddressController.text;
    selectedCustomer.value = customer;
  }

  void ckeckBoxSaveCustomer() {
    saveCust.value = !saveCust.value;
  }

  //! handle save
  Future handleSave() async {
    if (saveCust.value) {
      int numberId = int.parse(lastCustomersId.value.substring(3));
      try {
        final customer = CustomerModel(
            customerId: 'CST${numberId + 1}',
            createdAt: DateTime.now(),
            name: customerNameController.text,
            phone: customerPhoneController.text,
            address: customerAddressController.text,
            storeId: _authService.account.value!.storeId);
        await _customerService.insert(customer);
        selectedCustomer.value = customer;
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

  void clear() {
    saveCust.value = false;
    showSuffixClear.value = false;
    displayName.value = '';
    customerNameController.text = '';
    customerPhoneController.text = '';
    customerAddressController.text = '';
    CustomerModel customer = CustomerModel(
        id: '',
        customerId: '',
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
