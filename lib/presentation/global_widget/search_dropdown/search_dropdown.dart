import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../home/controllers/home.controller.dart';
import '../../product/controllers/product.controller.dart';
import '../../product/detail_product/image_product.dart';
import '../field_quantity_widget/field_quantity_widget.dart';

class DropdownSearchProduct extends GetxController {
  final ProductController productC = Get.find();
  late final displayedItems = productC.displayedItems;
  // Daftar item dropdown

  // Item yang dipilih
  // final selectedItem = Rx<Product?>(null);

  // Kontrol pencarian
  final searchQuery = ''.obs;

  // Filter item berdasarkan pencarian
  List<ProductModel> get filteredItems => displayedItems
      .where((item) => item.productName
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase()))
      .toList();

  // Mengubah item yang dipilih
  // void setSelectedItem(ProductModel? value) {
  //   selectedItem.value = value;
  // }

  // Mengubah query pencarian
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
}

class SearchableDropdownProduct extends StatelessWidget {
  final DropdownSearchProduct controller = Get.put(DropdownSearchProduct());

  SearchableDropdownProduct({super.key, this.isSales = false});

  final bool isSales;

  @override
  Widget build(BuildContext context) {
    final HomeController homeC = Get.find();
    final ProductController productC = Get.find();

    final dropDownKey = GlobalKey<DropdownSearchState<PopupMode>>();

    final cartItems = homeC.cart.value.items;

    return Column(
      children: [
        // TextField(
        //   onChanged: controller.setSearchQuery,
        //   decoration: InputDecoration(
        //     labelText: "Cari Barang",
        //     prefixIcon: Icon(Icons.search),
        //     border: OutlineInputBorder(),
        //   ),
        // ),
        DropdownSearch<PopupMode>(
          key: dropDownKey,
          selectedItem: PopupMode.menu,
          itemAsString: (item) => item.name,
          compareFn: (i1, i2) => i1 == i2,
          items: (filter, infiniteScrollProps) => PopupMode.values,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'Examples for: ',
              border: OutlineInputBorder(),
            ),
          ),
          popupProps: PopupProps.menu(
              fit: FlexFit.loose, constraints: BoxConstraints()),
        ),

        SizedBox(height: 16),
        Obx(
          () => DropdownButton<ProductModel>(
            isExpanded: true,
            // value: controller.selectedItem.value,
            hint: Text("Pilih Barang"),
            items: controller.filteredItems.map((item) {
              double getPrice = item.getPrice(1).value;
              double sellPrice =
                  getPrice.toInt() != 0 ? getPrice : item.sellPrice1.value;
              double costPrice = item.costPrice.value;

              var cart =
                  cartItems.firstWhereOrNull((i) => i.product.id == item.id);

              return DropdownMenuItem(
                value: item,
                child: ListTile(
                  leading: productC.showImage.value
                      ? (item.imageUrl != null)
                          ? ImageProductWidget(product: item)
                          : Container(
                              width: 60,
                              height: 60,
                              color: Theme.of(context).primaryColor,
                              child: Center(
                                child: Text(
                                  item.productName.isNotEmpty
                                      ? item.productName[0].toUpperCase()
                                      : '',
                                  style: context.textTheme.headlineSmall!
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            )
                      : null,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName,
                                style: context.textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 12),
                            if (cart != null)
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5))),
                                child: IconButton(
                                  onPressed: () {
                                    homeC.removeFromCart(cart);
                                  },
                                  icon: const Icon(
                                    Symbols.close,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Obx(
                          () => Text(
                            '${number.format((item.stock.value) - (cart?.quantity.value ?? 0))} ${item.unit}',
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${currency.format(isSales ? costPrice : sellPrice)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (cart != null)
                        Row(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    cart.quantity.value > 1
                                        ? Icons.remove
                                        : Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (cart.quantity.value > 1) {
                                      homeC.quantityHandle(
                                        cart,
                                        (cart.quantity.value - 1).toString(),
                                      );
                                    } else {
                                      homeC.removeFromCart(cart);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 85,
                                  child: QuantityTextField(
                                    item: cart,
                                    onChanged: (value) => homeC.quantityHandle(
                                      cart,
                                      value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),

                  // onTap: () {
                  //   onClick(foundProduct);
                  // },
                ),
              );
            }).toList(),

            onChanged: (product) => homeC.addToCart(product!),
          ),
        ),
        // SizedBox(height: 16),
        // Obx(
        //   () => Text(
        //     controller.selectedItem.value != null
        //         ? "Anda memilih: ${controller.selectedItem.value}"
        //         : "Belum ada yang dipilih",
        //     style: TextStyle(fontSize: 18),
        //   ),
        // ),
      ],
    );
  }
}
