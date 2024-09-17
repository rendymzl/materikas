import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import '../buy_product_widget/cart_sales_widget.dart';
import 'add_product_sales.dart';

class CardListInvoiceSales extends StatelessWidget {
  const CardListInvoiceSales({super.key, required this.editInvoice});

  final InvoiceSalesModel editInvoice;

  @override
  Widget build(BuildContext context) {
    final cart = editInvoice.purchaseList.value;
    final cartItems = editInvoice.purchaseList.value.items;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pembelian',
              style: Theme.of(Get.context!).textTheme.titleLarge,
              textAlign: TextAlign.end,
            ),
            const DatePickerWidget()
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            itemCount: cartItems.length,
            itemBuilder: (BuildContext context, int index) {
              final item = cartItems[index];

              return CartSalesWidget(item: item, index: index, cart: cart);
            },
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () =>
              addProductSalesDialog(editInvoice.purchaseList.value),
          child: const Text(
            'Tambah Barang',
          ),
        ),
      ],
    );
  }
}
