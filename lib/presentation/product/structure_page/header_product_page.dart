import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../controllers/product.controller.dart';
// import '../log_stock.dart';

class HeaderProductPage extends StatelessWidget {
  HeaderProductPage({super.key});

  final ProductController productC = Get.find();

  @override
  Widget build(BuildContext context) {
    productC.scrollC.addListener(productC.onScroll);

    final searchTextC = TextEditingController();
    productC.asignSearchTextC(searchTextC);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchAndAddRow(context, searchTextC),
          ),
          SizedBox(width: 12),
          Container(width: 1, height: 42, color: Colors.grey[300]),
          // IconButton(
          //   onPressed: () async => logStock(
          //       await controller.productService.getLogNow(),
          //       isNow: true),
          //   icon: const Icon(Symbols.today),
          // ),
          SizedBox(width: 12),
          _buildToggleButtons(context),
        ],
      ),
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
              // autofocus: true,
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
        // const SizedBox(width: 12),
        // Container(
        //   height: 48,
        //   width: 48,
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).colorScheme.primary,
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: IconButton(
        //     onPressed: () {
        //       FocusScope.of(context).unfocus();
        //       detailProduct();
        //     },
        //     icon: const Icon(Symbols.add, color: Colors.white),
        //   ),
        // ),
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
}
