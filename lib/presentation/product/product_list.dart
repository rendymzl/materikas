import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/product_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/product.controller.dart';
import 'detail_product/detail_product.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();
    ScrollController scrollC = ScrollController();

    void onScroll() {
      double maxScroll = scrollC.position.maxScrollExtent;
      double currentScroll = scrollC.position.pixels;

      if (maxScroll == currentScroll && controller.hasMore.value) {
        controller.fetch(isClean: true);
      }
    }

    scrollC.addListener(onScroll);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  height: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: "Cari Barang",
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Symbols.search),
                    ),
                    onChanged: (value) => controller.filterProducts(value),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                width: 200,
                child: Obx(
                  () => InkWell(
                    onTap: () => controller.toggleLowStock(),
                    child: SizedBox(
                      child: Row(
                        children: [
                          Checkbox(
                            value: controller.isLowStock.value,
                            onChanged: (value) => controller.toggleLowStock(),
                          ),
                          Text(
                            'Urutkan stok sedikit',
                            style: controller.isLowStock.value
                                ? context.textTheme.bodySmall!.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary)
                                : context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          TableHeader(),
          Divider(color: Colors.grey[500]),
          Expanded(
            child: Obx(
              () {
                if (controller.displayedItems.isEmpty &&
                    controller.isLoading.value) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Tampilkan loading jika pertama kali
                }
                final productList = controller.displayedItems;
                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey[300]),
                  controller: controller.isLowStock.value ? null : scrollC,
                  itemCount: controller.isLowStock.value
                      ? productList.length
                      : productList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == controller.displayedItems.length) {
                      // Indikator loading di bagian bawah
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!controller.hasMore.value) {
                        return const Center(child: Text("Tidak ada data lagi"));
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    final foundProduct = productList[index];

                    return TableContent(foundProduct: foundProduct);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 100,
        child: Text(
          'Kode',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 9,
            child: SizedBox(
              child: Text(
                'Nama Barang',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Modal',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Jual 1',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Jual 2',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Text(
                'Harga Jual 3',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Stok',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: SizedBox(
              child: Text(
                'Min. Stok',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableContent extends StatelessWidget {
  const TableContent({super.key, required this.foundProduct});

  final ProductModel foundProduct;

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find();

    return Obx(
      () => Container(
        color: foundProduct.stock.value < foundProduct.stockMin.value
            ? Colors.red[200]
            : null,
        child: ListTile(
          leading: SizedBox(
            width: 100,
            child: Text(
              foundProduct.productId,
              style: context.textTheme.bodySmall,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                flex: 9,
                child: SizedBox(
                  child: Text(
                    foundProduct.productName,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: SizedBox(
                  child: Text(
                    'Rp. ${currency.format(foundProduct.costPrice.value)}',
                    style: context.textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rp. ${currency.format(foundProduct.sellPrice1.value)}',
                    style: context.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rp. ${currency.format(foundProduct.sellPrice2!.value)}',
                    style: context.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rp. ${currency.format(foundProduct.sellPrice3!.value)}',
                    style: context.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  child: Text(
                    '${number.format(foundProduct.stock.value)} ',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  child: Text(
                    '${number.format(foundProduct.stockMin.value)} ${foundProduct.unit}',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => controller.editProduct.value
              ? detailProduct(foundProduct: foundProduct)
              : null,
        ),
      ),
    );
  }
}
