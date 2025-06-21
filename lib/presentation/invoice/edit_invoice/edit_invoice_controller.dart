import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/log_stock_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/payment_widget/payment_widget_controller.dart';
import '../controllers/invoice.controller.dart';

class EditInvoiceController extends GetxController {
  late final invoiceC = Get.find<InvoiceController>();

  late InvoiceModel currentInvoice = invoiceC.displayInvoice;
  late InvoiceModel editInvoice;

  late final customerFieldC = Get.put(CustomerInputFieldController());

  final amountOfChange = Cart(items: <CartItem>[].obs).obs;
  final returnamountOfChange = Cart(items: <CartItem>[].obs).obs;
  final newReturnamountOfChange = Cart(items: <CartItem>[].obs).obs;

  late final PaymentController paymentC = Get.put(PaymentController());

  void init(InvoiceModel invoice) {
    print('invoice inited Total Bill ${invoice.totalBill}');
    currentInvoice = invoice;
    editInvoice = InvoiceModel.fromJson(invoice.toJson());
    paymentC.displayInvoice = invoice;
    paymentC.assign(editInvoice, isEditMode: true);
  }

  //! ADD TO CART ===
  void addToCart(ProductModel product) async {
    amountOfChange.value.addItem(product);
    editInvoice.purchaseList.value.addItem(product);
    for (var aa in amountOfChange.value.items) {
      print('aaaaaaaaa ${aa.quantity.value}');
    }
  }

  //! QUANTITY HANDLE ===
  void quantityHandle(CartItem cartItem, String quantity) {
    amountOfChange.value.updateQuantityStock(
      cartItem.product,
      double.tryParse(quantity) ?? 0,
      currentInvoice,
      isEditPurchase: true,
    );

    editInvoice.purchaseList.value
        .updateQuantity(cartItem.product.id!, double.tryParse(quantity) ?? 0);

    for (var aa in amountOfChange.value.items) {
      print(
          'aaaaaaaaa purchase ${aa.product.productName} ${aa.quantity.value}');
    }
  }

  //! ADD TO RETURN CART ===
  void addToReturnCart(ProductModel product) async {
    returnamountOfChange.value.addReturnItem(product);
    editInvoice.purchaseList.value.addReturnItem(product);
    for (var aa in returnamountOfChange.value.items) {
      print('aaaaaaaaa ${aa.quantityReturn.value}');
    }
  }

  void substractFromReturnCart(ProductModel product) async {
    returnamountOfChange.value.substractFromReturnCart(product);
    editInvoice.purchaseList.value.substractFromReturnCart(product);
    for (var aa in returnamountOfChange.value.items) {
      print('aaaaaaaaa ${aa.quantityReturn.value}');
    }
  }

  void addToNewReturnCart(ProductModel product) async {
    // editInvoice.returnList.value ??= Cart(items: <CartItem>[].obs);
    newReturnamountOfChange.value.addReturnItem(product);
    editInvoice.returnList.value!.addReturnItem(product);
    for (var aa in newReturnamountOfChange.value.items) {
      print('aaaaaaaaa newReturn ${aa.quantityReturn.value}');
    }
  }

  //! QUANTITY RETURN HANDLE ===
  void quantityReturnHandle(CartItem cartItem, String quantityReturn) {
    returnamountOfChange.value.updateQuantityStock(
      cartItem.product,
      double.tryParse(quantityReturn) ?? 0,
      currentInvoice,
      // isReturn: true,
    );
    editInvoice.purchaseList.value.updateQuantityReturn(
        cartItem.product.id!, double.tryParse(quantityReturn) ?? 0);
    for (var aa in returnamountOfChange.value.items) {
      print(
          'aaaaaaaaa return ${aa.product.productName} ${aa.quantityReturn.value}');
    }
  }

  void quantityNewReturnHandle(CartItem cartItem, String quantityReturn) {
    newReturnamountOfChange.value.updateQuantityStock(
      cartItem.product,
      double.tryParse(quantityReturn) ?? 0,
      currentInvoice,
      newReturn: true,
      // isReturn: true,
    );
    editInvoice.returnList.value!.updateQuantityReturn(
      cartItem.product.id!,
      double.tryParse(quantityReturn) ?? 0,
      newReturn: true,
    );
    for (var aa in newReturnamountOfChange.value.items) {
      print(
          'aaaaaaaaa newReturn ${aa.product.productName} ${aa.quantityReturn.value}');
    }
  }

