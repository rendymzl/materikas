// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../infrastructure/dal/services/invoice_service.dart';
// import '../../../infrastructure/dal/services/product_service.dart';
// import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
// import '../../../infrastructure/models/invoice_model/cart_model.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../../infrastructure/models/log_stock_model.dart';
// import '../../../infrastructure/models/product_model.dart';
// import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
// import '../../global_widget/payment_widget/payment_widget_controller.dart';
// import '../controllers/invoice.controller.dart';

// class ReturnInvoiceController extends GetxController {
//   late final invoiceC = Get.find<InvoiceController>();

//   late InvoiceModel currentInvoice = invoiceC.currentInvoice;
//   late InvoiceModel editInvoice;

//   late final customerFieldC = Get.put(CustomerInputFieldController());

//   final amountOfChange = Cart(items: <CartItem>[].obs).obs;
//   final returnamountOfChange = Cart(items: <CartItem>[].obs).obs;
//   final newReturnamountOfChange = Cart(items: <CartItem>[].obs).obs;

//   late final PaymentController paymentC = Get.put(PaymentController());

//   void assignCustomer() {
//     paymentC.asign(editInvoice);
//   }

//   //! ADD TO CART ===
//   void addToCart(ProductModel product) async {
//     amountOfChange.value.addItem(product);
//     editInvoice.purchaseList.value.addItem(product);
//     for (var aa in amountOfChange.value.items) {
//       print('aaaaaaaaa ${aa.quantity.value}');
//     }
//   }

//   //! QUANTITY HANDLE ===
//   void quantityHandle(CartItem cartItem, String quantity) {
//     amountOfChange.value.updateQuantityStock(
//       cartItem.product,
//       double.tryParse(quantity) ?? 0,
//       currentInvoice,
//       isEditPurchase: true,
//     );

//     editInvoice.purchaseList.value.updateQuantity(
//         cartItem.product.productId, double.tryParse(quantity) ?? 0);

//     for (var aa in amountOfChange.value.items) {
//       print(
//           'aaaaaaaaa purchase ${aa.product.productName} ${aa.quantity.value}');
//     }
//   }

//   //! ADD TO RETURN CART ===
//   void addToReturnCart(ProductModel product) async {
//     returnamountOfChange.value.addReturnItem(product);
//     editInvoice.purchaseList.value.addReturnItem(product);
//     for (var aa in returnamountOfChange.value.items) {
//       print('aaaaaaaaa ${aa.quantityReturn.value}');
//     }
//   }

//   void substractFromReturnCart(ProductModel product) async {
//     returnamountOfChange.value.substractFromReturnCart(product);
//     editInvoice.purchaseList.value.substractFromReturnCart(product);
//     for (var aa in returnamountOfChange.value.items) {
//       print('aaaaaaaaa ${aa.quantityReturn.value}');
//     }
//   }

//   void addToNewReturnCart(ProductModel product) async {
//     // editInvoice.returnList.value ??= Cart(items: <CartItem>[].obs);
//     newReturnamountOfChange.value.addReturnItem(product);
//     editInvoice.returnList.value!.addReturnItem(product);
//     for (var aa in newReturnamountOfChange.value.items) {
//       print('aaaaaaaaa newReturn ${aa.quantityReturn.value}');
//     }
//   }

//   //! QUANTITY RETURN HANDLE ===
//   void quantityReturnHandle(CartItem cartItem, String quantityReturn) {
//     returnamountOfChange.value.updateQuantityStock(
//       cartItem.product,
//       double.tryParse(quantityReturn) ?? 0,
//       currentInvoice,
//       // isReturn: true,
//     );
//     editInvoice.purchaseList.value.updateQuantityReturn(
//         cartItem.product.productId, double.tryParse(quantityReturn) ?? 0);
//     for (var aa in returnamountOfChange.value.items) {
//       print(
//           'aaaaaaaaa return ${aa.product.productName} ${aa.quantityReturn.value}');
//     }
//   }

//   void quantityNewReturnHandle(CartItem cartItem, String quantityReturn) {
//     newReturnamountOfChange.value.updateQuantityStock(
//       cartItem.product,
//       double.tryParse(quantityReturn) ?? 0,
//       currentInvoice,
//       newReturn: true,
//       // isReturn: true,
//     );
//     editInvoice.returnList.value!.updateQuantityReturn(
//       cartItem.product.productId,
//       double.tryParse(quantityReturn) ?? 0,
//       newReturn: true,
//     );
//     for (var aa in newReturnamountOfChange.value.items) {
//       print(
//           'aaaaaaaaa newReturn ${aa.product.productName} ${aa.quantityReturn.value}');
//     }
//   }

