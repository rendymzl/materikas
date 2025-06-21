import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../infrastructure/models/invoice_model/cart_model.dart';

import 'add_product_dialog.dart';
import 'edit_invoice/cart_list.dart';
import 'edit_invoice/edit_invoice_controller.dart';

class CardListWidget extends StatelessWidget {
  const CardListWidget({super.key, this.isReturnPage = false});

  final bool isReturnPage;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();

    if (controller.editInvoice.returnList.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.editInvoice.returnList.value = Cart(items: <CartItem>[].obs);
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  CartList(
                    cartItemList: controller.editInvoice.purchaseList.value,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () => addProductDialog(
            // isPopUp: true,
            isReturnPage
                ? controller.editInvoice.returnList.value!
                : controller.editInvoice.purchaseList.value,
            isReturnPage: isReturnPage,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
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
