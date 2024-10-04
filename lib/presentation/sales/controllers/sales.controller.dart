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
  final invoiceSearchC = TextEditingController();
  final GlobalKey textFieldKey = GlobalKey();
  final showSuffixClear = false.obs;

  void filterSales(String salesName) {
    salesCustomerSecvice.search(salesName);
  }

  void filterSalesInvoice(String salesName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (salesName.isEmpty) {
        selectedSalesHandle(selectedSales.value);
        // List<InvoiceSalesModel> salesInvList = [];
        // salesInvList.addAll(invoiceById);
        // salesInvList
        //     .sort((a, b) => a.createdAt.value!.compareTo(b.createdAt.value!));
        // invoiceById.assignAll(salesInvList);
      } else {
        List<InvoiceSalesModel> salesInvList = [];
        salesInvList = invoiceById.where((sales) {
          return sales.invoiceId!
              .toLowerCase()
              .contains(salesName.toLowerCase());
        }).toList();
        invoiceById.assignAll(salesInvList);
      }
    });
  }

  void selectedSalesHandle(SalesModel? sales) {
    invoiceSearchC.text = '';
    selectedSales.value = sales;
    salesTextC.text = selectedSales.value?.name ?? '';
    if (sales != null) {
      showSuffixClear.value = true;
      invoiceById.value =
          selectedSales.value!.getInvoiceListBySalesId(salesInvoices);
      invoiceById
          .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    }
  }

  final selectedFilterCheckBox = ''.obs;
  void checkBoxHandle(String value) {
    selectedFilterCheckBox.value =
        selectedFilterCheckBox.value == value ? '' : value;
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
