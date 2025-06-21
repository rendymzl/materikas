import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:materikas/infrastructure/utils/display_format.dart';

import '../global_widget/date_picker_widget/date_picker_widget.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/product.controller.dart';
import 'daily_product_sold.dart';
import 'detail_product/detail_product.dart';
import 'product_sold.dart';
import 'structure_page/footer_product_page.dart';
import 'structure_page/header_product_page.dart';
import 'log_stock.dart';
import 'structure_page/body_product_page.dart';
import 'product_list_mobile.dart';

class ProductScreen extends GetView<ProductController> {
  const ProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: vertical ? Colors.white : null,
        appBar: vertical
            ? AppBar(
                title: const Text("Barang"),
                centerTitle: true,
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                actions: [
                  IconButton(
                    onPressed: () async => logStock(
                        await controller.productService.getLogNow(),
                        isNow: true),
                    icon: const Icon(Symbols.today),
                  ),
                  IconButton(
                    onPressed: () async =>
                        logStock(await controller.productService.getLog()),
                    icon: const Icon(Symbols.overview),
                  ),
                ],
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              )
            : null,
        drawer: vertical ? buildDrawer(context) : null,
        body: Column(
          children: [
            if (!vertical) const MenuWidget(title: 'Barang'),
            Expanded(
              child: vertical
                  ? buildMobileLayout(context)
                  : buildDesktopLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk tampilan desktop
  Widget buildDesktopLayout(BuildContext context) {
    return Obx(() => controller.loadingTest.value
        ? const CircularProgressIndicator()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Card(
                    elevation: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeaderProductPage(),
                        Expanded(child: BodyProductPage()),
                        const FooterProductPage(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  // flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.dateIsSelected.value
                                          ? ''
                                          : 'Terjual Hari Ini',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () async => controller
                                              .handleFilteredDate(context),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 100),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Obx(
                                              () => Text(
                                                controller.displayFilteredDate
                                                            .value ==
                                                        ''
                                                    ? 'Pilih Tanggal'
                                                    : controller
                                                        .displayFilteredDate
                                                        .value,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Obx(() => controller
                                                .dateIsSelected.value
                                            ? IconButton(
                                                onPressed: () =>
                                                    controller.clearHandle(),
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red),
                                              )
                                            : const SizedBox.shrink()),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey[300]),
                              Expanded(
                                child: controller.isInitLoading.value
                                    ? Center(child: CircularProgressIndicator())
                                    : !controller.dateIsSelected.value
                                        ? DailyProductSold(
                                            logStock: controller.dailyLogStock)
                                        : ProductSold(
                                            logStock: controller.logStock),
                              )
                            ],
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: Card(
                      //       elevation: 0,
                      //       child: Column(
                      //         children: [
                      //           Row(children: [Text('data')])
                      //         ],
                      //       )),
                      // ),
                      // Expanded(
                      //   child: Card(
                      //       elevation: 0,
                      //       child: Column(
                      //         children: [
                      //           Row(children: [Text('data')])
                      //         ],
                      //       )),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ));
  }

  // Fungsi untuk tampilan mobile
  Widget buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: ProductListMobile()),
          Column(
            children: [
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'Total Barang: ${controller.productsLenght.value}',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                  Obx(
                    () => Text(
                      'Kode Terakhir: ${controller.lastCode.value}',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: () => addFromExcel(),
                  //     child: const Text('Tambah dari Excel'),
                  //   ),
                  // ),
                  // const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => detailProduct(),
                      child: const Text('Tambah Barang'),
                    ),
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
        ],
      ),
    );
  }
}
