import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../../infrastructure/dal/services/product_service.dart';
import '../../../../infrastructure/models/invoice_sales_model.dart';
import '../../../../infrastructure/models/product_model.dart';
import '../../../../infrastructure/models/sales_model.dart';
import '../../../../infrastructure/utils/display_format.dart';
import '../../buy_product_widget/buy_product_controller.dart';
import '../../controllers/sales.controller.dart';

class PaymentSalesController extends GetxController {
  late final BuyProductController _buyProductC =
      Get.put(BuyProductController());
  late final SalesController _salesC = Get.find();
  late final ProductService _productService = Get.find();
  late final InvoiceSalesService _invoiceSalesService = Get.find();
  final paymentMethod = ['cash', 'transfer'].obs;
  final selectedPaymentMethod = ''.obs;
  final moneyChange = 0.0.obs;
  final bill = 0.0.obs;
  var pay = 0.0;
  var bundleDiscount = 0.0;

  final paymentTextC = TextEditingController();

  final paymentTextFocusNode = FocusNode();
  final GlobalKey lastWidgetKey = GlobalKey();
  // final scrollC = ScrollController();

  void setPaymentMethod(String method) async {
    selectedPaymentMethod.value = method;

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      scrollToLastWidget();
    });
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      paymentTextFocusNode.requestFocus();
    });
  }

  void scrollToLastWidget() async {
    final context = lastWidgetKey.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPayChanged(InvoiceSalesModel invoice, String value) {
    if (value.isNotEmpty) {
      String newValue =
          currency.format(double.parse(value.replaceAll('.', '')));
      if (newValue != paymentTextC.text) {
        paymentTextC.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    // double valueInt = value == '' ? 0 : double.parse(value.replaceAll('.', ''));
    // moneyChange.value = bill.value - valueInt;
    updateBill(invoice);
  }

  void updateBill(InvoiceSalesModel invoice) {
    pay = paymentTextC.text == ''
        ? 0
        : double.parse(paymentTextC.text.replaceAll('.', ''));

    bill.value = invoice.remainingDebt;
    moneyChange.value = bill.value - pay;
  }

  Future addPayment(InvoiceSalesModel invoice) async {
    if (paymentTextC.text != '') {
      invoice.addPayment(
        double.parse(paymentTextC.text.replaceAll('.', '')),
        method: selectedPaymentMethod.value,
        date: DateTime.now(),
      );
    }
  }

  void clear() {
    selectedPaymentMethod.value = '';
    paymentTextC.text = '';
    moneyChange.value = 0;
  }

  bool validateTotal = false;
  Future<void> saveInvoice(InvoiceSalesModel invoice,
      {bool isEdit = false, bool onlyPayment = false}) async {
    if (moneyChange.value > 0) {
      await Get.defaultDialog(
        title: 'Ups',
        middleText: 'Total tagihan belum terpenuhi. lanjutkan?',
        confirm: TextButton(
          onPressed: () async {
            validateTotal = true;
            Get.back();
          },
          child: const Text('Simpan'),
        ),
        cancel: TextButton(
          onPressed: () {
            validateTotal = false;
            Get.back();
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      );
    } else {
      validateTotal = true;
    }
    if (validateTotal) {
      saveToDatabase(invoice, isEdit: isEdit, onlyPayment: onlyPayment);
    }
  }

  Future saveToDatabase(InvoiceSalesModel invoice,
      {bool isEdit = false, bool onlyPayment = false}) async {
    await addPayment(invoice);

    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      if (!onlyPayment) {
        var productList = <ProductModel>[];

        for (var updatedCart in invoice.purchaseList.value.items) {
          if (updatedCart.product.sold != null) {
            updatedCart.product.sold!.value =
                updatedCart.product.sold!.value + updatedCart.quantity.value;
          } else {
            updatedCart.product.sold = updatedCart.quantity;
          }
          print('stock updatedCart ${updatedCart.product.stock.value}');
          ProductModel updatedProduct =
              ProductModel.fromJson(updatedCart.product.toJson());
          productList.add(updatedProduct);
        }

        await _productService.updateList(productList);
      }

      if (!isEdit || !onlyPayment) {
        await _invoiceSalesService.insert(invoice);
        _buyProductC.clear();
        late SalesModel selectedSales;
        selectedSales = _salesC.sales
            .firstWhere((sales) => sales.id == _salesC.selectedSales.value!.id);
        _salesC.selectedSales.value = null;
        _salesC.selectedSalesHandle(selectedSales);
        Get.back();
        Get.back();
      } else {
        await _invoiceSalesService.update(invoice);
        clear();
        if (onlyPayment) Get.back();
      }

      Get.back();

      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil disimpan.',
      );
    } catch (e) {
      await Get.defaultDialog(
        title: 'Gagal Menyimpan Invoice!',
        middleText: e.toString(),
      );
      Get.back();
      Get.back();
    }
  }
}
