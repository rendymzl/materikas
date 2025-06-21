import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../../infrastructure/dal/services/product_service.dart';
import '../../../../infrastructure/models/invoice_sales_model.dart';
import '../../../../infrastructure/models/log_stock_model.dart';
import '../../../../infrastructure/models/product_model.dart';
import '../../../../infrastructure/utils/display_format.dart';
import '../../buy_product_widget/buy_product_controller.dart';

class PaymentSalesController extends GetxController {
  final buyProductController = Get.find<BuyProductController>();
  final productService = Get.find<ProductService>();
  final invoiceSalesService = Get.find<InvoiceSalesService>();

  final paymentMethod = ['cash', 'transfer'].obs;
  final selectedPaymentMethod = ''.obs;
  final moneyChange = 0.0.obs;
  final bill = 0.0.obs;
  final isEdit = false.obs;
  // final isNewInvoice = false.obs;
  RxDouble pay = 0.0.obs;
  final bundleDiscount = 0.0.obs;

  late InvoiceSalesModel displayInvoice;
  late InvoiceSalesModel editedInvoice;
  final isLoading = false.obs;

  final paymentTextC = TextEditingController();
  final paymentTextFocusNode = FocusNode();
  final GlobalKey lastWidgetKey = GlobalKey();

  // @override
  // void onInit() {
  //   invoice = buyProductController.editInvoice;
  //   super.onInit();
  // }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    Future.delayed(const Duration(milliseconds: 100), scrollToLastWidget);
    Future.delayed(const Duration(milliseconds: 300),
        () => paymentTextFocusNode.requestFocus());
  }

  void scrollToLastWidget() {
    final context = lastWidgetKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void onPayChanged(String value) {
    if (value.isNotEmpty) {
      final newValue = currency.format(double.parse(value.replaceAll('.', '')));
      if (newValue != paymentTextC.text) {
        paymentTextC.value = TextEditingValue(
            text: newValue,
            selection: TextSelection.collapsed(offset: newValue.length));
      }
    }
    updateBill();
  }

  void updateBill() {
    pay.value = paymentTextC.text.isEmpty
        ? 0
        : double.parse(paymentTextC.text.replaceAll('.', ''));
    bill.value = editedInvoice.remainingDebt;
    moneyChange.value = bill.value - pay.value;
  }

  Future<void> addPayment() async {
    if (paymentTextC.text.isNotEmpty) {
      editedInvoice.addPayment(
          double.parse(paymentTextC.text.replaceAll('.', '')),
          method: selectedPaymentMethod.value,
          date: DateTime.now());
    }
  }

  void assign(
    InvoiceSalesModel editableInvoice, {
    bool isEditMode = false,
    // bool isNewInvoiceMode = false,
  }) {
    selectedPaymentMethod.value = '';

    paymentTextC.clear();
    editedInvoice = editableInvoice;
    pay.value = 0;
    bill.value = editedInvoice.remainingDebt;
    moneyChange.value = bill.value - pay.value;
    isEdit.value = isEditMode;
    // isNewInvoice.value = isNewInvoiceMode;
  }

  bool? validateTotal = true;
  Future<void> saveInvoice() async {
    if (moneyChange.value > 0) {
      validateTotal = await Get.defaultDialog(
        title: 'Ups',
        middleText: 'Total tagihan belum terpenuhi. Lanjutkan?',
        confirm: TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Simpan')),
        cancel: TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal',
                style: TextStyle(color: Colors.black.withOpacity(0.5)))),
      );
    }
    if (validateTotal != null && validateTotal!) {
      await saveToDatabase();

      if (isEdit.value) {
        displayInvoice.id = editedInvoice.id;
        displayInvoice.invoiceName = editedInvoice.invoiceName;
        displayInvoice.createdAt.value = editedInvoice.createdAt.value;
        displayInvoice.sales.value = editedInvoice.sales.value;
        displayInvoice.purchaseList.value = editedInvoice.purchaseList.value;
        displayInvoice.discount.value = editedInvoice.discount.value;
        displayInvoice.payments.value = editedInvoice.payments;
        displayInvoice.debtAmount.value = editedInvoice.debtAmount.value;
        displayInvoice.isDebtPaid.value = editedInvoice.isDebtPaid.value;
        displayInvoice.purchaseOrder.value = editedInvoice.purchaseOrder.value;
      }
    }
  }

  Future<void> saveToDatabase() async {
    await addPayment();
    // print('invoice.invoiceNumber ${editedInvoice.invoiceNumber}');
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      if (!buyProductController.isPurchaseOrder.value && !isEdit.value) {
        final logs = <LogStock>[];
        for (final cart in editedInvoice.purchaseList.value.items) {
          logs.add(LogStock(
            productId: cart.product.productId,
            productUuid: cart.product.id!,
            productName: cart.product.productName,
            storeId: editedInvoice.storeId,
            label: 'Beli',
            amount: cart.quantity.value,
            createdAt: DateTime.now(),
          ));
        }
        await productService.insertListLog(logs);
      }

      final products = <ProductModel>[];
      for (final cart in editedInvoice.purchaseList.value.items) {
        products.add(cart.product);
      }
      await productService.updateList(products);

      final date = DateTime.now();
      final dateCode =
          '${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${date.year.toString().substring(2)}${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}${date.millisecond.toString().padLeft(3, '0')}';
      editedInvoice.invoiceNumber ??= dateCode;

      for (final payment in editedInvoice.payments) {
        if (payment.id == null) {
          payment.invoiceId = editedInvoice.invoiceNumber!;
          payment.invoiceCreatedAt = editedInvoice.createdAt.value;
        }
      }

      if (isEdit.value) {
        print('invoice.payments.length ${editedInvoice.payments.length}');
        await invoiceSalesService.update(editedInvoice);
        Get.back();
      } else {
        await invoiceSalesService.insert(editedInvoice);
        Get.back();
        Get.back();
      }
      Get.back();
      await Get.defaultDialog(
          title: 'Berhasil', middleText: 'Invoice berhasil disimpan.');
    } catch (e) {
      Get.back();
      Get.back();
      await Get.defaultDialog(
          title: 'Gagal Menyimpan Invoice!', middleText: e.toString());
    }
  }
}
