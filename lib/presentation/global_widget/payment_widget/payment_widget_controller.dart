import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/util/generate_invoice_id.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../home/controllers/home.controller.dart';
import '../field_customer_widget/field_customer_widget_controller.dart';
import '../invoice_print_widget/invoice_print.dart';

class PaymentController extends GetxController {
  late final AuthService _authService = Get.find<AuthService>();
  late CustomerInputFieldController customerFieldC = Get.find();
  late final HomeController _homeC = Get.find();
  late final InvoiceService _invoiceService = Get.find();
  late final ProductService _productService = Get.find();
  late final CustomerService _customerService = Get.find();
  final paymentMethod = ['cash', 'transfer'].obs;
  final selectedPaymentMethod = ''.obs;
  final moneyChange = 0.0.obs;
  final bill = 0.0.obs;
  var pay = 0.0;
  var bundleDiscount = 0.0;

  final paymentTextC = TextEditingController();
  final additionalDiscountTextC = TextEditingController();
  final isAdditionalDiscount = false.obs;

  final additionalDiscountFocusNode = FocusNode();
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

  void checkBoxAdditionalDiscount(InvoiceModel invoice) async {
    isAdditionalDiscount.value = !isAdditionalDiscount.value;
    additionalDiscountTextC.text = '';
    bill.value = invoice.remainingDebt;

    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      scrollToLastWidget();
    });
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      additionalDiscountFocusNode.requestFocus();
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

  void additionalDiscount(InvoiceModel invoice, String value) {
    if (value.isNotEmpty) {
      String newValue =
          currency.format(double.parse(value.replaceAll('.', '')));
      if (newValue != additionalDiscountTextC.text) {
        additionalDiscountTextC.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }

    // double valueInt = value == '' ? 0 : double.parse(value.replaceAll('.', ''));
    // invoice.purchaseList.value.bundleDiscount.value = valueInt;
    // bill.value = invoice.remainingDebt - valueInt;
    updateBill(invoice);
  }

  void onPayChanged(InvoiceModel invoice, String value) {
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

  void updateBill(InvoiceModel invoice) {
    pay = paymentTextC.text == ''
        ? 0
        : double.parse(paymentTextC.text.replaceAll('.', ''));
    bundleDiscount = additionalDiscountTextC.text == ''
        ? 0
        : double.parse(additionalDiscountTextC.text.replaceAll('.', ''));
    bill.value = invoice.remainingDebt - bundleDiscount;
    moneyChange.value = bill.value - pay;
  }

  Future addPayment(InvoiceModel invoice) async {
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

  bool validateCustomer = false;
  bool validateTotal = false;
  Future<void> saveInvoice(InvoiceModel invoice,
      {bool onlyPayment = false}) async {
    if (customerFieldC.validateCustomer() && invoice.id == null) {
      await Get.defaultDialog(
        title: 'Ups',
        middleText: 'Data Customer tidak lengkap. lanjutkan?',
        confirm: TextButton(
          onPressed: () async {
            validateCustomer = true;
            Get.back();
          },
          child: const Text('Simpan'),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
            validateCustomer = false;
          },
          child: Text(
            'Batal',
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      );
    } else {
      validateCustomer = true;
    }
    if (validateCustomer & (moneyChange.value > 0)) {
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
    if (validateCustomer & validateTotal) {
      saveToDatabase(invoice, onlyPayment: onlyPayment);
    }
  }

  Future saveToDatabase(InvoiceModel invoice,
      {bool onlyPayment = false}) async {
    if (!_authService.isOwner.value) {
      invoice.account.value.name = _authService.selectedUser.value!.name;
    }

    final isNewInvoice = invoice.invoiceId == null;
    await customerFieldC.addCustomer(invoice);
    if (isNewInvoice) {
      invoice.invoiceId = await generateInvoiceId(invoice.customer.value!);
      invoice.purchaseList.value.bundleDiscount.value = bundleDiscount;
      invoice.updateIsDebtPaid();
    }
    await addPayment(invoice);

    InvoiceModel printInvoice = InvoiceModel.fromJson(invoice.toJson());

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

          var initCart = _homeC.initCartList.firstWhereOrNull(
            (cart) => cart.product.id == updatedProduct.id,
          );
          if (initCart != null) {
            updatedProduct.sellPrice1 = initCart.product.sellPrice1;
            updatedProduct.sellPrice2 = initCart.product.sellPrice2;
            updatedProduct.sellPrice3 = initCart.product.sellPrice3;
          }

          productList.add(updatedProduct);
        }

        await _productService.updateList(productList);
      }

      await customerFieldC.handleSave();
      await customerFieldC.addCustomer(invoice);

      if (isNewInvoice) {
        if (_authService.selectedUser.value != null) {
          invoice.account.value.name = _authService.selectedUser.value!.name;
        }

        invoice.customer.value?.id = customerFieldC.lastCustomersId.value;

        await _invoiceService.insert(invoice);
        _homeC.resetData();
        Get.back();
      } else {
        await _invoiceService.update(invoice);
        clear();
        if (onlyPayment) Get.back();
      }

      Get.back();

      // await AppDialog.show(
      //   title: 'Berhasil',
      //   content: 'Invoice berhasil disimpan.',
      //   confirmText: "Cetak Invoice",
      //   cancelText: "Kembali",
      //   onConfirm: () async {
      //     print(printInvoice);
      //     // Get.back();
      //     printInvoiceDialog(printInvoice);
      //   },
      // );

      // await Get.defaultDialog(
      //   title: 'Berhasil',
      //   middleText: 'Invoice berhasil disimpan.',
      // );
      Get.back();
      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil disimpan',
        confirm: SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.primaryColor)
                .copyWith(
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontWeight: FontWeight.normal)),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12.0))),
            onPressed: () async {
              // Get.back();
              printInvoiceDialog(printInvoice);
            },
            child: const Text('Cetak Invoice'),
          ),
        ),
        cancel: SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey)
                .copyWith(
                    textStyle: WidgetStateProperty.all(
                        const TextStyle(fontWeight: FontWeight.normal)),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12.0))),
            onPressed: () async {
              Get.back();
            },
            child: const Text('Kembali'),
          ),
        ),
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
