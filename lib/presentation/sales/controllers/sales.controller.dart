import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/sales_service.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/log_stock_model.dart';
import '../../../infrastructure/models/sales_model.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../product/controllers/product.controller.dart';
// import '../../product/controllers/product.controller.dart';

class SalesController extends GetxController {
  late SalesService salesCustomerSecvice = Get.find();
  late InvoiceSalesService invoiceSalesService = Get.find();

  late InvoiceSalesModel displayInvoice;

  late final sales = salesCustomerSecvice.sales;
  late final foundSales = salesCustomerSecvice.foundSales;
  final ProductController productC = Get.put(ProductController());

  Rx<SalesModel?> selectedSales = Rx<SalesModel?>(null);

  late final salesInvoices = invoiceSalesService.salesInvoices;
  final invoiceById = <InvoiceSalesModel>[].obs;

  final salesTextC = TextEditingController();
  final invoiceSearchC = TextEditingController();
  final GlobalKey textFieldKey = GlobalKey();
  final showSuffixClear = false.obs;

  @override
  void onInit() async {
    // Get.put(ProductController());
    super.onInit();
    filterSales('');
    await loadInvoice(clean: true);

    everAll([salesInvoices, searchQuery, isPaid, selectedSales], (_) async {
      await loadInvoice(clean: true);
    });

    ever(salesInvoices, (_) => selectedSalesHandle(selectedSales.value));
  }

  final displayedItems = <InvoiceSalesModel>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  int offset = 0;

  final int limit = 15;

  final searchQuery = ''.obs;
  final Rx<bool?> isPaid = Rx(null);

  Future<List<InvoiceSalesModel>> fetch({bool isClean = false}) async {
    if (isClean) {
      hasMore.value = true;
      offset = 0;
    }

    if (hasMore.value) {
      final results = await invoiceSalesService.fetch(
        isPaid: isPaid.value,
        salesId: selectedSales.value?.name,
        limit: limit,
        offset: offset,
        search: searchQuery.value,
      );
      if (results.isEmpty || offset > 200) {
        hasMore.value = false;
        return <InvoiceSalesModel>[];
      } else {
        offset += limit;
        return results;
      }
    } else {
      return <InvoiceSalesModel>[];
    }
  }

  Future<void> loadInvoice({bool clean = false}) async {
    clean
        ? displayedItems.assignAll(await fetch(isClean: clean))
        : displayedItems.addAll(await fetch());
  }

  bool isFiltered() {
    return (searchQuery.isNotEmpty || selectedSales.value != null);
  }

  void filterSales(String salesName) {
    salesCustomerSecvice.search(salesName);
  }

  Timer? debounceTimer;
  void filterSalesInvoice(String salesName) {
    if (selectedSales.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (salesName.isEmpty) {
          selectedSalesHandle(selectedSales.value);
          List<InvoiceSalesModel> salesInvList = [];
          salesInvList.addAll(invoiceById);
          salesInvList
              .sort((a, b) => a.createdAt.value!.compareTo(b.createdAt.value!));
          invoiceById.assignAll(salesInvList);
        } else {
          List<InvoiceSalesModel> salesInvList = [];
          salesInvList = invoiceById.where((sales) {
            return sales.invoiceName.value!
                .toLowerCase()
                .contains(salesName.toLowerCase());
          }).toList();
          invoiceById.assignAll(salesInvList);
        }
      });
    } else {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        // if (formKey.currentState!.validate()) {
        searchQuery.value = salesName;
        // }
      });
    }
  }

  void selectedSalesHandle(SalesModel? sales) async {
    invoiceSearchC.text = '';
    selectedSales.value = sales;
    salesTextC.text = selectedSales.value?.name ?? '';
    if (sales != null) {
      showSuffixClear.value = true;
      // invoiceById.value = await invoiceSalesService
      //     .fetchBySalesId(sales.id ?? '');
      invoiceById.value =
          selectedSales.value!.getInvoiceListBySalesId(salesInvoices);
      invoiceById
          .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    }
  }

  final selectedFilterCheckBox = ''.obs;
  void checkBoxHandle(String value) async {
    selectedFilterCheckBox.value =
        selectedFilterCheckBox.value == value ? '' : value;

    if (selectedFilterCheckBox.value.isEmpty) {
      isPaid.value = null;
    } else {
      isPaid.value = value == 'paid';
    }
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

  purchaseOrderDoneHandle(InvoiceSalesModel invoice) async {
    await invoiceSalesService.updatePurchaseOrder(
        invoice.id!, !invoice.purchaseOrder.value);

    var logs = <LogStock>[];

    for (var cart in invoice.purchaseList.value.items) {
      var log = LogStock(
        productId: cart.product.productId,
        productUuid: cart.product.id!,
        productName: cart.product.productName,
        storeId: invoice.storeId,
        label: 'Beli (PO)',
        amount: cart.quantity.value,
        createdAt: DateTime.now(),
      );
      print('aaaw ${log.toJson()}');
      logs.add(log);
    }

    await productC.productService.insertListLog(logs);
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
