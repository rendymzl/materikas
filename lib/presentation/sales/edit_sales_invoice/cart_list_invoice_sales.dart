import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import '../buy_product_widget/cart_sales_mobile.dart';
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller:
                    TextEditingController(text: editInvoice.invoiceName.value),
                onChanged: (value) => editInvoice.invoiceName.value = value,
                decoration: const InputDecoration(labelText: 'ID/Nama Invoice'),
              ),
            ),
            DatePickerWidget(dateTime: editInvoice.createdAt),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Pembelian',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Obx(
          () => ListView.separated(
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.grey),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return vertical
                  ? CartSalesMobile(
                      item: item, index: index, cart: cart, isEdit: true)
                  : CartSalesWidget(item: item, index: index, cart: cart);
            },
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => addProductSalesDialog(editInvoice),
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Tambah Barang'),
            ],
          ),
        ),
      ],
    );
  }
}
