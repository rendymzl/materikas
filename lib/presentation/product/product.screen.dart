import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'add_from_excel.dart';
import 'controllers/product.controller.dart';
import 'detail_product/detail_product.dart';
import 'product_list.dart';

class ProductScreen extends GetView<ProductController> {
  const ProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MenuWidget(title: 'Barang'),
          Expanded(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: ProductList()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Row(
                              children: [
                                Text(
                                  'Total Barang: ${controller.productsLenght.toString()}',
                                  style: context.textTheme.bodySmall,
                                ),
                                Text(
                                  '  |  ',
                                  style: context.textTheme.bodySmall,
                                ),
                                Text(
                                  'Kode Terakhir: ${controller.lastCode.toString()}',
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            )),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => addFromExcel(),
                              child: const Text('Tambah dari Excel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => detailProduct(),
                              child: const Text('Tambah Barang'),
                            ),
                            // const SizedBox(width: 8),
                            // ElevatedButton(
                            //   onPressed: () => controller.exportHandle(),
                            //   child: const Text('Export Data barang'),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
