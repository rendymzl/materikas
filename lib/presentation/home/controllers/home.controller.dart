import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/customer_model.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/menu_widget/menu_controller.dart';

class HomeController extends GetxController {
  late final ProductService _productService = Get.find<ProductService>();
  late final AuthService _authService = Get.find<AuthService>();
  late final InvoiceService _invoiceService = Get.put(InvoiceService());
  late final DatePickerController _datePickerC =
      Get.put(DatePickerController());
  late final CustomerInputFieldController _customerInputFieldC =
      Get.put(CustomerInputFieldController());
  final MenuWidgetController _menuC = Get.put(MenuWidgetController());

  late final products = _productService.products;
  late final foundProducts = _productService.foundProducts;

  late InvoiceModel invoice;
  final cart = Cart(items: <CartItem>[].obs).obs;
  final initCartList = <CartItem>[].obs;

  final priceType = 1.obs;

  late ScrollController scrollController = ScrollController();

  final FocusNode focusNode = FocusNode();

  @override
  void onInit() async {
    _menuC.selectedIndex.value = 0;
    _menuC.getMenu();
    invoice = await createInvoice();
    print(_authService.selectedUser.value);
    super.onInit();
  }

  @override
  void onClose() {
    for (var cartItem in initCartList) {
      var product = products.firstWhereOrNull(
        (p) => p.id == cartItem.product.id,
      );
      if (product != null) {
        product.stock.value = cartItem.product.stock.value;
        product.sellPrice1 = cartItem.product.sellPrice1;
        product.sellPrice2 = cartItem.product.sellPrice2;
        product.sellPrice3 = cartItem.product.sellPrice3;
      }
    }
    super.onClose();
  }

  void priceTypeHandleCheckBox(int type) async {
    priceType.value == type ? priceType.value = 1 : priceType.value = type;
    invoice.priceType.value = priceType.value;
  }

  CartItem? checkExistence(
    ProductModel product,
    List<CartItem> productList,
  ) {
    return productList.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );
  }

  //! SCAN HANDLE ===
  var scannedData = ''.obs; // Observable untuk menyimpan hasil scan

  // Fungsi untuk memproses input dari scanner
  void processBarcode(String barcode) {
    print('Memproses barcode: $barcode');
    scannedData.value = barcode; // Update UI dengan hasil scan
    var product =
        foundProducts.firstWhereOrNull((product) => product.barcode == barcode);
    if (product != null) {
      addToCart(product);
    }
  }

  // Reset data setelah diproses
  void resetScannedData() {
    scannedData.value = '';
  }

  void handleKeyPress(KeyEvent event) {
    // Cek apakah key event merupakan input karakter
    if (event is KeyDownEvent) {
      final String key = event.logicalKey.keyLabel;

      // Jika key adalah Enter, kita anggap selesai menerima input barcode
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        processBarcode(scannedData.value);
        resetScannedData();
      } else {
        // Jika bukan Enter, tambahkan ke scannedData
        scannedData.value += key;
      }
    }
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
    product.stock.value -= 1;
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
        initCartItem.product.stock.value - cartItem.quantity.value;
    //!---
  }

  //! REMOVE FROM CART ===
  void removeFromCart(CartItem cartItem) {
    var foundProduct = foundProducts
        .firstWhereOrNull((item) => item.id == cartItem.product.id);
    foundProduct!.stock.value += cartItem.quantity.value;
    cart.value.removeItem(cartItem.product.id!);
  }

  //! DISCOUNT ===
  void discountHandle(String productId, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    cart.value.updateDiscount(productId, valueDouble);
  }

  //! SELLPRICE ===
  void sellPriceHandle(RxDouble sellPrice, String value) {
    double valueDouble = value == '' ? 0 : double.parse(value);
    sellPrice.value = valueDouble;
    // cart.value.updateDiscount(productId, valueDouble);
  }

  Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);
  late final invoices = _invoiceService.invoices;

  final selectedTime = TimeOfDay.now().obs;
  final selectedDate = DateTime.now().obs;

  //! CREATE INVOICE ===
  Future<InvoiceModel> createInvoice() async {
    late final CustomerModel customer;
    selectedTime.value = TimeOfDay.now();
    DateTime dateTime = DateTime(
      _datePickerC.selectedDate.value.year,
      _datePickerC.selectedDate.value.month,
      _datePickerC.selectedDate.value.day,
      selectedTime.value.hour,
      selectedTime.value.minute,
    );

    if (selectedCustomer.value != null) {
      customer = CustomerModel(
        id: selectedCustomer.value!.id,
        customerId: selectedCustomer.value!.customerId,
        name: selectedCustomer.value!.name,
        phone: selectedCustomer.value!.phone,
        address: selectedCustomer.value!.address,
      );
    } else {
      customer = CustomerModel(
        name: _customerInputFieldC.customerNameController.text,
        phone: _customerInputFieldC.customerPhoneController.text,
        address: _customerInputFieldC.customerAddressController.text,
      );
    }

    final invoice = InvoiceModel(
      storeId: _authService.account.value!.storeId,
      account: _authService.account.value!,
      createdAt: dateTime,
      customer: customer,
      purchaseList: cart.value,
      returnList: Cart(items: <CartItem>[].obs),
      priceType: priceType.value,
      discount: cart.value.totalIndividualDiscount,
      payments: [],
      debtAmount: cart.value.getTotalBill(priceType.value),
    );

    return invoice;
  }

  void resetData() {
    cart.value.items.clear();
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
  }
}
