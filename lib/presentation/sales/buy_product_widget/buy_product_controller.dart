import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/log_stock_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/models/sales_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
// import '../../product/controllers/product.controller.dart';
import '../controllers/sales.controller.dart';
import '../detail_sales/payment_sales/payment_sales_controller.dart';

class BuyProductController extends GetxController {
  final createdAt = DateTime.now().obs;
  late final ProductService productService = Get.find();
  late SalesController salesC = Get.find();
  late InvoiceSalesService invoiceSalesService = Get.find();
  late final AuthService _authService = Get.find<AuthService>();
  late final DatePickerController _datePickerC =
      Get.put(DatePickerController());
  late final foundProducts = productService.products;

  final cart = Cart(items: <CartItem>[].obs).obs;
  final initCartList = <CartItem>[].obs;
  final removeCartList = <CartItem>[].obs;
  final nomorInvoice = ''.obs;
  final isPurchaseOrder = false.obs;

  late InvoiceSalesModel currentInvoice;
  late InvoiceSalesModel editInvoice;

  late ScrollController scrollController = ScrollController();

  void init() async {
    nomorInvoice.value = '';
    isPurchaseOrder.value = false;
    cart.value.items.clear();
    editInvoice = await createInvoice();
    print('init buyC');
  }

  void assign(InvoiceSalesModel invoice) async {
    currentInvoice = invoice;
    editInvoice = InvoiceSalesModel.fromJson(invoice.toJson());
    final paymentSalesC = Get.put(PaymentSalesController());
    paymentSalesC.displayInvoice = invoice;
    paymentSalesC.assign(editInvoice, isEditMode: true);
  }

  //! PURCHASE ORDER HANDLE ===
  void purchaseOrderHandle() {
    print(isPurchaseOrder.value);
    isPurchaseOrder.value = !isPurchaseOrder.value;
  }

  //! DISCOUNT ===
  void discountHandle(String productId, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cart.value.updateDiscount(productId, valueDouble);
  }

