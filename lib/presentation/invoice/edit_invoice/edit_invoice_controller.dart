import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  final initCartList = <CartItem>[].obs;
  final initAdditionalCartList = <CartItem>[].obs;
  final removeCartList = <CartItem>[].obs;

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

    //! add product to cart
    CartItem cartItem =
        CartItem(product: product, quantity: 0, quantityReturn: 1);
    cart.addReturnItem(cartItem);
    //!---

    //! change Stock
    cartItem.product.stock.value += 1;
    print('stock: ${cartItem.product.stock.value}');
    //!---
  }

  void addToCart(ProductModel product, Cart cart, {bool isReturn = false}) {
    //! add product to initCartItem
    var initCartItem = checkExistence(product, initCartList);

    if (initCartItem == null) {
      ProductModel initProduct = ProductModel.fromJson(product.toJson());
      CartItem initItem = CartItem(product: initProduct, quantity: 0);
      initCartList.add(initItem);
      initCartItem = initItem;
    }
    //!---

    //! add product to cart
    CartItem cartItem = CartItem(product: product, quantity: 1);
    cart.addItem(cartItem);
    //!---

    //! change Stock
    cartItem.product.stock.value -= 1;
    print('stock addToCart: ${cartItem.product.stock.value}');
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
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
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

      for (var updatedReturnCart in invoice.returnList.value!.items) {
        if (updatedReturnCart.product.sold != null) {
          updatedReturnCart.product.sold!.value =
              updatedReturnCart.product.sold!.value -
                  updatedReturnCart.quantityReturn.value;
        } else {
          updatedReturnCart.product.sold = updatedReturnCart.quantityReturn;
        }
        print(
            'stock updatedReturnCart ${updatedReturnCart.product.stock.value}');
        ProductModel updatedProduct =
            ProductModel.fromJson(updatedReturnCart.product.toJson());
        var foundUpdatedProduct = productList
            .firstWhereOrNull((item) => item.id == updatedProduct.id);
        if (foundUpdatedProduct != null) {
          foundUpdatedProduct.stock.value =
              updatedReturnCart.product.stock.value;
        } else {
          productList.add(updatedProduct);
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
