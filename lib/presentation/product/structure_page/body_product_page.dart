import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../controllers/product.controller.dart';
import '../detail_product/detail_product.dart';
import '../detail_product/image_product.dart';
import '../log_stock.dart';

class BodyProductPage extends StatelessWidget {
  const BodyProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();

    controller.scrollC.addListener(controller.onScroll);

    final searchTextC = TextEditingController();
    controller.asignSearchTextC(searchTextC);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Obx(
        () {
          if (controller.displayedItems.isEmpty) {
            return const Center(
                child: Text("Belum ada barang yang ditambahkan"));
          }
          final productList = controller.displayedItems;

          // if (controller.isLowStock.value) {
          //   productList.sort((a, b) => (a.getPrice(1).value - a.costPrice.value)
          //       .compareTo((a.getPrice(1).value - a.costPrice.value)));
          // }
          if (controller.isLowStock.value) {
            productList.sort((a, b) => (a.finalStock.value - a.stockMin.value)
                .compareTo((b.finalStock.value - b.stockMin.value)));
          }

          return ListView.builder(
            controller: controller.isFiltered() ? controller.scrollC : null,
            itemCount: productList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == controller.displayedItems.length) {
                if (controller.isLoadingFetch.value) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (!controller.hasMore.value) {
                  return const Center(child: Text("Tidak ada data lagi"));
                } else {
                  return const SizedBox.shrink();
                }
              }

              final foundProduct = productList[index];

              return ListTileContent(
                index: index,
                foundProduct: foundProduct,
              );
            },
          );
        },
      ),
    );
  }
}

class ListTileContent extends StatelessWidget {
  const ListTileContent(
      {super.key, required this.foundProduct, required this.index});

  final ProductModel foundProduct;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();

    final isHover = false.obs;
    return MouseRegion(
      onHover: (event) {
        isHover.value = true;
      },
      onExit: (event) {
        isHover.value = false;
      },
      child: Obx(
        () {
          print(foundProduct.stock.value);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              color:
                  foundProduct.finalStock.value <= foundProduct.stockMin.value
                      ? isHover.value
                          ? Colors.red[100]
                          : Colors.red[50]
                      : isHover.value
                          ? Colors.grey[300]
                          : index % 2 == 1
                              ? null
                              : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: isHover.value
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              onTap: () => controller.editProduct.value
                  ? detailProduct(foundProduct: foundProduct)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 30,
                        child: Column(
                          children: [
                            Text('${index + 1}'),
                            // if (foundProduct.barcode != null &&
                            //     foundProduct.barcode!.isNotEmpty)
                            //   Icon(Symbols.barcode)
                          ],
                        )),
                    // Leading (Image or Product ID)
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          Obx(() {
                            var showImage = controller.showImage.value;
                            var imageUrl = foundProduct.imageUrl;
                            print(
                                'debugimageUrl ${foundProduct.imageUrl?.value}');
                            // print(
                            //     'debugimageUrl ${foundProduct.costPrice.value > foundProduct.getPrice(1).value}');
                            return (showImage)
                                ? GestureDetector(
                                    onTap: () {
                                      if (imageUrl != null &&
                                          imageUrl.value.isNotEmpty) {
                                        Get.dialog(
                                          Dialog(
                                            child: Container(
                                              width: 600,
                                              height: 600,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: ImageProductWidget(
                                                product: foundProduct,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: (imageUrl != null &&
                                              imageUrl.value.isNotEmpty)
                                          ? ImageProductWidget(
                                              product: foundProduct,
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  foundProduct.productName
                                                          .isNotEmpty
                                                      ? foundProduct
                                                          .productName[0]
                                                          .toUpperCase()
                                                      : '',
                                                  style: context
                                                      .textTheme.headlineSmall!
                                                      .copyWith(
                                                          color: Colors.white),
                                                ),
                                              ),
                                            ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }),
                          SizedBox(
                            width: 100,
                            child: Text(
                              foundProduct.productId,
                              style: context.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    // Product Details
                    Expanded(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foundProduct.productName,
                                    style: context.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Harga Modal: ',
                                        style: context.textTheme.bodyMedium,
                                      ),
                                      _buildPriceCard(
                                          'Rp. ${currency.format(foundProduct.costPrice.value)}',
                                          Colors.amber[600]!),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async => logStock(
                                        await controller.productService
                                            .getLogByProduct(foundProduct),
                                        isSingle: true),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          number.format(
                                              foundProduct.finalStock.value),
                                          style: context.textTheme.titleMedium!
                                              .copyWith(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                        // const SizedBox(height: 2),
                                        Text(
                                          foundProduct.unit,
                                          style: context.textTheme.labelSmall!
                                              .copyWith(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 1,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Wrap(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('Harga Jual 1: '),
                                    _buildPriceCard(
                                        'Rp. ${currency.format(foundProduct.sellPrice1.value)}',
                                        Colors.green[600]!),
                                  ],
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                  width: 1,
                                  height: 38,
                                  color: Colors.grey[400]),
                              Expanded(
                                child: Wrap(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('Harga Jual 2: '),
                                    _buildPriceCard(
                                        foundProduct.sellPrice2!.value == 0
                                            ? '-'
                                            : 'Rp. ${currency.format(foundProduct.sellPrice2!.value)}',
                                        Colors.green[500]!),
                                  ],
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                  width: 1,
                                  height: 38,
                                  color: Colors.grey[400]),
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Harga Jual 3: '),
                                    _buildPriceCard(
                                        foundProduct.sellPrice3!.value == 0
                                            ? '-'
                                            : 'Rp. ${currency.format(foundProduct.sellPrice3!.value)}',
                                        Colors.green[400]!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceCard(String price, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        price,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
