import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
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
  void addToCart(ProductModel product) async {
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
    cart.value.addItem(cartItem);
    //!---

    //! change Stock
    product.stock.value += 1;
    print('stock: ${product.stock.value}');
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

  //! QUANTITY HANDLE ===
  void quantityHandle(CartItem cartItem, String quantity) {
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
    cartItem.product.stock.value =
        initCartItem.product.stock.value + cartItem.quantity.value;
    //!---
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

  //! CLEAR ===
  void clear() {
    cart.value.items.clear();
    initCartList.clear();
    removeCartList.clear();
  }
}
