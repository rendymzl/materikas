import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../product/controllers/product.controller.dart';
import '../../product/detail_product/detail_product.dart';
import '../../product/detail_product/image_product.dart';

class AddProductListWidget extends StatelessWidget {
  final Function(ProductModel) onClick;
  final Cart? cart;
  final bool isSales;

  AddProductListWidget({
    super.key,
    required this.onClick,
    this.cart,
    this.isSales = false,
  });

  final ProductController productC = Get.find();

  @override
  Widget build(BuildContext context) {
    productC.scrollC.addListener(productC.onScroll);

    final searchTextC = TextEditingController();
    productC.asignSearchTextC(searchTextC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchAndAddRow(context, searchTextC),
        _buildToggleButtons(context),
        Expanded(
          child: _buildProductList(context),
        ),
      ],
    );
  }

  Widget _buildSearchAndAddRow(
      BuildContext context, TextEditingController searchTextC) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: TextField(
              controller: searchTextC,
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Cari Barang",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Symbols.search),
              ),
              onChanged: productC.searchProducts,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              detailProduct();
            },
            icon: const Icon(Symbols.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Obx(() => _buildToggleButton(
                context,
                label: 'Stok',
                isActive: productC.isLowStock.value,
                icon: productC.isLowStock.value
                    ? Symbols.filter_list
                    : Symbols.filter_list_off,
                upsideDown: true,
                onTap: productC.toggleLowStock,
              )),
          const SizedBox(width: 12),
          Obx(() => _buildToggleButton(
                context,
                label: 'Gambar',
                isActive: productC.showImage.value,
                icon: productC.showImage.value
                    ? Symbols.image
                    : Symbols.hide_image,
                onTap: productC.toggleShowImage,
              )),
          // const SizedBox(width: 12),
          // Obx(() => _buildToggleButton(
          //       context,
          //       label: 'Grid',
          //       isActive: productC.isGridLayout.value,
          //       icon: Icons.grid_view,
          //       onTap: productC.toggleGridLayout,
          //     )),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required bool isActive,
    required IconData icon,
    bool upsideDown = false,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? Theme.of(context).colorScheme.primary : Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          upsideDown
              ? Transform.rotate(
                  angle: 3.1416, // 180 derajat dalam radian
                  child:
                      Icon(icon, color: isActive ? Colors.white : Colors.black),
                )
              : Icon(icon, color: isActive ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontSize: 14, // Menambahkan ukuran font
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return Obx(() {
      if (productC.displayedItems.isEmpty) {
        return Text('Barang tidak ditemukan');
      }

      final productList = productC.displayedItems;
      final cartItems = cart?.items;

      if (productC.isLowStock.value) {
        productList.sort((a, b) => (a.finalStock.value - a.stockMin.value)
            .compareTo((b.finalStock.value - b.stockMin.value)));
      }

      return ListView.builder(
        controller: productC.isFiltered() ? productC.scrollC : null,
        itemCount: productList.length + 1,
        itemBuilder: (context, index) {
          if (index == productC.displayedItems.length) {
            if (productC.isLoadingFetch.value) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Center(child: CircularProgressIndicator()),
              );
            } else if (!productC.hasMore.value) {
              return const Center(child: Text("Tidak ada data lagi"));
            } else {
              return const SizedBox.shrink();
            }
          }

          return Obx(() {
            final product = productList[index];
            final cartItem =
                cartItems?.firstWhereOrNull((i) => i.product.id == product.id);
            final price =
                isSales ? product.costPrice.value : product.sellPrice1.value;
            final isLowStock = product.finalStock <= product.stockMin.value;
            final remainingStock = isSales
                ? product.finalStock.value +
                    (cartItem?.quantity.value.toInt() ?? 0)
                : product.finalStock.value -
                    (cartItem?.quantity.value.toInt() ?? 0);
            return _buildProductItem(
                context, product, cartItem, price, isLowStock, remainingStock);
          });
        },
      );
    });
  }

  // Widget _buildGridProductList(BuildContext context) {
  //   return Obx(() {
  //     if (productC.displayedItems.isEmpty) {
  //       return Text('Barang tidak ditemukan');
  //     }

  //     final productList = productC.displayedItems;

  //      final product = productList[index];
  //           final cartItem =
  //               cartItems?.firstWhereOrNull((i) => i.product.id == product.id);
  //           final price =
  //               isSales ? product.costPrice.value : product.sellPrice1.value;
  //           final isLowStock = product.finalStock <= product.stockMin.value;
  //           final remainingStock = isSales
  //               ? product.finalStock.value +
  //                   (cartItem?.quantity.value.toInt() ?? 0)
  //               : product.finalStock.value -
  //                   (cartItem?.quantity.value.toInt() ?? 0);

  //     return GridView.builder(
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2,
  //         childAspectRatio: 0.7, // Mengubah aspect ratio agar lebih kotak
  //         mainAxisSpacing: 8, // Menambahkan jarak antar baris
  //         crossAxisSpacing: 8, // Menambahkan jarak antar kolom
  //       ),
  //       itemCount: productList.length + 1,
  //       itemBuilder: (context, index) {
  //         if (index == productList.length) {
  //           if (productC.isLoadingFetch.value) {
  //             return const Center(child: CircularProgressIndicator());
  //           } else if (!productC.hasMore.value) {
  //             return const Center(child: Text("Tidak ada data lagi"));
  //           } else {
  //             return const SizedBox.shrink();
  //           }
  //         }
  //         final product = productList[index];
  //         return _buildGridItem(
  //             context, product, cartItem, price, isLowStock, remainingStock);
  //       },
  //     );
  //   });
  // }

  // Widget _buildGridItem(
  //   BuildContext context,
  //   ProductModel product,
  //   CartItem? cartItem,
  //   double price,
  //   bool isLowStock,
  //   double remainingStock,
  // ) {
  //   return InkWell(
  //     onTap: () => onClick(product),
  //     child: Card(
  //       color: cartItem != null
  //           ? Colors.green[100]
  //           : isLowStock
  //               ? Colors.red[100]
  //               : null,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10), // Beri border radius
  //       ),
  //       elevation: 2, // Tambahkan elevation untuk shadow
  //       child: Padding(
  //         padding: const EdgeInsets.all(12.0), // Tambahkan padding
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             AspectRatio(
  //               aspectRatio: 1, // Buat aspect ratio 1:1 agar gambar kotak
  //               child: _buildProductImage(context, product),
  //             ),
  //             const SizedBox(height: 8), // Tambahkan jarak
  //             Text(product.productName,
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //                 overflow: TextOverflow.ellipsis,
  //                 maxLines: 1), // Batasi jumlah baris
  //             const SizedBox(height: 4), // Tambahkan jarak
  //             Text('Rp ${currency.format(product.sellPrice1.value)}',
  //                 style:
  //                     const TextStyle(color: Colors.green)), // Ubah warna harga
  //             const SizedBox(height: 4), // Tambahkan jarak
  //             Text('Stok: ${product.finalStock.value}'), // Menampilkan stok
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildProductItem(
      BuildContext context,
      ProductModel product,
      CartItem? cartItem,
      double price,
      bool isLowStock,
      double remainingStock) {
    var isHovered = false.obs;
    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            color: cartItem != null
                ? isHovered.value
                    ? Colors.green[100]
                    : Colors.green[50]
                : isLowStock
                    ? isHovered.value
                        ? Colors.red[100]
                        : Colors.red[50]
                    : isHovered.value
                        ? Colors.grey[200]
                        : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isHovered.value
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
          child: ListTile(
            hoverColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(context, product),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildProductDetails(
                          context, product, price, remainingStock, isLowStock)),
                ],
              ),
            ),
            onTap: () => onClick(product),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, ProductModel product) {
    return Obx(
      () => productC.showImage.value
          ? Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null
                    ? ImageProductWidget(
                        product: product,
                      )
                    : _buildPlaceholderImage(context, product.productName),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, String productName) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          productName.isNotEmpty ? productName[0].toUpperCase() : '',
          style: context.textTheme.headlineSmall!.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    ProductModel product,
    double price,
    double remainingStock,
    bool isLowStock,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.productName,
                style: context.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Expanded(
            //   child: Text(
            //     product.currentStock!.value.toString(),
            //     style: context.textTheme.titleLarge,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSales)
                  Text(
                    'Harga Beli',
                    style: const TextStyle(fontSize: 12),
                  ),
                Text(
                  'Rp ${currency.format(price)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.inventory_2,
              size: 16,
              color: isLowStock ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLowStock
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${number.format(remainingStock)} ${product.unit}',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
