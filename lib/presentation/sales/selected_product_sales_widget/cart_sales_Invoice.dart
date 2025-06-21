import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../buy_product_widget/cart_sales_mobile.dart';
import '../views/search_product_sales_view.dart';

class CartSalesInvoice extends StatelessWidget {
  final InvoiceSalesModel? invoiceSales;

  const CartSalesInvoice({super.key, this.invoiceSales});

  @override
  Widget build(BuildContext context) {
    late BuyProductController controller = Get.find();

    return Obx(
      () {
        if (invoiceSales != null) {
          controller.cart.value = invoiceSales!.purchaseList.value;
        }
        final cart = controller.cart.value;
        final cartItems = controller.cart.value.items;
        return ListView.builder(
          shrinkWrap: true,
          controller: controller.scrollController,
          itemCount: cartItems.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < cartItems.length) {
              final item = cartItems[index];

              return CartSalesMobile(item: item, index: index, cart: cart);
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: InkWell(
                  onTap: vertical
                      ? () => Get.to(
                            () => SearchProductSalesView(),
                            transition: Transition.fadeIn,
                          )
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vertical
                            ? 'Tambah barang'
                            : cartItems.isEmpty
                                ? 'Barang yang Anda klik akan ditampilkan di sini.'
                                : '',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                      if (vertical)
                        IconButton(
                            icon: Icon(Symbols.add),
                            color: Theme.of(context).primaryColor,
                            onPressed: () => Get.to(
                                  () => SearchProductSalesView(),
                                  transition: Transition.fadeIn,
                                ))
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
