import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../core/util/generate_invoice_id.dart';
import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/log_stock_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../home/controllers/home.controller.dart';
import '../date_picker_widget/date_picker_widget_controller.dart';
import '../field_customer_widget/field_customer_widget_controller.dart';
import '../invoice_print_widget/invoice_print.dart';
import '../invoice_print_widget/print_ble_controller.dart';
import '../invoice_print_widget/print_usb_controller.dart';

class PaymentController extends GetxController {
  // Services
  late final AuthService _authService = Get.find<AuthService>();
  late final AccountService _accountService = Get.find();
  late final InvoiceService _invoiceService = Get.find();
  late final ProductService _productService = Get.find();

  // Controllers
  late final customerFieldC = Get.put(CustomerInputFieldController());
  late final HomeController _homeC = Get.find();
  late final DatePickerController _datePickerC = Get.find();

  @override
  void onInit() {
    if (Platform.isWindows) {
      Get.put(PrinterUsbController());
    } else if (Platform.isAndroid) {
      Get.put(PrinterBluetoothController());
    }
    super.onInit();
  }

  // Observables
  final paymentMethod = ['cash', 'transfer', 'deposit'].obs;
  final selectedPaymentMethod = ''.obs;
  final moneyChange = 0.0.obs;
  final bill = 0.0.obs;
  final isEdit = false.obs;
  final onlyPayment = false.obs;
  final isAdditionalDiscount = false.obs;

  // Text Controllers
  final paymentTextC = TextEditingController();
  final additionalDiscountTextC = TextEditingController();

  // Focus Nodes
  final additionalDiscountFocusNode = FocusNode();
  final paymentTextFocusNode = FocusNode();

  // Other variables
  var pay = 0.0.obs;
  var bundleDiscount = 0.0;
  late InvoiceModel displayInvoice;
  late InvoiceModel editedInvoice;
  final GlobalKey lastWidgetKey = GlobalKey();

  // Payment Methods
  void setPaymentMethod(String method) async {
    // print('clickedaaaa 1 method');
    selectedPaymentMethod.value = method;
    print('clickedaaaa 1 method ${selectedPaymentMethod.value}');
    await Future.delayed(const Duration(milliseconds: 100), scrollToLastWidget);
    await Future.delayed(const Duration(milliseconds: 300),
        () => paymentTextFocusNode.requestFocus());
    print('clickedaaaa 2 method ${selectedPaymentMethod.value}');
  }

  // Additional Discount
  void checkBoxAdditionalDiscount(InvoiceModel invoice) async {
    isAdditionalDiscount.value = !isAdditionalDiscount.value;
    additionalDiscountTextC.text = '';
    bundleDiscount = 0;
    bill.value = invoice.remainingDebt + invoice.additionalDIscount;
    await Future.delayed(const Duration(milliseconds: 100), scrollToLastWidget);
    await Future.delayed(const Duration(milliseconds: 300),
        () => additionalDiscountFocusNode.requestFocus());
  }

  // Scroll to last widget
  void scrollToLastWidget() {
    final context = lastWidgetKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Update Bill
  void updateBill(InvoiceModel invoice) {
    print('awdkjhawdhawkjdhawdhwauih ${invoice.additionalDIscount}');
    pay.value = paymentTextC.text.isEmpty
        ? 0
        : double.parse(paymentTextC.text.replaceAll('.', ''));
    bundleDiscount = additionalDiscountTextC.text.isEmpty
        ? 0
        : double.parse(additionalDiscountTextC.text.replaceAll('.', ''));
    bill.value =
        invoice.remainingDebt + invoice.additionalDIscount - bundleDiscount;
    moneyChange.value = bill.value - pay.value;
  }

  // Input Validation
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
    updateBill(invoice);
  }

