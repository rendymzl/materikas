import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/sales_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/sales.controller.dart';
import 'detail_sales/detail_sales.dart';

class SalesListWidget extends StatelessWidget {
  final Function(SalesModel) onSalesTap;

  const SalesListWidget({super.key, required this.onSalesTap});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSearchBar(controller),
          Expanded(child: _buildSalesList(controller)),
          // _buildAddSalesButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SalesController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: "Cari Sales",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.filterSales,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => detailSales(isMobile: vertical),
              icon: const Icon(Symbols.add_business, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(SalesController controller) {
    return Obx(() {
      final sales = controller.foundSales;
      return ListView.separated(
        itemCount: sales.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final salesData = sales[index];
          return _buildSalesListTile(context, index, salesData, controller);
        },
      );
    });
  }

  Widget _buildSalesListTile(BuildContext context, int index,
      SalesModel salesData, SalesController controller) {
    return Obx(
      () => ListTile(
        tileColor: (index % 2 == 0) ? Colors.grey[100] : Colors.white,
        selected: salesData.id == controller.selectedSales.value?.id,
        leading: const Icon(Symbols.store, size: 32),
        selectedTileColor: Colors.blueGrey[100]!,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                salesData.name!,
                style: context.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => detailSales(selectedSales: salesData),
                  icon: const Icon(Symbols.edit_square),
                ),
                const Icon(Symbols.arrow_right),
              ],
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              salesData.phone ?? '',
              style: context.textTheme.bodySmall,
            ),
            if (salesData.getTotalDebt(controller.salesInvoices) > 0)
              _buildDebtIndicator(context, salesData, controller),
          ],
        ),
        onTap: () => onSalesTap(salesData),
      ),
    );
  }

  Widget _buildDebtIndicator(
      BuildContext context, SalesModel salesData, SalesController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        'Hutang: Rp${currency.format(salesData.getTotalDebt(controller.salesInvoices))}',
        style: context.textTheme.bodySmall!
            .copyWith(color: Colors.white, fontStyle: FontStyle.italic),
      ),
    );
  }

  // Widget _buildAddSalesButton(BuildContext context) {
  //   return ElevatedButton.icon(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Theme.of(context).colorScheme.primary,
  //     ),
  //     onPressed: () => detailSales(isMobile: vertical),
  //     label: const Text('Tambah Sales', style: TextStyle(fontSize: 16)),
  //     icon: const Icon(Symbols.add, color: Colors.white),
  //   );
  // }
}
