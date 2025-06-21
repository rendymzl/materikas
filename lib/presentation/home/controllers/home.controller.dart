import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../product/controllers/product.controller.dart';

class HomeController extends GetxController {
  final isLoading = false.obs;
  final AuthService authService = Get.find();
  late final token = Rx<int?>(authService.account.value?.token);

  late final productC = Get.put(ProductController());
  late final RxList<ProductModel> displayedItems;

  late InvoiceModel invoice;
  late final focusNode = FocusNode();
  late final scrollController = ScrollController();

  final showWarningSubs = false.obs;
  final showPopupSubs = false.obs;
  bool isCreatedAtCustom = false;
  bool fromAuto = false;
  final createdAt = DateTime.now().obs;

  final cart = Cart(items: <CartItem>[].obs).obs;

  final scannedData = ''.obs;

  @override
  void onInit() async {
    debugPrint('HomeController INIT');
    isLoading(true);
    showWarningSubs.value = authService.account.value!.endDate != null &&
        DateTime.now()
            .add(const Duration(days: 7))
            .isAfter(authService.account.value!.endDate!);

    showPopupSubs.value = authService.account.value!.endDate != null &&
        DateTime.now().isAfter(
            authService.account.value!.endDate!.add(const Duration(days: 1)));

    // print('awdawdwad enddate ${authService.account.value!.endDate!}');
    print(
        'awdawdwad3 day before ${DateTime.now().subtract(const Duration(days: 3))}');
    print('awdawdwad3 now ${DateTime.now()}');
    print('awdawdwad ${showPopupSubs.value}');
    invoice = await createInvoice();
    displayedItems = productC.displayedItems;
    // _startTimer();
    // ever(createdAt, (_) {
    //   if (fromAuto || !isCreatedAtCustom) {
    //     if (!fromAuto) {
    //       isCreatedAtCustom = true;
    //     }
    //     fromAuto = false;
    //   }
    // });
    isLoading(false);
    debugPrint('HomeController INIT FINISH');
    super.onInit();
  }

  void addToCart(ProductModel product) {
    cart.value.addItem(product);
    if (!vertical) {
      final index = cart.value.items
          .indexWhere((selectItem) => selectItem.product.id == product.id);
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          index * 80.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void sellPriceHandle(RxDouble sellPrice, String value) {
    final valueDouble = value.isEmpty ? 0 : double.parse(value);
    sellPrice.value = valueDouble.toDouble();
  }

  void quantityHandle(CartItem cartItem, String quantity) {
    cart.value
        .updateQuantity(cartItem.product.id!, double.tryParse(quantity) ?? 0);
  }

  void discountHandle(String id, String value) {
    final valueDouble = value.isEmpty ? 0 : double.parse(value);
    cart.value.updateDiscount(id, valueDouble.toDouble());
  }

  void removeFromCart(CartItem cartItem) {
    cart.value.removeItem(cartItem.product.id!);
  }

  void handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        processBarcode(scannedData.value);
        resetScannedData();
      } else {
        scannedData.value += key;
      }
    }
  }

  Future<void> scanBarcode() async {
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Batal',
      true,
      ScanMode.BARCODE,
    );
    if (barcode != '-1') {
      processBarcode(barcode);
      resetScannedData();
    }
  }

  void processBarcode(String barcode) {
    scannedData.value = barcode;
    final product = displayedItems
        .firstWhereOrNull((product) => product.barcode == barcode);
    if (product != null) {
      addToCart(product);
    }
  }

  void resetScannedData() => scannedData.value = '';

  Future<InvoiceModel> createInvoice() async {
    return InvoiceModel(
      storeId: authService.account.value!.storeId,
      account: authService.account.value!,
      createdAt: createdAt.value,
      customer: null,
      purchaseList: cart.value,
      returnList: Cart(items: <CartItem>[].obs),
      priceType: 1,
      discount: cart.value.totalIndividualDiscount,
      payments: [],
      debtAmount: 0,
    );
  }

  Future<void> resetData() async {
    cart.value.items.clear();
    createdAt.value = DateTime.now();
    isCreatedAtCustom = false;
    invoice = await createInvoice();
  }

  // Timer? _timer;
  // void _startTimer() {
  //   _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
  //     if (!isCreatedAtCustom) {
  //       fromAuto = true;
  //       isCreatedAtCustom = false;
  //       createdAt.value = DateTime.now();
  //     } else {
  //       _stopTimer();
  //     }
  //   });
  // }

  // void _stopTimer() {
  //   _timer?.cancel();
  // }

  // @override
  // void onClose() {
  //   _stopTimer();
  //   super.onClose();
  // }
}
