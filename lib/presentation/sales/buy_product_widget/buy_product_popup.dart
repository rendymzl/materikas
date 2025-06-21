import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/product_list_widget/add_product_list_widget.dart';
import '../controllers/sales.controller.dart';
import '../invoice_widget/invoice_sales_header.dart';
import '../selected_product_sales_widget/calculate_sales.dart';
import '../selected_product_sales_widget/cart_sales_Invoice.dart';
import 'buy_product_controller.dart';

Future<void> buyProductPopup() async {
  final SalesController salesC = Get.find();
  final BuyProductController controller = Get.find();

  showPopupPageWidget(
    title: 'Beli Barang: ${salesC.selectedSales.value!.name!}',
    height: MediaQuery.of(Get.context!).size.height * (0.9),
    width: MediaQuery.of(Get.context!).size.width * (0.9),
    content: _buildPopupContent(controller),
  );
}

Widget _buildPopupContent(BuyProductController controller) {
  return Expanded(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftCard(controller),
        _buildRightCard(controller),
      ],
    ),
  );
}

Widget _buildLeftCard(BuyProductController controller) {
  return Expanded(
    flex: 4,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AddProductListWidget(
          onClick: (product) => controller.addToCart(product),
          cart: controller.cart.value,
          isSales: true,
        ),
      ),
    ),
  );
}

Widget _buildRightCard(BuyProductController controller) {
  return Expanded(
    flex: 7,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            Divider(color: Colors.grey[100]),
            _buildBody(),
            _buildFooter(controller),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHeader() {
  return Container(
    height: 50,
    decoration: const BoxDecoration(
      color: Colors.white,
    ),
    child: InvoiceSalesHeader(),
  );
}

Widget _buildBody() {
  return Expanded(child: CartSalesInvoice());
}

Widget _buildFooter(BuyProductController controller) {
  return Obx(
    () {
      return controller.cart.value.items.isNotEmpty
          ? CalculateSalesPrice(
              editableInvoice: controller.editInvoice,
            )
          : const SizedBox();
    },
  );
}
