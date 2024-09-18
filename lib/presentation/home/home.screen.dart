import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import '../global_widget/product_list_widget/product_list_widget.dart';
import 'controllers/home.controller.dart';
import 'selected_product_widget/selected_product.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => controller.focusNode.requestFocus(),
        child: Column(
          children: [
            const MenuWidget(title: 'Transaksi'),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: ProductListWidget(onClick: (product) {
                        controller.addToCart(product);
                      }),
                    ),
                  ),
                  const Expanded(
                      flex: 4, child: Card(child: SelectedProduct())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