  //! DISCOUNT ===
  void discountEditHandle(String productId, String value, Cart cart) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cart.updateDiscount(productId, valueDouble);
  }

  //! SELL ===
  void sellHandle(RxDouble sellprice, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    sellprice.value = valueDouble;
  }

  //! COST ===
  void costHandle(CartItem cartItem, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cartItem.product.costPrice.value = valueDouble;
  }

  //! QUANTITY HANDLE ===
  void quantityHandle(CartItem cartItem, String quantity) {
    cart.value
        .updateQuantity(cartItem.product.id!, double.tryParse(quantity) ?? 0);
  }

  //! REMOVE FROM CART ===
  void removeFromCart(CartItem cartItem) {
    cart.value.removeItem(cartItem.product.id!);
  }

  //! EDIT
  final amountOfChange = Cart(items: <CartItem>[].obs).obs;

  void addToCart(ProductModel product) async {
    amountOfChange.value.addItem(product);
    editInvoice.purchaseList.value.addItem(product);
    for (var aa in amountOfChange.value.items) {
      print('aaaaaaaaa ${aa.quantity.value}');
    }
  }

  void removeFromEditCart(ProductModel product, Cart cart) {
    amountOfChange.value.removeItemStockSales(product, currentInvoice);
    cart.removeItem(product.id!);

    for (var aa in cart.items) {
      print(
          'aaaaaaaaa purchaseList ${aa.product.productName} ${aa.quantity.value}');
    }
    for (var aa in amountOfChange.value.items) {
      print('aaaaaaaaa amount ${aa.product.productName} ${aa.quantity.value}');
    }
  }

  void quantityEditHandle(CartItem cartItem, String quantity, Cart cart) {
    print('cartItem.product.productId ${cartItem.product.productName}');
    print('cartItem.product.productId ${cartItem.product.productId}');
    amountOfChange.value.updateQuantityStockSales(
        cartItem.product, double.tryParse(quantity) ?? 0, currentInvoice);

    cart.updateQuantity(cartItem.product.id!, double.tryParse(quantity) ?? 0);

    for (var aa in cart.items) {
      print(
          'aaaaaaaaa awdawdawdawdawdwa ${aa.product.productName} ${aa.quantity.value}');
    }
    for (var aa in amountOfChange.value.items) {
      print(
          'aaaaaaaaa purchase ${aa.product.productName} ${aa.quantity.value}');
    }
  }

  //! CREATE INVOICE ===
  Future<InvoiceSalesModel> createInvoice() async {
    late final SalesModel sales;
    var selectedTime = TimeOfDay.now();
    DateTime dateTime = DateTime(
      _datePickerC.selectedDate.value.year,
      _datePickerC.selectedDate.value.month,
      _datePickerC.selectedDate.value.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (salesC.selectedSales.value != null) {
      sales = SalesModel(
        id: salesC.selectedSales.value!.id,
        salesId: salesC.selectedSales.value!.salesId,
        name: salesC.selectedSales.value!.name,
        phone: salesC.selectedSales.value!.phone,
        address: salesC.selectedSales.value!.address,
      );
    } else {
      sales = SalesModel(name: '', phone: '', address: '');
    }

    final invoice = InvoiceSalesModel(
      id: null,
      storeId: _authService.account.value!.storeId,
      invoiceNumber: null,
      invoiceName: nomorInvoice.value,
      createdAt: dateTime,
      sales: sales,
      purchaseList: cart.value,
      returnList: Cart(items: <CartItem>[].obs),
      priceType: 1,
      discount: cart.value.totalIndividualDiscount,
      payments: [],
      debtAmount: cart.value.totalCost,
    );

    print('awdawdawdwa ${sales.id}');
    return invoice;
  }

  destroyHandle(InvoiceSalesModel invoice) async {
    await invoiceSalesService.delete(invoice.id!);
  }

  //! UPDATE ===
  Future<void> updateInvoice() async {
    print('awdawdawdawdawdawdawwad ');
    await Future.delayed(const Duration(milliseconds: 100));
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    print('awdawdawdawdawdawdawwad 2');
    try {
      var logs = <LogStock>[];

      if (!editInvoice.purchaseOrder.value) {
        for (var cart in amountOfChange.value.items) {
          var log = LogStock(
            productId: cart.product.productId,
            productUuid: cart.product.id!,
            productName: cart.product.productName,
            storeId: editInvoice.storeId,
            label: 'Edit Pembelian',
            amount: cart.quantity.value,
            createdAt: DateTime.now(),
          );
          print('aaaw ${log.toJson()}');
          logs.add(log);
        }
      }

      bool isPriceChanged = false;
      var productChangeList = <ProductModel>[];

      for (var editedCart in editInvoice.purchaseList.value.items) {
        var currentProduct =
            await productService.getProductById(editedCart.product.id!);

        var isChange = editedCart.product.costPrice.value !=
                currentProduct.costPrice.value ||
            editedCart.product.sellPrice1.value !=
                currentProduct.sellPrice1.value ||
            editedCart.product.sellPrice2?.value !=
                currentProduct.sellPrice2?.value ||
            editedCart.product.sellPrice3?.value !=
                currentProduct.sellPrice3?.value;

        if (isChange) productChangeList.add(editedCart.product);

        if (!isPriceChanged) {
          isPriceChanged = isChange;
        }
      }

      DateTime date = DateTime.now();
      String year = date.year.toString().substring(2);
      String month = date.month.toString().padLeft(2, '0');
      String day = date.day.toString().padLeft(2, '0');
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = date.minute.toString().padLeft(2, '0');
      String second = date.second.toString().padLeft(2, '0');
      String millisecond = date.millisecond.toString().padLeft(3, '0');
      String dateCode = '$month$day$year$hour$minute$second$millisecond';

      editInvoice.invoiceNumber ??= dateCode;

      for (var payment in editInvoice.payments) {
        if (payment.id == null) {
          payment.invoiceId = editInvoice.invoiceNumber.toString();
          payment.invoiceCreatedAt = editInvoice.createdAt.value;
        }
        print('payment_sales ${payment.toJson()}');
      }

      await productService.insertListLog(logs);

      await invoiceSalesService.update(editInvoice);

      currentInvoice.id = editInvoice.id;
      currentInvoice.invoiceName = editInvoice.invoiceName;
      currentInvoice.createdAt.value = editInvoice.createdAt.value;
      currentInvoice.sales.value = editInvoice.sales.value;
      currentInvoice.purchaseList.value = editInvoice.purchaseList.value;
      currentInvoice.discount.value = editInvoice.discount.value;
      currentInvoice.payments.value = editInvoice.payments;
      currentInvoice.debtAmount.value = editInvoice.debtAmount.value;
      currentInvoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
      currentInvoice.purchaseOrder.value = editInvoice.purchaseOrder.value;

      Get.back();

      if (isPriceChanged) {
        bool confirm = await Get.defaultDialog(
          title: "Konfirmasi Perubahan Harga",
          middleText:
              "Harga produk telah diubah. \nApakah harga sebelumnya ingin diubah ke harga terbaru?",
          // confirmTextColor: Colors.white,
          // cancelTextColor: Colors.white,
          textConfirm: "Ya",
          textCancel: "Tidak",
          // buttonColor: Get.theme.primaryColor,
          onCancel: () => Get.back(result: false),
          onConfirm: () => Get.back(result: true),
        );
        if (confirm) {
          await productService.updateList(productChangeList);
        }
      }

      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil diubah.',
      );
    } catch (e) {
      print('-----------${e.toString()}---------------');
      await Get.defaultDialog(
        title: 'Gagal Menyimpan Invoice!',
        middleText: e.toString(),
      );
      Get.back();
      Get.back();
    }
  }
}
