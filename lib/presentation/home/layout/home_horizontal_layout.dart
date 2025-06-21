import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../global_widget/invoice_widget/price_type_header_horizontal.dart';
import '../../global_widget/product_list_widget/add_product_list_widget.dart';
import '../controllers/home.controller.dart';
import '../../global_widget/invoice_widget/transaction/calculate_price.dart';
import '../../global_widget/invoice_widget/transaction/cartlist_transaction_widget.dart';

class HomeHorizontalLayout extends StatelessWidget {
  final HomeController controller;

  const HomeHorizontalLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLeftCard(),
          _buildRightCard(),
          _buildScanDetector(),
        ],
      ),
    );
  }

  Widget _buildLeftCard() {
    return Expanded(
      flex: 2,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AddProductListWidget(
              onClick: controller.addToCart, cart: controller.cart.value),
        ),
      ),
    );
  }

  Widget _buildRightCard() {
    return Expanded(
      flex: 3,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              Divider(color: Colors.grey[300]),
              _buildBody(),
              Divider(color: Colors.grey[300]),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return HorizontalPriceTypeView(
      priceType: controller.invoice.priceType,
      datetime: controller.createdAt,
    );
  }

  Widget _buildBody() {
    return Obx(() => controller.cart.value.items.isNotEmpty
        ? const Expanded(flex: 10, child: CartListTransactionWidget())
        : const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Barang yang Anda klik akan ditampilkan di sini.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ));
  }

  Widget _buildFooter() {
    return Obx(() => controller.cart.value.items.isNotEmpty
        ? CalculatePrice(editableInvoice: controller.invoice)
        : const SizedBox());
  }

  Widget _buildScanDetector() {
    return SizedBox(
      height: 1,
      width: 1,
      child: KeyboardListener(
        focusNode: controller.focusNode,
        autofocus: true,
        onKeyEvent: controller.handleKeyPress,
        child: const SizedBox(),
      ),
    );
  }
}
