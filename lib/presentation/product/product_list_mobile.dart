import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/product_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/product.controller.dart';
import 'detail_product/detail_product.dart';
import 'detail_product/image_product.dart';
import 'log_stock.dart';

class ProductListMobile extends StatelessWidget {
  const ProductListMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();
    // ScrollController scrollC = ScrollController();

    // void onScroll() {
    //   double maxScroll = scrollC.position.maxScrollExtent;
    //   double currentScroll = scrollC.position.pixels;

    //   if (maxScroll == currentScroll && controller.hasMore.value) {
    //     controller.fetch();
    //   }
    // }

    // scrollC.addListener(onScroll);

    final searchTextC = TextEditingController();
    controller.asignSearchTextC(searchTextC);

    return Column(
      children: [
        // Search bar
        TextField(
          controller: searchTextC,
          decoration: const InputDecoration(
            labelText: "Cari Barang",
            // labelStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => controller.searchProducts(value),
        ),
        // Checkbox for sorting by low stock
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              //! stock toogle button
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.isLowStock.value
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      controller.toggleLowStock();
                    },
                    child: SizedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_drop_up,
                            color: controller.isLowStock.value
                                ? Colors.white
                                : Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Stok',
                            style: controller.isLowStock.value
                                ? context.textTheme.bodySmall!
                                    .copyWith(color: Colors.white)
                                : context.textTheme.bodySmall!
                                    .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              //! image show toogle button
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.showImage.value
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      controller.toggleShowImage();
                    },
                    child: SizedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            color: controller.showImage.value
                                ? Colors.white
                                : Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Gambar',
                            style: controller.showImage.value
                                ? context.textTheme.bodySmall!
                                    .copyWith(color: Colors.white)
                                : context.textTheme.bodySmall!
                                    .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.grey),
        // Displaying the list of products
        Expanded(
          child: Obx(
            () {
              if (controller.displayedItems.isEmpty) {
                return const Center(
                    child: Text("Belum ada barang yang ditambahkan"));
              }
              final productList = controller.displayedItems;

              if (controller.isLowStock.value) {
                productList.sort((a, b) =>
                    (a.finalStock.value - a.stockMin.value)
                        .compareTo((b.finalStock.value - b.stockMin.value)));
              }

              return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300]),
                controller: controller.isFiltered() ? controller.scrollC : null,
                itemCount: productList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == productList.length) {
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

                  return ProductListItem(foundProduct: foundProduct);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProductListItem extends StatelessWidget {
  const ProductListItem({super.key, required this.foundProduct});

  final ProductModel foundProduct;

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();
    // print(foundProduct.imageUrl);
    return Obx(
      () => Container(
        color: foundProduct.stock.value < foundProduct.stockMin.value
            ? Colors.red[100]
            : null,
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          controller.showImage.value
                              ? Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: (foundProduct.imageUrl != null)
                                      ? ImageProductWidget(
                                          product: foundProduct,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              foundProduct
                                                      .productName.isNotEmpty
                                                  ? foundProduct.productName[0]
                                                      .toUpperCase()
                                                  : '',
                                              style: context
                                                  .textTheme.headlineSmall!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                          ),
                                        ),
                                )
                              : SizedBox(),
                        ],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foundProduct.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleMedium,
                            ),
                            Text(
                              'Kode: ${foundProduct.productId}',
                              style: context.textTheme.bodySmall,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Modal: Rp ${currency.format(foundProduct.costPrice.value)}',
                                  style: context.textTheme.bodySmall,
                                ),
                                InkWell(
                                  onTap: () async => logStock(
                                      foundProduct.logStock!,
                                      isSingle: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Stok: ${number.format(foundProduct.finalStock.value)}',
                                      style: context.textTheme.bodySmall!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PriceTag(
                        price: foundProduct.sellPrice1.value,
                        color: Colors.green[700],
                        index: 0,
                      ),
                      _PriceTag(
                        price: foundProduct.sellPrice2!.value,
                        color: Colors.green[500],
                        index: 1,
                      ),
                      _PriceTag(
                        price: foundProduct.sellPrice3!.value,
                        color: Colors.green[300],
                        index: 2,
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => controller.editProduct.value
                  ? detailProduct(foundProduct: foundProduct)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  final double price;
  final Color? color;
  final int index;

  const _PriceTag({
    required this.price,
    this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Rp. ${currency.format(price)}',
            style: context.textTheme.bodySmall!.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Harga Jual ${index + 1}',
          style: context.textTheme.bodySmall!,
        ),
      ],
    );
  }
}
