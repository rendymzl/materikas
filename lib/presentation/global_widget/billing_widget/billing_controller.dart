import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/models/billing_model.dart';

class BillingController extends GetxController {
  late final AuthService authService = Get.find();
  final InvoiceService invoiceService = Get.find();

  // var totalInvoices = 0.obs;
  var paymentStatus = "Belum Dibayar".obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   loadInvoices();
  // }

  // void loadInvoices() {
  //   // Contoh data dummy
  //   invoices.value = [
  //     {
  //       'invoiceNumber': 'INV-001',
  //       'date': '01-10-2024',
  //       'totalTransaction': 500000,
  //       'invoiceFee': 1000,
  //       'status': 'Valid'
  //     },
  //     {
  //       'invoiceNumber': 'INV-002',
  //       'date': '02-10-2024',
  //       'totalTransaction': 700000,
  //       'invoiceFee': 1000,
  //       'status': 'Valid'
  //     },
  //     {
  //       'invoiceNumber': 'INV-003',
  //       'date': '03-10-2024',
  //       'totalTransaction': 200000,
  //       'invoiceFee': 1000,
  //       'status': 'Void'
  //     },
  //   ];
  //   calculateTotalFee();
  // }

  // void calculateTotalFee() {
  //   int total = 0;
  //   int count = 0;
  //   for (var invoice in invoices) {
  //     if (invoice['status'] == 'Valid') {
  //       total += invoice['invoiceFee'];
  //       count++;
  //     }
  //   }
  //   totalFee.value = total;
  //   totalInvoices.value = count;
  // }
}
