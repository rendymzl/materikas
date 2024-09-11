import 'package:get/get.dart';

import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../global_widget/payment_widget/payment_widget_controller.dart';

class EditInvoiceController extends GetxController {
  late final PaymentController paymentC = Get.put(PaymentController());
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
    print('stock: ${cartItem.product.stock.value}');
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

  //! UPDATE INVOICE ===
  void saveInvoice(InvoiceModel editInvoice) async {
    await paymentC.saveInvoice(editInvoice);
  }

  //! REMOVE FROM CART ===
  void remove(CartItem cartItem, Cart cart) {
    removeCartList.assign(cartItem);
    cart.removeItem(cartItem.product.id!);
  }

  //! CLEAR ===
  void clear() {
    initCartList.clear();
    initAdditionalCartList.clear();
    removeCartList.clear();
  }
}
