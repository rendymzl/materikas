import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../global_widget/payment_widget/payment_widget_controller.dart';

class EditInvoiceController extends GetxController {
  late final PaymentController paymentC = Get.put(PaymentController());
  late final InvoiceService _invoiceService = Get.find();
  late final ProductService _productService = Get.find<ProductService>();
  late final foundProducts = _productService.foundProducts;
  final AuthService accountC = Get.find();

  final initCartList = <CartItem>[].obs;
  final initAdditionalCartList = <CartItem>[].obs;
  final removeCartList = <CartItem>[].obs;

  final priceType = 1.obs;

  CartItem? checkExistence(
    ProductModel product,
    List<CartItem> productList,
  ) {
    return productList.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );
  }

  void addToReturnCart(ProductModel product, Cart cart,
      {bool isReturn = false}) {
    //! add product to initCartItem
    var initAdditionalCartItem =
        checkExistence(product, initAdditionalCartList);

    if (initAdditionalCartItem == null) {
      ProductModel initProduct = ProductModel.fromJson(product.toJson());
      CartItem initItem =
          CartItem(product: initProduct, quantity: 0, quantityReturn: 0);
      initAdditionalCartList.add(initItem);
      initAdditionalCartItem = initItem;
    }
    //!---

    //! change Stock
    CartItem cartItem =
        CartItem(product: product, quantity: 0, quantityReturn: 1);
    cartItem.product.stock.value += 1;
    print('stock: ${cartItem.product.stock.value}');
    //!---

    //! add product to cart

    cart.addReturnItem(cartItem);
    //!---
  }

  void addToCart(ProductModel product, Cart editedCart,
      {bool isReturn = false}) {
    //! add product to initCartItem
    var initCartItem = checkExistence(product, initCartList);
    print("initCartItem $initCartItem");
    if (initCartItem == null) {
      ProductModel initProduct = ProductModel.fromJson(product.toJson());
      CartItem initItem = CartItem(product: initProduct, quantity: 0);
      initCartList.add(initItem);
      initCartItem = initItem;
    }
    //!---
    print("initCartItem $initCartItem");

    //! change Stock
    CartItem cartItem = CartItem(product: product, quantity: 1);
    cartItem.product.stock.value -= 1;
    print('stock addToCart: ${cartItem.product.stock.value}');
    //!---

    //! add product to cart
    editedCart.addItem(cartItem);
    //!---
  }

  void quantityMoveHandle(CartItem cartItem, bool isReturn) {
    //! add product to initCartItem
    var initCartItem = checkExistence(cartItem.product, initCartList);

    if (initCartItem == null) {
      var foundProduct = foundProducts
          .firstWhereOrNull((item) => item.id == cartItem.product.id);
      CartItem initItem = CartItem.fromJson(cartItem.toJson());
      if (foundProduct != null) {
        initItem.product.stock.value = foundProduct.stock.value;
      }
      initCartList.add(initItem);
      initCartItem = initItem;
    }
    //!---

    //! change Quantity
    cartItem.quantityReturn.value += isReturn ? -1 : 1;
    cartItem.quantity.value += isReturn ? 1 : -1;
    //!---

    //! change Stock
    cartItem.product.stock.value += isReturn ? -1 : 1;
    //!---
  }

  //! SELLPRICE ===
  void sellPriceHandle(RxDouble sellPrice, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    sellPrice.value = valueDouble;
    // cart.value.updateDiscount(productId, valueDouble);
  }

  void priceTypeHandleCheckBox(int type) async {
    priceType.value == type ? priceType.value = 1 : priceType.value = type;
    // invoice.priceType.value = priceType.value;
  }

  //! QUANTITY HANDLE ===
  void quantityHandle(CartItem cartItem, String quantity, bool isReturn) {
    //! add product to initCartItem
    var initCartItem = checkExistence(cartItem.product, initCartList);

    if (initCartItem == null) {
      var foundProduct = foundProducts
          .firstWhereOrNull((item) => item.id == cartItem.product.id);
      CartItem initItem = CartItem.fromJson(cartItem.toJson());
      if (foundProduct != null) {
        initItem.product.stock.value = foundProduct.stock.value;
      }
      initCartList.add(initItem);
      initCartItem = initItem;
    }
    //!---

    //! change Quantity
    if (isReturn) {
      cartItem.quantityReturn.value = double.tryParse(quantity) ?? 0;
    } else {
      cartItem.quantity.value = double.tryParse(quantity) ?? 0;
    }
    //!---

    //! change Stock
    cartItem.product.stock.value = initCartItem.product.stock.value +
        (initCartItem.quantity.value - cartItem.quantity.value) +
        (cartItem.quantityReturn.value - initCartItem.quantityReturn.value);
    //!---
  }

  void discountHandle(CartItem cart, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cart.individualDiscount.value = valueDouble;
  }

  //! REMOVE FROM CART ===
  void remove(CartItem cartItem, Cart cart) {
    var foundProduct = foundProducts
        .firstWhereOrNull((item) => item.id == cartItem.product.id);

    if (foundProduct != null) {
      cartItem.product.stock.value = foundProduct.stock.value;
    }

    print(cartItem.product.stock.value);
    cartItem.product.stock.value += cartItem.quantity.value;
    cartItem.product.stock.value -= cartItem.quantityReturn.value;
    print(cartItem.product.stock.value);
    removeCartList.add(cartItem);
    cart.removeItem(cartItem.product.id!);
  }

  //! CLEAR ===
  void clear() {
    initCartList.clear();
    initAdditionalCartList.clear();
    removeCartList.clear();
  }

  bool validateTotal = false;
  Future<void> updateInvoice(InvoiceModel invoice) async {
    invoice.updateIsDebtPaid();
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      var productList = <ProductModel>[];

      for (var purchaseCart in invoice.purchaseList.value.items) {
        if (purchaseCart.product.sold != null) {
          purchaseCart.product.sold!.value =
              purchaseCart.product.sold!.value + purchaseCart.quantity.value;
        } else {
          purchaseCart.product.sold = purchaseCart.quantity;
        }
        print(
            '---stock purchaseCart ${purchaseCart.product.productName} ${purchaseCart.product.stock.value}');
        var updatedProduct = initCartList.firstWhereOrNull(
          (item) => item.product.id == purchaseCart.product.id,
        );
        if (updatedProduct != null) {
          ProductModel product =
              ProductModel.fromJson(purchaseCart.product.toJson());
          productList.add(product);
        }
      }

      if (invoice.returnList.value != null) {
        for (var returnCart in invoice.returnList.value!.items) {
          if (returnCart.product.sold != null) {
            returnCart.product.sold!.value = returnCart.product.sold!.value -
                returnCart.quantityReturn.value;
          } else {
            returnCart.product.sold = returnCart.quantityReturn;
          }
          print('stock returnCart ${returnCart.product.stock.value}');

          var updatedProduct = initAdditionalCartList.firstWhereOrNull(
            (item) => item.product.id == returnCart.product.id,
          );
          if (updatedProduct != null) {
            ProductModel updatedProduct =
                ProductModel.fromJson(returnCart.product.toJson());
            var foundUpdatedProduct = productList
                .firstWhereOrNull((item) => item.id == updatedProduct.id);
            if (foundUpdatedProduct != null) {
              foundUpdatedProduct.stock.value = returnCart.product.stock.value;
            } else {
              productList.add(updatedProduct);
            }
          }
        }
      }

      for (var removedCart in removeCartList) {
        var foundProduct = foundProducts
            .firstWhereOrNull((item) => item.id == removedCart.product.id);

        if (foundProduct != null) {
          if (foundProduct.sold != null) {
            foundProduct.sold!.value -= removedCart.quantity.value;
            foundProduct.sold!.value += removedCart.quantityReturn.value;
          } else {
            foundProduct.sold!.value =
                removedCart.quantity.value + removedCart.quantityReturn.value;
          }
        }

        print('stock removedCart ${removedCart.product.stock.value}');
        ProductModel updatedProduct =
            ProductModel.fromJson(removedCart.product.toJson());
        var foundUpdatedProduct = productList
            .firstWhereOrNull((item) => item.id == updatedProduct.id);
        if (foundUpdatedProduct != null) {
          foundUpdatedProduct.stock.value = removedCart.product.stock.value;
        } else {
          productList.add(updatedProduct);
        }
      }

      await _productService.updateList(productList);

      await _invoiceService.update(invoice);
      print('---selesai updated invoice');
      clear();
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
