import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/sales_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/sales.controller.dart';
import 'detail_sales/detail_sales.dart';
import 'purchase_order_detail.dart';
import 'purchase_order_dialog.dart';

class SalesList extends StatelessWidget {
  final Function(SalesModel) onClick;

  const SalesList({
    super.key,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      decoration: const InputDecoration(
                        labelText: "Cari Sales",
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Symbols.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => controller.filterSales(value),
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
                    onPressed: () => detailSales(),
                    icon: const Icon(
                      Symbols.add,
                      // size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () {
                var sales = controller.foundSales;
                return ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (BuildContext context, int index) {
                    var foundSales = sales[index];
                    // var selectedSales = controller.selectedSales.value;

                    // int getPrice =
                    //     foundSales.getPrice(controller.priceType.value);
                    // int sellPrice = getPrice.toInt() != 0
                    //     ? getPrice
                    //     : foundSales.sellPrice1;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Obx(
                        () => ListTile(
                            selected:
                                foundSales == controller.selectedSales.value,
                            selectedTileColor: Colors.grey[100],
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 240,
                                  child: Text(
                                    foundSales.name!,
                                    style: context.textTheme.titleLarge,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (foundSales.getTotalDebt(
                                        controller.salesInvoices) >
                                    0)
                                  Text(
                                    'Hutang Rp${currency.format(foundSales.getTotalDebt(controller.salesInvoices))}',
                                    style: context.textTheme.bodySmall!
                                        .copyWith(
                                            color: Colors.red,
                                            fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            subtitle: foundSales.phone != null
                                ? Text(
                                    foundSales.phone ?? '',
                                    style: context.textTheme.bodySmall,
                                  )
                                : null,
                            trailing: const Icon(Symbols.arrow_right),
                            onTap: () => onClick(foundSales)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => purchaseOrderDialog(),
            child: const Text('PO Barang'),
          ),
        ],
      ),
    );
  }
}