  void onPayChanged(InvoiceModel invoice, String value) {
    if (value.isNotEmpty) {
      String newValue =
          currency.format(double.parse(value.replaceAll('.', '')));

      final selectedCustomer = customerFieldC.selectedCustomer.value;
      var isDepositActive = selectedCustomer != null &&
          selectedCustomer.deposit != null &&
          selectedCustomer.deposit! > 0 &&
          selectedPaymentMethod.value == 'deposit';

      var overDepositLimit = isDepositActive &&
          double.parse(value.replaceAll('.', '')) > selectedCustomer.deposit!;

      if (overDepositLimit) {
        _showOverDepositLimitDialog();
        newValue = '0';
      }

      if (newValue != paymentTextC.text) {
        paymentTextC.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(offset: newValue.length),
        );
      }
    }
    updateBill(invoice);
  }

  Future<void> _showOverDepositLimitDialog() async {
    await Get.defaultDialog(
      title: 'Peringatan',
      middleText: 'Jumlah pembayaran melebihi batas deposit.',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }

  // Add Payment
  Future addPayment() async {
    if (paymentTextC.text.isNotEmpty) {
      editedInvoice.addPayment(
        double.parse(paymentTextC.text.replaceAll('.', '')),
        method: selectedPaymentMethod.value,
        date: DateTime.now(),
      );
    }
  }

  // asign Payment Data
  void assign(
    InvoiceModel editableInvoice, {
    bool isEditMode = false,
    bool onlyPaymentMode = false,
  }) {
    displayInvoice = displayInvoice;
    selectedPaymentMethod.value = '';
    paymentTextC.text = '';
    editedInvoice = editableInvoice;
    pay.value = 0;
    bill.value = editedInvoice.remainingDebt;
    moneyChange.value = bill.value - pay.value;
    isEdit.value = isEditMode;
    onlyPayment.value = onlyPaymentMode;
    additionalDiscountTextC.text =
        currency.format(editableInvoice.additionalDIscount);
    isAdditionalDiscount.value = editableInvoice.additionalDIscount > 0;

    customerFieldC.clear();
    if (editedInvoice.customer.value != null) {
      customerFieldC.asignCustomer(editedInvoice.customer.value!);
    }
  }

  // Invoice Saving and Validation
  bool validateCustomer = true;
  bool validateTotal = true;
  late bool isNewInvoice;

  Future<void> saveInvoice() async {
    if (customerFieldC.validateCustomer() && editedInvoice.id == null) {
      validateCustomer = await _showConfirmationDialog(
          'Data Customer tidak lengkap. Lanjutkan?');
    }
    if (validateCustomer && moneyChange.value > 0) {
      validateTotal = await _showConfirmationDialog(
          'Total tagihan belum terpenuhi. Lanjutkan?');
    }
    print(validateCustomer);
    print(validateTotal);
    if (validateCustomer && validateTotal) {
      await saveToDatabase();

      if (isEdit.value) {
        displayInvoice.id = editedInvoice.id;
        displayInvoice.invoiceId = editedInvoice.invoiceId;
        displayInvoice.createdAt.value = editedInvoice.createdAt.value;
        displayInvoice.customer.value = editedInvoice.customer.value;
        displayInvoice.purchaseList.value = editedInvoice.purchaseList.value;
        displayInvoice.priceType.value = editedInvoice.priceType.value;
        displayInvoice.discount.value = editedInvoice.discount.value;
        displayInvoice.payments.value = editedInvoice.payments;
        displayInvoice.debtAmount.value = editedInvoice.debtAmount.value;
        displayInvoice.isDebtPaid.value = editedInvoice.isDebtPaid.value;
        displayInvoice.otherCosts.value = editedInvoice.otherCosts;
      }
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    final result = await Get.defaultDialog(
      title: 'Ups',
      middleText: message,
      confirm: TextButton(
          onPressed: () => Get.back(result: true), child: const Text('Simpan')),
      cancel: TextButton(
          onPressed: () => Get.back(result: false), child: const Text('Batal')),
    );
    return result ?? false;
  }

  Future saveToDatabase() async {
    if (!_authService.isOwner.value) {
      editedInvoice.account.value.name = _authService.selectedUser.value!.name;
    }

    isNewInvoice = editedInvoice.invoiceId == null;
    await customerFieldC.addCustomer(editedInvoice);
    editedInvoice.purchaseList.value.bundleDiscount.value = bundleDiscount;
    if (isNewInvoice) {
      await _initNewInvoice(editedInvoice);
    }
    print('invoice ${editedInvoice.id}');
    await addPayment();
    await _saveInvoiceToDatabase();
  }

  Future<void> _initNewInvoice(InvoiceModel invoice) async {
    invoice.initAt.value =
        _homeC.isCreatedAtCustom ? _homeC.createdAt.value : DateTime.now();
    invoice.invoiceId = await generateInvoiceId(invoice.customer.value!);
    // invoice.purchaseList.value.bundleDiscount.value = bundleDiscount;
    invoice.createdAt.value = DateTime(
      _datePickerC.selectedDate.value.year,
      _datePickerC.selectedDate.value.month,
      _datePickerC.selectedDate.value.day,
      _datePickerC.selectedTime.value.hour,
      _datePickerC.selectedTime.value.minute,
    );
    invoice.updateIsDebtPaid();
  }

  Future _saveInvoiceToDatabase() async {
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      print('isEditing? save ${isEdit.value}');

      // await _updateProduct(editedInvoice);

      if (selectedPaymentMethod.value == 'deposit') {
        await _updateDeposit();
      }

      await customerFieldC.handleSave();
      await customerFieldC.addCustomer(editedInvoice);
      _updatePaymentsInvoiceId(editedInvoice);

      final printInvoice = InvoiceModel.fromJson(editedInvoice.toJson());
      // print('prepare reset a ${invoice.id}');
      // print('prepare reset b $isNewInvoice');

      Get.back();
      Get.back();

      // if (!onlyPayment.value || !isEdit.value) {
      //   await _printInvoice(printInvoice);
      // }

      if (isNewInvoice) {
        _handleNewInvoice(editedInvoice);
        bool saved = await _showPrintDialog(printInvoice);

        print('prepare reset $saved');
        if (!saved) await _invoiceService.insert(editedInvoice);
        if (!isEdit.value) {
          await _saveLogStock(editedInvoice);
        }
        // print('prepare reset');
        await _homeC.resetData();
      } else {
        await _invoiceService.update(editedInvoice);
      }
    } catch (e) {
      await Get.defaultDialog(
          title: 'Gagal Menyimpan Invoice!', middleText: e.toString());
      Get.back();
      Get.back();
    }
  }

  Future<void> _updateDeposit() async {
    // if (customerFieldC.selectedCustomer.value != null)
    customerFieldC.selectedCustomer.value!.deposit =
        customerFieldC.selectedCustomer.value!.deposit! - pay.value;
    await Get.find<CustomerService>()
        .update(customerFieldC.selectedCustomer.value!);
  }

  Future<void> _saveLogStock(InvoiceModel invoice) async {
    final logs = <LogStock>[];
    for (final cart in invoice.purchaseList.value.items) {
      logs.add(LogStock(
        productId: cart.product.productId,
        productUuid: cart.product.id!,
        productName: cart.product.productName,
        storeId: invoice.storeId,
        label: 'Terjual',
        amount: -1 * cart.quantity.value,
        createdAt: DateTime.now(),
      ));
    }
    await _productService.insertListLog(logs);
  }

  Future<void> _updateProduct(InvoiceModel invoice) async {
    final products = <ProductModel>[];
    for (final cart in invoice.purchaseList.value.items) {
      cart.product.lastSold = DateTime.now();
      products.add(cart.product);
    }
    await _productService.updateList(products);
  }

  void _updatePaymentsInvoiceId(InvoiceModel invoice) {
    for (final payment in invoice.payments) {
      if (payment.id == null) {
        payment.invoiceId = invoice.invoiceId;
        payment.invoiceCreatedAt = invoice.createdAt.value;
      }
    }
  }

  void _handleNewInvoice(InvoiceModel invoice) {
    if (_authService.selectedUser.value != null) {
      invoice.account.value.name = _authService.selectedUser.value!.name;
    }
    if (_authService.account.value!.accountType != 'flexible') {
      invoice.isAppBillPaid.value = true;
    }
    invoice.customer.value?.id = customerFieldC.lastCustomersId.value;
    invoice.appBillAmount.value = invoice.totalAppBill;
    if (invoice.account.value.token != null) {
      final updatedAccount =
          AccountModel.fromJson(_authService.account.value!.toJson());
      updatedAccount.token = _homeC.token.value!;
      _accountService.update(updatedAccount);
    }
  }

  // Future<void> _printInvoice(InvoiceModel printInvoice) async {
  //   await _showPrintDialog(printInvoice);
  // }

  Future<bool> _showPrintDialog(InvoiceModel printInvoice) async {
    bool saved = false;
    await Get.dialog(
      AlertDialog(
        title: const Text('Invoice berhasil disimpan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (GetPlatform.isAndroid) {
                final printerC = Get.find<PrinterBluetoothController>();
                return printerC.message.value
                        .toLowerCase()
                        .contains('menghubungkan')
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: printerC.isPrinting.value
                            ? null
                            : () async {
                                await printerC.printReceipt(printInvoice);
                                if (!saved) {
                                  await _invoiceService.insert(editedInvoice);
                                }
                                saved = true;
                              },
                        icon: const Icon(Icons.print),
                        label: const Text('Cetak Struk'),
                      );
              } else {
                final printerC = Get.find<PrinterUsbController>();
                // printerC.invoice = invoice;
                return printerC.message.value
                        .toLowerCase()
                        .contains('menghubungkan')
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          IconButton(
                            onPressed: () => printInvoiceDialog(printInvoice),
                            icon: const Icon(Symbols.settings, fill: 1),
                          ),
                          SizedBox(width: 4),
                          ElevatedButton.icon(
                            onPressed: printerC.isPrinting.value ||
                                    printerC.selectedPrinter.value == null ||
                                    printerC.selectedPaperSize.value.isEmpty
                                ? null
                                : () async {
                                    await printerC.printReceipt(printInvoice);
                                    if (!saved) {
                                      await _invoiceService
                                          .insert(editedInvoice);
                                    }
                                    saved = true;
                                  },
                            icon: const Icon(Icons.print),
                            label: printerC.selectedPrinter.value == null ||
                                    printerC.selectedPaperSize.value.isEmpty
                                ? const Text('Printer Belum di Setting')
                                : const Text('Cetak Struk'),
                          ),
                        ],
                      );
              }
            }),
          ],
        ),
      ),
    );
    return saved;
  }

  Widget _buildPrinterSelection() {
    if (GetPlatform.isAndroid) {
      final printerC = Get.find<PrinterBluetoothController>();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Printer', border: OutlineInputBorder()),
              value: printerC.selectedDevice.value?.address,
              items: printerC.devices
                  .map((device) => DropdownMenuItem<String>(
                        value: device.address,
                        child: Text(
                          device.name!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                final device = printerC.devices
                    .firstWhereOrNull((d) => d.address == value);
                if (device != null) {
                  print('Menghubungkan Printer...');
                  printerC.connect(device);
                }
              },
            ),
          ),
        ],
      );
    } else {
      final printerC = Get.find<PrinterUsbController>();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Printer', border: OutlineInputBorder()),
              value: printerC.selectedPrinter.value?.name,
              items: printerC.devices
                  .map((device) => DropdownMenuItem<String>(
                        value: device.name,
                        child: Text(
                          device.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                final device =
                    printerC.devices.firstWhereOrNull((d) => d.name == value);
                if (device != null) {
                  print('Menghubungkan Printer...');
                  printerC.connect(device);
                }
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPaperSizeSelection() {
    if (GetPlatform.isAndroid) {
      final printerC = Get.find<PrinterBluetoothController>();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Ukuran', border: OutlineInputBorder()),
              value: printerC.selectedPaperSize.value.isEmpty
                  ? null
                  : printerC.selectedPaperSize.value,
              items: printerC.paperSize
                  .map((size) => DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      ))
                  .toList(),
              onChanged:
                  printerC.message.value.toLowerCase().contains('menghubungkan')
                      ? null
                      : (value) => printerC.setPaperSize(value!),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
              onPressed: printerC.startScan, icon: const Icon(Symbols.refresh)),
        ],
      );
    } else {
      final printerC = Get.find<PrinterUsbController>();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Ukuran', border: OutlineInputBorder()),
              value: printerC.selectedPaperSize.value.isEmpty
                  ? null
                  : printerC.selectedPaperSize.value,
              items: printerC.paperSize
                  .map((size) => DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      ))
                  .toList(),
              onChanged:
                  printerC.message.value.toLowerCase().contains('menghubungkan')
                      ? null
                      : (value) => printerC.setPaperSize(value!),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
              onPressed: printerC.startScan, icon: const Icon(Symbols.refresh)),
        ],
      );
    }
  }

  // bool get isNewInvoice => invoice.invoiceId == null;
}
