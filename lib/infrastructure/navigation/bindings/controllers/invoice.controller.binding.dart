import 'package:get/get.dart';

import '../../../../presentation/invoice/controllers/invoice.controller.dart';

class InvoiceControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceController>(
      () => InvoiceController(),
    );
  }
}
