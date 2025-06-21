import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../add_from_excel.dart';
import '../controllers/product.controller.dart';
import '../detail_product/detail_product.dart';
import '../log_stock.dart';

class FooterProductPage extends StatelessWidget {
  const FooterProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();
    final searchTextC = TextEditingController();
    controller.asignSearchTextC(searchTextC);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Obx(
                () => Text(
                  'Total Barang: ${controller.productsLenght.value}',
                  style: context.textTheme.bodySmall,
                ),
              ),
              Text(
                '  |  ',
                style: context.textTheme.bodySmall,
              ),
              Obx(
                () => Text(
                  'Kode Terakhir: ${controller.lastCode.value}',
                  style: context.textTheme.bodySmall,
                ),
              ),
              // Text(
              //   '  |  ',
              //   style: context.textTheme.bodySmall,
              // ),
              // TextButton(
              //   onPressed: () async =>
              //       logStock(await controller.productService.getLog()),
              //   child: Text(
              //     'Perubahan Stok',
              //     style: context.textTheme.bodySmall!
              //         .copyWith(color: Theme.of(context).primaryColor),
              //   ),
              // ),
              // Text(
              //   '  |  ',
              //   style: context.textTheme.bodySmall,
              // ),
              // TextButton(
              //   onPressed: () async => logStock(
              //       await controller.productService.getLogNow(),
              //       isNow: true),
              //   child: Text(
              //     'Terjual hari ini',
              //     style: context.textTheme.bodySmall!
              //         .copyWith(color: Theme.of(context).primaryColor),
              //   ),
              // ),
              // Text(
              //   '  |  ',
              //   style: context.textTheme.bodySmall,
              // ),
              // TextButton(
              //   onPressed: () async => controller.gooooooo(),
              //   child: Text(
              //     'GOOOOOOOOOOOO',
              //     style: context.textTheme.bodySmall!
              //         .copyWith(color: Theme.of(context).primaryColor),
              //   ),
              // ),
              // TextButton(
              //   onPressed: () async => await controller.setStock(),
              //   child: Text(
              //     'updatestock',
              //     style: context.textTheme.bodySmall!
              //         .copyWith(color: Theme.of(context).primaryColor),
              //   ),
              // ),
            ],
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    controller.downloadProductExcel();
                  },
                  child: SizedBox(
                    child: Row(
                      children: [
                        Icon(
                          Symbols.file_save,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Download Excel',
                          style: context.textTheme.bodySmall!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              PopupMenuButton<String>(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.add,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tambah Barang',
                        style: context.textTheme.bodySmall!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onSelected: (String item) {
                  if (item == 'addFromExcel') {
                    addProductFromExcel();
                  } else if (item == 'addProduct') {
                    detailProduct();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'addFromExcel',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Icon(
                                Symbols.upload_file,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tambah dari Excel',
                                style: context.textTheme.bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'addProduct',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          child: Row(
                            children: [
                              Icon(
                                Symbols.add,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tambah Barang',
                                style: context.textTheme.bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