  //! REMOVE FROM CART ===
  void removeItem(ProductModel product) {
    amountOfChange.value.removeItemStock(product, currentInvoice);
    editInvoice.purchaseList.value.removeItem(product.id!);
    editInvoice.updateIsDebtPaid();

    for (var aa in amountOfChange.value.items) {
      print(
          'aaaaaaaaa amount ${aa.product.productName} ${aa.quantityReturn.value}');
    }
  }

  //! REMOVE FROM CART ===
  void removeNewReturn(ProductModel product) {
    newReturnamountOfChange.value.removeItemStock(
      product,
      currentInvoice,
      newReturn: true,
    );
    editInvoice.returnList.value!.removeItem(product.id!);

    // for (var aa in newReturnamountOfChange.value.items) {
    //   print(
    //       'aaaaaaaaa newReturn ${aa.product.productName} ${aa.quantityReturn.value}');
    // }
  }

  //! SELLPRICE ===
  void sellPriceHandle(RxDouble sellPrice, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    sellPrice.value = valueDouble;
    // cart.value.updateDiscount(id, valueDouble);
  }

  void discountHandle(CartItem cart, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cart.individualDiscount.value = valueDouble;
  }

  bool validateTotal = false;
  Future<void> updateInvoice() async {
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      var logs = <LogStock>[];

      for (var cart in amountOfChange.value.items) {
        var log = LogStock(
          productId: cart.product.productId,
          productUuid: cart.product.id!,
          productName: cart.product.productName,
          storeId: editInvoice.storeId,
          label: 'Edit Penjualan',
          amount: -1 * cart.quantity.value,
          createdAt: DateTime.now(),
        );
        print('aaaw ${log.toJson()}');
        logs.add(log);
      }

      for (var cart in returnamountOfChange.value.items) {
        var log = LogStock(
          productId: cart.product.productId,
          productUuid: cart.product.id!,
          productName: cart.product.productName,
          storeId: editInvoice.storeId,
          label: cart.quantityReturn.value < 0 ? 'Batal Return' : 'Return',
          amount: cart.quantityReturn.value,
          createdAt: DateTime.now(),
        );
        print('aaaw ${log.toJson()}');
        logs.add(log);
      }

      for (var cart in newReturnamountOfChange.value.items) {
        var log = LogStock(
          productId: cart.product.productId,
          productUuid: cart.product.id!,
          productName: cart.product.productName,
          storeId: editInvoice.storeId,
          label: cart.quantityReturn.value < 0 ? 'Batal Return' : 'Return',
          amount: cart.quantityReturn.value,
          createdAt: DateTime.now(),
        );
        print('aaaw ${log.toJson()}');
        logs.add(log);
      }

      await Get.find<ProductService>().insertListLog(logs);

      print('totalAppBill ${editInvoice.totalAppBill}');

      if (editInvoice.totalAppBill < currentInvoice.totalAppBill) {
        if (DateTime.now().isBefore(DateTime(
            editInvoice.initAt.value!.year,
            editInvoice.initAt.value!.month,
            editInvoice.initAt.value!.day + 1))) {
          editInvoice.appBillAmount.value = currentInvoice.totalAppBill;
        }
      } else {
        editInvoice.appBillAmount.value = currentInvoice.totalAppBill;
      }

      for (var payment in editInvoice.payments) {
        if (payment.id == null) {
          payment.invoiceId = editInvoice.invoiceId;
          payment.invoiceCreatedAt = editInvoice.createdAt.value;
        }
      }
      editInvoice.updateIsDebtPaid();
      await customerFieldC.handleSave();
      await customerFieldC.addCustomer(editInvoice);
      await Get.find<InvoiceService>().update(editInvoice);

      currentInvoice.id = editInvoice.id;
      currentInvoice.invoiceId = editInvoice.invoiceId;
      currentInvoice.createdAt.value = editInvoice.createdAt.value;
      currentInvoice.customer.value = editInvoice.customer.value;
      currentInvoice.purchaseList.value = editInvoice.purchaseList.value;
      currentInvoice.returnList.value = editInvoice.returnList.value;
      currentInvoice.returnFee.value = editInvoice.returnFee.value;
      currentInvoice.priceType.value = editInvoice.priceType.value;
      currentInvoice.discount.value = editInvoice.discount.value;
      currentInvoice.payments.value = editInvoice.payments;
      currentInvoice.debtAmount.value = editInvoice.debtAmount.value;
      currentInvoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
      currentInvoice.otherCosts.value = editInvoice.otherCosts;

      print('---selesai updated invoice ${currentInvoice.createdAt.value}');
      print('---selesai updated invoice');
      Get.back();

      await Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Invoice berhasil diubah.',
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


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/dal/services/invoice_service.dart';
// import '../../../infrastructure/dal/services/product_service.dart';
// import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
// import '../../../infrastructure/models/invoice_model/cart_model.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../../infrastructure/models/log_stock_model.dart';
// import '../../../infrastructure/models/product_model.dart';
// import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
// import '../../global_widget/payment_widget/payment_widget_controller.dart';
// import '../../product/controllers/product.controller.dart';

// class EditInvoiceController extends GetxController {
//   late final PaymentController paymentC = Get.put(PaymentController());
//   late final InvoiceService _invoiceService = Get.find();
//   late final ProductService _productService = Get.find();
//   late final ProductController _productC = Get.put(ProductController());
//   late final foundProducts = _productC.displayedItems;
//   final AuthService accountC = Get.find();
//   late CustomerInputFieldController customerFieldC = Get.find();

//   final amountOfChange = Cart(items: <CartItem>[].obs).obs;
//   final returnamountOfChange = Cart(items: <CartItem>[].obs).obs;
//   final newReturnamountOfChange = Cart(items: <CartItem>[].obs).obs;

//   final initCartList = <CartItem>[].obs;
//   final initAdditionalCartList = <CartItem>[].obs;
//   final removeCartList = <CartItem>[].obs;

//   final priceType = 1.obs;

//   late InvoiceModel currentInvoice;
//   late InvoiceModel editInvoice;

//   // CartItem? checkExistence(
//   //   ProductModel product,
//   //   List<CartItem> productList,
//   // ) {
//   //   return productList.firstWhereOrNull(
//   //     (item) => item.product.id == product.id,
//   //   );
//   // }

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

//   // void addToReturnCart(ProductModel product, Cart cart,
//   //     {bool isReturn = false}) {
//   //   //! add product to initCartItem
//   //   var initAdditionalCartItem =
//   //       checkExistence(product, initAdditionalCartList);

//   //   if (initAdditionalCartItem == null) {
//   //     ProductModel initProduct = ProductModel.fromJson(product.toJson());
//   //     CartItem initItem =
//   //         CartItem(product: initProduct, quantity: 0, quantityReturn: 0);
//   //     initAdditionalCartList.add(initItem);
//   //     initAdditionalCartItem = initItem;
//   //   }
//   //   //!---

//   //   //! change Stock
//   //   CartItem cartItem =
//   //       CartItem(product: product, quantity: 0, quantityReturn: 1);
//   //   cartItem.product.stock.value += 1;
//   //   print('stock: ${cartItem.product.stock.value}');
//   //   //!---

//   //   //! add product to cart

//   //   cart.addReturnItem(cartItem);
//   //   //!---
//   // }

//   // void addToCart(ProductModel product, Cart editedCart,
//   //     {bool isReturn = false}) {
//   //   //! add product to initCartItem
//   //   var initCartItem = checkExistence(product, initCartList);
//   //   print("initCartItem $initCartItem");
//   //   if (initCartItem == null) {
//   //     ProductModel initProduct = ProductModel.fromJson(product.toJson());
//   //     CartItem initItem = CartItem(product: initProduct, quantity: 0);
//   //     initCartList.add(initItem);
//   //     initCartItem = initItem;
//   //   }
//   //   //!---
//   //   print("initCartItem $initCartItem");

//   //   //! change Stock
//   //   CartItem cartItem = CartItem(product: product, quantity: 1);
//   //   cartItem.product.stock.value -= 1;
//   //   print('stock addToCart: ${cartItem.product.stock.value}');
//   //   //!---

//   //   //! add product to cart
//   //   editedCart.addItem(cartItem.product);
//   //   //!---
//   // }

//   // void quantityMoveHandle(CartItem cartItem, bool isReturn) {
//   //   //! add product to initCartItem
//   //   var initCartItem = checkExistence(cartItem.product, initCartList);

//   //   if (initCartItem == null) {
//   //     var foundProduct = foundProducts
//   //         .firstWhereOrNull((item) => item.id == cartItem.product.id);
//   //     CartItem initItem = CartItem.fromJson(cartItem.toJson());
//   //     if (foundProduct != null) {
//   //       initItem.product.stock.value = foundProduct.stock.value;
//   //     }
//   //     initCartList.add(initItem);
//   //     initCartItem = initItem;
//   //   }
//   //   //!---

//   //   //! change Quantity
//   //   cartItem.quantityReturn.value += isReturn ? -1 : 1;
//   //   cartItem.quantity.value += isReturn ? 1 : -1;
//   //   //!---

//   //   //! change Stock
//   //   cartItem.product.stock.value += isReturn ? -1 : 1;
//   //   //!---
//   // }

//   //! SELLPRICE ===
//   void sellPriceHandle(RxDouble sellPrice, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     sellPrice.value = valueDouble;
//     // cart.value.updateDiscount(productId, valueDouble);
//   }

//   void priceTypeHandleCheckBox(int type) async {
//     priceType.value == type ? priceType.value = 1 : priceType.value = type;
//     editInvoice.priceType.value = priceType.value;
//     print(priceType.value);
//     // invoice.priceType.value = priceType.value;
//   }

//   //! QUANTITY HANDLE ===
//   // void quantityHandle(CartItem cartItem, String quantity, bool isReturn,
//   //     {bool isLockQty = false}) {
//   //   //! add product to initCartItem
//   //   var initCartItem = checkExistence(cartItem.product, initCartList);

//   //   if (initCartItem == null) {
//   //     var foundProduct = foundProducts
//   //         .firstWhereOrNull((item) => item.id == cartItem.product.id);
//   //     CartItem initItem = CartItem.fromJson(cartItem.toJson());
//   //     if (foundProduct != null) {
//   //       initItem.product.stock.value = foundProduct.stock.value;
//   //     }
//   //     initCartList.add(initItem);
//   //     initCartItem = initItem;
//   //   }
//   //   //!---

//   //   //! change Quantity
//   //   if (isReturn) {
//   //     var qtyReturn = double.tryParse(quantity) ?? 0;
//   //     var qty = initCartItem.quantity.value - (double.tryParse(quantity) ?? 0);
//   //     cartItem.quantityReturn.value = qtyReturn;
//   //     cartItem.quantity.value = qty;
//   //     if (isLockQty && qty < 0) {
//   //       qty = 0;
//   //       qtyReturn = initCartItem.quantity.value;
//   //     }
//   //     cartItem.quantityReturn.value = qtyReturn;
//   //     cartItem.quantity.value = qty;
//   //   } else {
//   //     cartItem.quantity.value = double.tryParse(quantity) ?? 0;
//   //   }
//   //   //!---

//   //   //! change Stock
//   //   cartItem.product.stock.value = initCartItem.product.stock.value +
//   //       (initCartItem.quantity.value - cartItem.quantity.value) +
//   //       (cartItem.quantityReturn.value - initCartItem.quantityReturn.value);
//   //   //!---
//   // }

//   void discountHandle(CartItem cart, String value) {
//     double valueDouble = value == '' ? 0 : double.parse(value);
//     cart.individualDiscount.value = valueDouble;
//   }

//   //! CLEAR ===
//   void clear() {
//     initCartList.clear();
//     initAdditionalCartList.clear();
//     removeCartList.clear();
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
//       // var productList = <ProductModel>[];

//       // for (var purchaseCart in invoice.purchaseList.value.items) {
//       //   if (purchaseCart.product.sold != null) {
//       //     purchaseCart.product.sold!.value =
//       //         purchaseCart.product.sold!.value + purchaseCart.quantity.value;
//       //   } else {
//       //     purchaseCart.product.sold = purchaseCart.quantity;
//       //   }
//       //   print(
//       //       '---stock purchaseCart ${purchaseCart.product.productName} ${purchaseCart.product.stock.value}');
//       //   var updatedProduct = initCartList.firstWhereOrNull(
//       //     (item) => item.product.id == purchaseCart.product.id,
//       //   );
//       //   if (updatedProduct != null) {
//       //     ProductModel product =
//       //         ProductModel.fromJson(purchaseCart.product.toJson());
//       //     productList.add(product);
//       //   }
//       // }

//       // if (invoice.returnList.value != null) {
//       //   for (var returnCart in invoice.returnList.value!.items) {
//       //     if (returnCart.product.sold != null) {
//       //       returnCart.product.sold!.value = returnCart.product.sold!.value -
//       //           returnCart.quantityReturn.value;
//       //     } else {
//       //       returnCart.product.sold = returnCart.quantityReturn;
//       //     }
//       //     print('stock returnCart ${returnCart.product.stock.value}');

//       //     var updatedProduct = initAdditionalCartList.firstWhereOrNull(
//       //       (item) => item.product.id == returnCart.product.id,
//       //     );
//       //     if (updatedProduct != null) {
//       //       ProductModel updatedProduct =
//       //           ProductModel.fromJson(returnCart.product.toJson());
//       //       var foundUpdatedProduct = productList
//       //           .firstWhereOrNull((item) => item.id == updatedProduct.id);
//       //       if (foundUpdatedProduct != null) {
//       //         foundUpdatedProduct.stock.value = returnCart.product.stock.value;
//       //       } else {
//       //         productList.add(updatedProduct);
//       //       }
//       //     }
//       //   }
//       // }

//       // print('removeCartList ${removeCartList.length}');
//       // for (var removedCart in removeCartList) {
//       //   var foundProduct = foundProducts
//       //       .firstWhereOrNull((item) => item.id == removedCart.product.id);

//       //   if (foundProduct != null) {
//       //     if (foundProduct.sold != null) {
//       //       foundProduct.sold!.value -= removedCart.quantity.value;
//       //       foundProduct.sold!.value += removedCart.quantityReturn.value;
//       //     } else {
//       //       foundProduct.sold!.value =
//       //           removedCart.quantity.value + removedCart.quantityReturn.value;
//       //     }
//       //   }

//       //   // print('removedCartItem ${removedCartItem[0].toJson()}');

//       //   print('stock removedCart ${removedCart.product.stock.value}');
//       //   ProductModel updatedProduct =
//       //       ProductModel.fromJson(removedCart.product.toJson());
//       //   var foundUpdatedProduct = productList
//       //       .firstWhereOrNull((item) => item.id == updatedProduct.id);
//       //   if (foundUpdatedProduct != null) {
//       //     foundUpdatedProduct.stock.value = removedCart.product.stock.value;
//       //   } else {
//       //     productList.add(updatedProduct);
//       //   }
//       // }

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

//       await _productService.insertListLog(logs);

//       if (removeCartList.isNotEmpty) {
//         List<RemoveProduct> removedCartItem = [];
//         removedCartItem.add(RemoveProduct(
//             removeAt: DateTime.now(),
//             removedCart: Cart(items: removeCartList)));
//         // print('invoice ${invoice.toJson()}');
//         invoice.removeProduct.assignAll(removedCartItem);
//       }

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
//       await _invoiceService.update(invoice);
//       print('---selesai updated invoice');
//       clear();
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

//   @override
//   void onClose() {
//     for (var cartItem in initCartList) {
//       var product = foundProducts.firstWhereOrNull(
//         (p) => p.id == cartItem.product.id,
//       );
//       if (product != null) {
//         product.stock.value = cartItem.product.stock.value;
//       }
//     }
//     clear();
//     print('closed');
//   }
// }