//   //! REMOVE FROM CART ===
//   void removeItem(ProductModel product) {
//     amountOfChange.value.removeItemStock(product, currentInvoice);
//     editInvoice.purchaseList.value.removeItem(product.id!);

//     for (var aa in amountOfChange.value.items) {
//       print(
//           'aaaaaaaaa amount ${aa.product.productName} ${aa.quantityReturn.value}');
//     }
//   }

//   //! REMOVE FROM CART ===
//   void removeNewReturn(ProductModel product) {
//     newReturnamountOfChange.value.removeItemStock(
//       product,
//       currentInvoice,
//       newReturn: true,
//     );
//     editInvoice.returnList.value!.removeItem(product.id!);

//     for (var aa in newReturnamountOfChange.value.items) {
//       print(
//           'aaaaaaaaa newReturn ${aa.product.productName} ${aa.quantityReturn.value}');
//     }
//   }

//   //! SELLPRICE ===
//   void sellPriceHandle(RxDouble sellPrice, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     sellPrice.value = valueDouble;
//     // cart.value.updateDiscount(productId, valueDouble);
//   }

//   void discountHandle(CartItem cart, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     cart.individualDiscount.value = valueDouble;
//   }

//   bool validateTotal = false;
//   Future<void> updateInvoice(InvoiceModel invoice,
//       {double prevTotalAppBill = 0}) async {
//     invoice.updateIsDebtPaid();
//     Get.defaultDialog(
//       title: 'Menyimpan Invoice...',
//       content: const CircularProgressIndicator(),
//       barrierDismissible: false,
//     );
//     try {
//       var logs = <LogStock>[];

//       for (var cart in amountOfChange.value.items) {
//         var log = LogStock(
//           productId: cart.product.productId,
//           productUuid: cart.product.id!,
//           productName: cart.product.productName,
//           storeId: invoice.storeId,
//           label: 'Edit Penjualan',
//           amount: -1 * cart.quantity.value,
//           createdAt: DateTime.now(),
//         );
//         print('aaaw ${log.toJson()}');
//         logs.add(log);
//       }

//       for (var cart in returnamountOfChange.value.items) {
//         var log = LogStock(
//           productId: cart.product.productId,
//           productUuid: cart.product.id!,
//           productName: cart.product.productName,
//           storeId: invoice.storeId,
//           label: cart.quantityReturn.value < 0 ? 'Batal Return' : 'Return',
//           amount: cart.quantityReturn.value,
//           createdAt: DateTime.now(),
//         );
//         print('aaaw ${log.toJson()}');
//         logs.add(log);
//       }

//       for (var cart in newReturnamountOfChange.value.items) {
//         var log = LogStock(
//           productId: cart.product.productId,
//           productUuid: cart.product.id!,
//           productName: cart.product.productName,
//           storeId: invoice.storeId,
//           label: cart.quantityReturn.value < 0 ? 'Batal Return' : 'Return',
//           amount: cart.quantityReturn.value,
//           createdAt: DateTime.now(),
//         );
//         print('aaaw ${log.toJson()}');
//         logs.add(log);
//       }

//       await Get.find<ProductService>().insertListLog(logs);

//       print('totalAppBill ${invoice.totalAppBill}');
//       print('prevTotalAppBill $prevTotalAppBill');

//       if (invoice.totalAppBill < prevTotalAppBill) {
//         if (DateTime.now().isBefore(DateTime(invoice.initAt.value!.year,
//             invoice.initAt.value!.month, invoice.initAt.value!.day + 1))) {
//           invoice.appBillAmount.value = invoice.totalAppBill;
//         }
//       } else {
//         invoice.appBillAmount.value = invoice.totalAppBill;
//       }

//       for (var payment in invoice.payments) {
//         if (payment.id == null) {
//           payment.invoiceId = invoice.invoiceId;
//           payment.invoiceCreatedAt = invoice.createdAt.value;
//         }
//       }
//       // print('update invoice payments lenght ${invoice.payments.length}');

//       // await _productService.updateList(productList);
//       // await _productService.updateList(productList);
//       await customerFieldC.handleSave();
//       await customerFieldC.addCustomer(invoice);

//       await Get.find<InvoiceService>().update(invoice);
//       print('---selesai updated invoice');
//       Get.back();

//       await Get.defaultDialog(
//         title: 'Berhasil',
//         middleText: 'Invoice berhasil diubah.',
//       );
//     } catch (e) {
//       await Get.defaultDialog(
//         title: 'Gagal Menyimpan Invoice!',
//         middleText: e.toString(),
//       );
//       Get.back();
//       Get.back();
//     }
//   }
// }
