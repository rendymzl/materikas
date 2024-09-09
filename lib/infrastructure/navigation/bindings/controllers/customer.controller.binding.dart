import 'package:get/get.dart';

import '../../../../presentation/customer/controllers/customer.controller.dart';

class CustomerControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerController>(
      () => CustomerController(),
    );
  }
}
