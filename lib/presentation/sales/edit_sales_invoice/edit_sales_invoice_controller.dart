// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/dal/services/invoice_sales_service.dart';
// import '../../../infrastructure/dal/services/product_service.dart';
// import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
// import '../../../infrastructure/models/invoice_model/cart_model.dart';
// import '../../../infrastructure/models/invoice_sales_model.dart';
// import '../../../infrastructure/models/log_stock_model.dart';
// import '../../../infrastructure/models/product_model.dart';
// import '../../../infrastructure/models/sales_model.dart';
// import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
// // import '../../product/controllers/product.controller.dart';
// import '../controllers/sales.controller.dart';

// class EditInvoiceSalesController extends GetxController {
//   final createdAt = DateTime.now().obs;
//   late final ProductService productService = Get.find();
//   late SalesController salesC = Get.find();
//   late InvoiceSalesService invoiceSalesService = Get.find();
//   late final AuthService _authService = Get.find<AuthService>();
//   late final DatePickerController _datePickerC =
//       Get.put(DatePickerController());
//   late final foundProducts = productService.products;

//   final cart = Cart(items: <CartItem>[].obs).obs;
//   final initCartList = <CartItem>[].obs;
//   final removeCartList = <CartItem>[].obs;
//   final nomorInvoice = ''.obs;
//   final isPurchaseOrder = false.obs;

//   late InvoiceSalesModel currentInvoice;
//   late InvoiceSalesModel editInvoice;

//   late ScrollController scrollController = ScrollController();

//   void init() async {
//     nomorInvoice.value = '';
//     isPurchaseOrder.value = false;
//     cart.value.items.clear();
//     editInvoice = await createInvoice();
//     print('init buyC');
//     super.onInit();
//   }

//   //! PURCHASE ORDER HANDLE ===
//   void purchaseOrderHandle() {
//     print(isPurchaseOrder.value);
//     isPurchaseOrder.value = !isPurchaseOrder.value;
//   }

//   //! DISCOUNT ===
//   void discountHandle(String productId, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     cart.value.updateDiscount(productId, valueDouble);
//   }

//   //! DISCOUNT ===
//   void discountEditHandle(String productId, String value, Cart cart) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     cart.updateDiscount(productId, valueDouble);
//   }

//   //! SELL ===
//   void sellHandle(RxDouble sellprice, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     sellprice.value = valueDouble;
//   }

//   //! COST ===
//   void costHandle(CartItem cartItem, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     cartItem.product.costPrice.value = valueDouble;
//   }

//   //! QUANTITY HANDLE ===
//   void quantityHandle(CartItem cartItem, String quantity) {
//     cart.value.updateQuantity(
//         cartItem.product.productId, double.tryParse(quantity) ?? 0);
//   }

//   //! REMOVE FROM CART ===
//   void removeFromCart(CartItem cartItem) {
//     cart.value.removeItem(cartItem.product.id!);
//   }

//   //! EDIT
//   final amountOfChange = Cart(items: <CartItem>[].obs).obs;

//   void addToCart(ProductModel product) async {
//     amountOfChange.value.addItem(product);
//     editInvoice.purchaseList.value.addItem(product);
//     for (var aa in amountOfChange.value.items) {
//       print('aaaaaaaaa ${aa.quantity.value}');
//     }
//   }

//   void removeFromEditCart(ProductModel product, Cart cart) {
//     amountOfChange.value.removeItemStockSales(product, currentInvoice);
//     cart.removeItem(product.id!);

//     for (var aa in cart.items) {
//       print(
//           'aaaaaaaaa purchaseList ${aa.product.productName} ${aa.quantity.value}');
//     }
//     for (var aa in amountOfChange.value.items) {
//       print('aaaaaaaaa amount ${aa.product.productName} ${aa.quantity.value}');
//     }
//   }

//   void quantityEditHandle(CartItem cartItem, String quantity, Cart cart) {
//     amountOfChange.value.updateQuantityStockSales(
//         cartItem.product, double.tryParse(quantity) ?? 0, currentInvoice);

//     cart.updateQuantity(
//         cartItem.product.productId, double.tryParse(quantity) ?? 0);

