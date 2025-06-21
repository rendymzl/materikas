import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../modules/home/views/search_product_home_view.dart';
import '../controllers/home.controller.dart';
import '../../global_widget/invoice_widget/transaction/calculate_price.dart';
import '../../global_widget/invoice_widget/transaction/cartlist_transaction_widget.dart';

class HomeVerticalLayout extends StatelessWidget {
  final HomeController controller;

  const HomeVerticalLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchAndScanRow(context),
          // const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          _buildCartList(),
          const SizedBox(height: 4),
          // const Divider(color: Colors.grey),
          Obx(() => controller.cart.value.items.isNotEmpty
              ? CalculatePrice(editableInvoice: controller.invoice)
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildSearchAndScanRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            onTap: () => Get.to(() => SearchProductHomeView(),
                transition: Transition.fadeIn),
            decoration: const InputDecoration(
              hintText: "Cari Barang",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: IconButton(
            onPressed: controller.scanBarcode,
            icon: const Icon(
              Symbols.barcode_scanner,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartList() {
    return Obx(() => controller.cart.value.items.isNotEmpty
        ? const Expanded(flex: 10, child: CartListTransactionWidget())
        : const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Cari barang untuk di tambahkan.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ));
  }
}
