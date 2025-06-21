import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

// import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../controllers/sales.controller.dart';
import '../selected_product_sales_widget/calculate_sales.dart';
import '../selected_product_sales_widget/cart_sales_Invoice.dart';

class BuyProductView extends GetView {
  const BuyProductView({super.key});
  @override
  Widget build(BuildContext context) {
    final BuyProductController controller = Get.put(BuyProductController());
    final SalesController salesC = Get.find();

    controller.nomorInvoice.value = '';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back),
            onPressed: () {
              for (var cartItem in controller.initCartList) {
                var product = controller.foundProducts.firstWhereOrNull(
                  (p) => p.id == cartItem.product.id,
                );
                if (product != null) {
                  product.stock.value = cartItem.product.stock.value;
                }
              }
              Get.back();
            },
          ),
          title: Text('Beli Barang dari: ${salesC.selectedSales.value!.name!}'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                // height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: HeaderSelectedProductSales(),
              ),
            ),
            // SizedBox(height: 4),
            Divider(color: Colors.grey[100]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CartSalesInvoice(),
              ),
            ),
            Obx(
              () {
                return controller.cart.value.items.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: CalculateSalesPrice(
                            editableInvoice: controller.editInvoice),
                      )
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderSelectedProductSales extends StatelessWidget {
  const HeaderSelectedProductSales({super.key});
  // final bool po;
  // final PurchaseOrderModel? purchaseOrder;

  @override
  Widget build(BuildContext context) {
    late BuyProductController controller = Get.find();
    // late SalesController salesC = Get.find();
    var textIdC = TextEditingController();

    // if (controller.isPurchaseOrder != null) {
    //   textIdC.text = purchaseOrder!.orderId!;
    //   controller.nomorInvoice.value = purchaseOrder!.orderId!;
    //   salesC.salesTextC.text = purchaseOrder!.sales.value!.name!;
    //   Future.delayed(Duration.zero, () async {
    //     salesC.selectedSales.value = purchaseOrder!.sales.value;
    //   });
    //   // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   //   salesC.selectedSales.value = purchaseOrder!.sales.value;
    //   // });
    // }

    return Obx(
      () => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextField(
                    controller: textIdC,
                    decoration: InputDecoration(
                      labelText: controller.isPurchaseOrder.value
                          ? "ID Purchase Order"
                          : "ID/Nama Invoice",
                      prefixIcon: const Icon(Symbols.numbers),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.nomorInvoice.value = value,
                  ),
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilterChip(
                label: Text('Pesanan PO',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                selected: controller.isPurchaseOrder.value,
                onSelected: (selected) => controller.purchaseOrderHandle(),
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2)),
              ),
              SizedBox(width: 16),
              DatePickerWidget(dateTime: controller.createdAt),
            ],
          ),
          // SizedBox(width: 16),
          // const SizedBox(height: 4),
        ],
      ),
    );
  }
}
