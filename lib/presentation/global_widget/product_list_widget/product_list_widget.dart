import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../product/controllers/product.controller.dart';
import '../../product/detail_product/detail_product.dart';
// import 'product_list_widget_controller.dart';

class ProductListWidget extends StatelessWidget {
  final Function(ProductModel) onClick;
  final bool isSales;
  final bool isPopUp;
  final bool po;

  const ProductListWidget({
    super.key,
    required this.onClick,
    this.isSales = false,
    this.isPopUp = false,
    this.po = false,
  });

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(ProductListWidgetController());
    final ProductController controller = Get.put(ProductController());

    ScrollController scrollC = ScrollController();

    void onScroll() {
      double maxScroll = scrollC.position.maxScrollExtent;
      double currentScroll = scrollC.position.pixels;
      print('maxScroll $maxScroll');
      print('currentScroll $currentScroll');

      if (maxScroll == currentScroll && controller.hasMore.value) {
        controller.fetch();
      }
    }

    scrollC.addListener(onScroll);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    height: 50,
                    child: TextField(
                      // focusNode: controller.focusNode,
                      // controller: controller.serchController,
                      // autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Cari Barang",
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Symbols.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => controller.filterProducts(value),
                      // onSubmitted: (value) {
                      //   controller.scanBarcode(value);
                      // },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: IconButton(
                    onPressed: () => detailProduct(isPopUp: isPopUp),
                    icon: const Icon(
                      Symbols.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
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
                                color: Theme.of(context).colorScheme.primary)
                            : context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (controller.displayedItems.isEmpty &&
                    controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final productList = controller.displayedItems;

                return ListView.builder(
                  controller: scrollC,
                  itemCount: productList.length,
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
                    double getPrice = foundProduct.getPrice(1).value;
                    double sellPrice = getPrice.toInt() != 0
                        ? getPrice
                        : foundProduct.sellPrice1.value;
                    double costPrice = foundProduct.costPrice.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Container(
                        color: foundProduct.stock.value <
                                foundProduct.stockMin.value
                            ? Colors.red[200]
                            : null,
                        child: ListTile(
                            leading: SizedBox(
                              width: 80,
                              child: Obx(
                                () => Text(
                                  '${number.format(foundProduct.stock.value)} ${foundProduct.unit}',
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ),
                            title: Text(
                              foundProduct.productName,
                              style: context.textTheme.titleLarge,
                            ),
                            trailing: Text(
                              'Rp ${currency.format(isSales ? costPrice : sellPrice)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () => onClick(foundProduct)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
