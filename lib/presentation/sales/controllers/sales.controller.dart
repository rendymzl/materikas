import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/sales_service.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/sales_model.dart';
import '../../global_widget/app_dialog_widget.dart';

class SalesController extends GetxController {
  late SalesService salesCustomerSecvice = Get.find();
  late InvoiceSalesService invoiceSalesService = Get.find();

  late final sales = salesCustomerSecvice.sales;
  late final foundSales = salesCustomerSecvice.foundSales;

  Rx<SalesModel?> selectedSales = Rx<SalesModel?>(null);

  late final salesInvoices = invoiceSalesService.invoices;
  final invoiceById = <InvoiceSalesModel>[].obs;
  late InvoiceSalesModel initInvoice;

  final salesTextC = TextEditingController();
  final GlobalKey textFieldKey = GlobalKey();
  final showSuffixClear = false.obs;

  void filterSales(String salesName) {
    salesCustomerSecvice.search(salesName);
  }

  void selectedSalesHandle(SalesModel sales) {
    selectedSales.value = sales;
    showSuffixClear.value = true;
    salesTextC.text = selectedSales.value!.name!;
    invoiceById.value =
        selectedSales.value!.getInvoiceListBySalesId(salesInvoices);
  }

  //! delete
  destroyHandle(SalesModel sales) async {
    AppDialog.show(
      title: 'Hapus Sales',
      content: 'Hapus Sales ini?',
      confirmText: "Ya",
      cancelText: "Tidak",
      confirmColor: Colors.grey,
      cancelColor: Get.theme.primaryColor,
      onConfirm: () async {
        salesCustomerSecvice.delete(sales.id!);
        Get.back();
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  destroyInvoiceHandle(InvoiceSalesModel invoice) async {
    await invoiceSalesService.delete(invoice.id!);
  }

  void clear() {
    showSuffixClear.value = false;
    selectedSales.value = null;
    salesTextC.text = '';
  }
}
