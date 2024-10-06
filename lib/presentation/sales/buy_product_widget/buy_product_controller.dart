import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/models/sales_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../controllers/sales.controller.dart';

class BuyProductController extends GetxController {
  late final ProductService productService = Get.find();
  late SalesController salesC = Get.find();
  late InvoiceSalesService invoiceSalesService = Get.find();
  late final AuthService _authService = Get.find<AuthService>();
  late final DatePickerController _datePickerC =
      Get.put(DatePickerController());
  late final foundProducts = productService.foundProducts;
  // Rx<SalesModel?> selectedSales = Rx<SalesModel?>(null);

  late InvoiceSalesModel invoice;
  final cart = Cart(items: <CartItem>[].obs).obs;
  final initCartList = <CartItem>[].obs;
  final removeCartList = <CartItem>[].obs;
  final nomorInvoice = ''.obs;

  late ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    print('on init');
    invoice = await createInvoice();
    super.onInit();
  }

  void filterProducts(String productName) {
    productService.search(productName);
  }

  CartItem? checkExistence(
    ProductModel product,
    List<CartItem> productList,
  ) {
    return productList.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );
  }

  //! DISCOUNT ===
  void discountHandle(String productId, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cart.value.updateDiscount(productId, valueDouble);
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

  //! ADD TO CART ===
  void addToCart(ProductModel product, {bool po = false}) async {
    //! add product to initCartItem
    var initCartItem = checkExistence(product, initCartList);

    if (initCartItem == null) {
      ProductModel initProduct = ProductModel.fromJson(product.toJson());
      CartItem initItem = CartItem(product: initProduct, quantity: 0);
      initCartList.add(initItem);
      initCartItem = initItem;
    }
    //!---

    //! change Stock
    if (!po) {
      product.stock.value += 1;
      print('stock: ${product.stock.value}');
    }
    //!---

    //! add product to cart
    CartItem cartItem = CartItem(product: product, quantity: 1);
    cart.value.addItem(cartItem);
    //!---

    //! auto move
    int index = cart.value.items
        .indexWhere((selectItem) => selectItem.product.id == product.id);

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    });
    //!---
  }

  //! ADD TO CART ===
  void addToCartEdit(ProductModel product, Cart cart, {bool po = false}) async {
    //! add product to initCartItem
    var initCartItem = checkExistence(product, initCartList);

    if (initCartItem == null) {
      ProductModel initProduct = ProductModel.fromJson(product.toJson());
      CartItem initItem = CartItem(product: initProduct, quantity: 0);
      initCartList.add(initItem);
      initCartItem = initItem;
    }
    //!---

    //! change Stock
    if (!po) {
      product.stock.value += 1;
      print('stock: ${product.stock.value}');
    }
    //!---

    //! add product to cart
    CartItem cartItem = CartItem(product: product, quantity: 1);
    cart.addItem(cartItem);
    //!---
  }

  //! QUANTITY HANDLE ===
  void quantityHandle(CartItem cartItem, String quantity, {bool po = false}) {
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
    cartItem.quantity.value = double.tryParse(quantity) ?? 0;
    //!---

    //! change Stock
    if (!po) {
      cartItem.product.stock.value = initCartItem.product.stock.value +
          cartItem.quantity.value -
          initCartItem.quantity.value;
    }
    //!---
    print('-------------${initCartList.length}-------------');
  }

  //! REMOVE FROM CART ===
  void removeFromCart(CartItem cartItem, Cart cart, {bool po = false}) {
    var initCartItem = checkExistence(cartItem.product, initCartList);
    var foundProduct = foundProducts
        .firstWhereOrNull((item) => item.id == cartItem.product.id);

    if (foundProduct != null) {
      cartItem.product.stock.value = foundProduct.stock.value;
      if (initCartItem != null) {
        foundProduct.costPrice = initCartItem.product.costPrice;
        foundProduct.sellPrice1 = initCartItem.product.sellPrice1;
        foundProduct.sellPrice2 = initCartItem.product.sellPrice2;
        foundProduct.sellPrice3 = initCartItem.product.sellPrice3;
      }
    }

    if (!po) cartItem.product.stock.value -= cartItem.quantity.value;
    removeCartList.add(cartItem);
    cart.removeItem(cartItem.product.id!);
    print('=================');
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
      storeId: _authService.account.value!.storeId,
      invoiceId: nomorInvoice.value,
      createdAt: dateTime,
      sales: sales,
      purchaseList: cart.value,
      returnList: Cart(items: <CartItem>[].obs),
      priceType: 1,
      discount: cart.value.totalIndividualDiscount,
      payments: [],
      debtAmount: cart.value.totalCost,
    );

    return invoice;
  }

  destroyHandle(InvoiceSalesModel invoice) async {
    await invoiceSalesService.delete(invoice.id!);
  }

  //! UPDATE ===
  Future<void> updateInvoice(InvoiceSalesModel invoice) async {
    Get.defaultDialog(
      title: 'Menyimpan Invoice...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );
    try {
      var productList = <ProductModel>[];

      for (var purchaseCart in invoice.purchaseList.value.items) {
        var initProduct = initCartList.firstWhereOrNull((item) {
          return item.product.id == purchaseCart.product.id;
        });
        if (initProduct != null) {
          purchaseCart.product.costPrice = initProduct.product.costPrice;
          purchaseCart.product.sellPrice1 = initProduct.product.sellPrice1;
          purchaseCart.product.sellPrice2 = initProduct.product.sellPrice2;
          purchaseCart.product.sellPrice3 = initProduct.product.sellPrice3;

          var updatedProduct = initCartList.firstWhereOrNull(
            (item) => item.product.id == purchaseCart.product.id,
          );
          if (updatedProduct != null) {
            ProductModel updatedProduct =
                ProductModel.fromJson(purchaseCart.product.toJson());
            productList.add(updatedProduct);
          }
        }
      }

      for (var removedCart in removeCartList) {
        print('---------- ${removeCartList.length}');
        var initProduct = initCartList.firstWhereOrNull(
            (item) => item.product.id == removedCart.product.id);
        if (initProduct != null) {
          removedCart.product.costPrice = initProduct.product.costPrice;
          removedCart.product.sellPrice1 = initProduct.product.sellPrice1;
          removedCart.product.sellPrice2 = initProduct.product.sellPrice2;
          removedCart.product.sellPrice3 = initProduct.product.sellPrice3;
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

      await productService.updateList(productList);

      await invoiceSalesService.update(invoice);
      clear();

      Get.back();

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

  //! CLEAR ===
  void clear() async {
    invoice = await createInvoice();
    cart.value.items.clear();

    for (var cart in initCartList) {
      var foundProduct =
          foundProducts.firstWhereOrNull((item) => item.id == cart.product.id);
      foundProduct!.costPrice.value = cart.product.costPrice.value;
      foundProduct.sellPrice1.value = cart.product.sellPrice1.value;
      foundProduct.sellPrice2?.value = cart.product.sellPrice2!.value;
      foundProduct.sellPrice3?.value = cart.product.sellPrice3!.value;
    }
    initCartList.clear();
    removeCartList.clear();
  }
}