//     for (var aa in cart.items) {
//       print(
//           'aaaaaaaaa awdawdawdawdawdwa ${aa.product.productName} ${aa.quantity.value}');
//     }
//     for (var aa in amountOfChange.value.items) {
//       print(
//           'aaaaaaaaa purchase ${aa.product.productName} ${aa.quantity.value}');
//     }
//   }

//   //! CREATE INVOICE ===
//   Future<InvoiceSalesModel> createInvoice() async {
//     late final SalesModel sales;
//     var selectedTime = TimeOfDay.now();
//     DateTime dateTime = DateTime(
//       _datePickerC.selectedDate.value.year,
//       _datePickerC.selectedDate.value.month,
//       _datePickerC.selectedDate.value.day,
//       selectedTime.hour,
//       selectedTime.minute,
//     );

//     if (salesC.selectedSales.value != null) {
//       sales = SalesModel(
//         id: salesC.selectedSales.value!.id,
//         salesId: salesC.selectedSales.value!.salesId,
//         name: salesC.selectedSales.value!.name,
//         phone: salesC.selectedSales.value!.phone,
//         address: salesC.selectedSales.value!.address,
//       );
//     } else {
//       sales = SalesModel(name: '', phone: '', address: '');
//     }

//     final invoice = InvoiceSalesModel(
//       id: null,
//       storeId: _authService.account.value!.storeId,
//       invoiceNumber: null,
//       invoiceName: nomorInvoice.value,
//       createdAt: dateTime,
//       sales: sales,
//       purchaseList: cart.value,
//       returnList: Cart(items: <CartItem>[].obs),
//       priceType: 1,
//       discount: cart.value.totalIndividualDiscount,
//       payments: [],
//       debtAmount: cart.value.totalCost,
//     );

//     print('awdawdawdwa ${sales.id}');
//     return invoice;
//   }

//   destroyHandle(InvoiceSalesModel invoice) async {
//     await invoiceSalesService.delete(invoice.id!);
//   }

//   //! UPDATE ===
//   Future<void> updateInvoice(InvoiceSalesModel invoice) async {
//     Get.defaultDialog(
//       title: 'Menyimpan Invoice...',
//       content: const CircularProgressIndicator(),
//       barrierDismissible: false,
//     );
//     try {
//       var logs = <LogStock>[];

//       if (!invoice.purchaseOrder.value) {
//         for (var cart in amountOfChange.value.items) {
//           var log = LogStock(
//             productId: cart.product.productId,
//             productUuid: cart.product.id!,
//             productName: cart.product.productName,
//             storeId: invoice.storeId,
//             label: 'Edit Pembelian',
//             amount: cart.quantity.value,
//             createdAt: DateTime.now(),
//           );
//           print('aaaw ${log.toJson()}');
//           logs.add(log);
//         }
//       }

//       DateTime date = DateTime.now();
//       String year = date.year.toString().substring(2);
//       String month = date.month.toString().padLeft(2, '0');
//       String day = date.day.toString().padLeft(2, '0');
//       String hour = date.hour.toString().padLeft(2, '0');
//       String minute = date.minute.toString().padLeft(2, '0');
//       String second = date.second.toString().padLeft(2, '0');
//       String millisecond = date.millisecond.toString().padLeft(3, '0');
//       String dateCode = '$month$day$year$hour$minute$second$millisecond';

//       invoice.invoiceNumber ??= dateCode;

//       for (var payment in invoice.payments) {
//         if (payment.id == null) {
//           payment.invoiceId = invoice.invoiceNumber.toString();
//           payment.invoiceCreatedAt = invoice.createdAt.value;
//         }
//         print('payment_sales ${payment.toJson()}');
//       }

//       await productService.insertListLog(logs);
//       for (var aa in invoice.purchaseList.value.items) {
//         print(aa.quantity);
//       }
//       await invoiceSalesService.update(invoice);

//       Get.back();

//       await Get.defaultDialog(
//         title: 'Berhasil',
//         middleText: 'Invoice berhasil diubah.',
//       );
//     } catch (e) {
//       print('-----------${e.toString()}---------------');
//       await Get.defaultDialog(
//         title: 'Gagal Menyimpan Invoice!',
//         middleText: e.toString(),
//       );
//       Get.back();
//       Get.back();
//     }
//   }
// }
