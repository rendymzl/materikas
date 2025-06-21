import 'package:flutter/material.dart';

import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../controllers/sales.controller.dart';
import '../detail_sales/detail_sales.dart';

class InvoiceSalesListView extends GetView {
  const InvoiceSalesListView({super.key});
  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Symbols.store),
                SizedBox(width: 8),
                Text(controller.selectedSales.value!.name!),
                Spacer(),
                PopupMenuButton<String>(
                  onSelected: (String item) {
                    if (item == 'edit') {
                      detailSales(
                          isMobile: true,
                          selectedSales: controller.selectedSales.value);
                    } else if (item == 'delete') {
                      controller.destroyHandle(controller.selectedSales.value!);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Sales'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Hapus Sales'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.invoiceSearchC,
                        decoration: const InputDecoration(
                          labelText: "Cari Invoice",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            controller.filterSalesInvoice(value),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),
                // Filter Lunas dan Piutang dengan checkbox
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Checkbox Lunas
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.checkBoxHandle('paid'),
                          child: Container(
                            // padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: controller
                                              .selectedFilterCheckBox.value ==
                                          'paid'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: controller.selectedFilterCheckBox.value ==
                                      'paid'
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value:
                                      controller.selectedFilterCheckBox.value ==
                                          'paid',
                                  onChanged: (value) =>
                                      controller.checkBoxHandle('paid'),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                Text(
                                  'Lunas',
                                  style: TextStyle(
                                      color: controller.selectedFilterCheckBox
                                                  .value ==
                                              'paid'
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Checkbox Piutang
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.checkBoxHandle('debt'),
                          child: Container(
                            // padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: controller
                                              .selectedFilterCheckBox.value ==
                                          'debt'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: controller.selectedFilterCheckBox.value ==
                                      'debt'
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value:
                                      controller.selectedFilterCheckBox.value ==
                                          'debt',
                                  onChanged: (value) =>
                                      controller.checkBoxHandle('debt'),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                Text(
                                  'Piutang',
                                  style: TextStyle(
                                      color: controller.selectedFilterCheckBox
                                                  .value ==
                                              'debt'
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                // Header untuk List Invoice
                // const HeaderWidget(),
                // List invoice menggunakan BuildListTile
                const Expanded(child: BuildListTile()),
                const Divider(color: Colors.grey),
                // const SizedBox(height: 12),
                // Footer dengan total invoice dan tombol aksi
                Container(
                  color: Colors.white,
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menampilkan jumlah total invoice
                      Obx(
                        () => Text(
                          controller.selectedSales.value != null
                              ? 'Total Invoice ${controller.invoiceById.length}'
                              : '',
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          // Tombol Beli Barang
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.put(BuyProductController()).init();
                                Get.toNamed(Routes.INVOICE_BUY_PRODUCT);
                              },
                              child: const Text('Beli Barang'),
                            ),
                          ),
                          // const SizedBox(width: 12),
                          // Tombol Edit Sales
                          // Expanded(
                          //   child: ElevatedButton(
                          //     onPressed: () => detailSales(
                          //         isMobile: true,
                          //         selectedSales:
                          //             controller.selectedSales.value),
                          //     child: const Text('Edit Sales'),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const ListTile(
        title: Row(
          children: [
            Expanded(child: Text('No')),
            Expanded(flex: 3, child: Text('Invoice')),
            Expanded(
                flex: 4,
                child: Text('Total tagihan', textAlign: TextAlign.end)),
            Expanded(
                flex: 4, child: Text('Sisa tagihan', textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}

class BuildListTile extends StatelessWidget {
  const BuildListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Obx(
      () {
        List<InvoiceSalesModel> invoiceById = controller.invoiceById;
        var invoiceList = invoiceById;

        if (controller.selectedFilterCheckBox.value == 'paid') {
          invoiceList =
              invoiceById.where((invoice) => invoice.isDebtPaid.value).toList();
        } else if (controller.selectedFilterCheckBox.value == 'debt') {
          invoiceList = invoiceById
              .where((invoice) => !invoice.isDebtPaid.value)
              .toList();
        }

        Future.delayed(Duration.zero, () async {
          invoiceList
              .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: invoiceList.length,
          itemBuilder: (BuildContext context, int index) {
            final invoice = invoiceList[index];
            return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                    tileColor: index % 2 == 0 ? Colors.white : Colors.grey[100],
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${index + 1}. ${invoice.invoiceName.value}',
                          style: context.textTheme.titleMedium!
                              .copyWith(fontSize: 14),
                        ),
                        Text(
                          'Rp${number.format(invoice.totalCost)}',
                          style: context.textTheme.titleMedium!
                              .copyWith(fontSize: 14),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date.format(invoice.createdAt.value!),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: invoice.purchaseOrder.value
                                ? Colors.amber
                                : invoice.isDebtPaid.value
                                    ? Colors.green
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            invoice.purchaseOrder.value
                                ? 'PO'
                                : invoice.isDebtPaid.value
                                    ? 'Lunas'
                                    : 'Rp${number.format(invoice.remainingDebt)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Symbols.arrow_right),
                    onTap: () {
                      controller.displayInvoice = invoice;
                      Get.toNamed(Routes.DETAIL_INVOICE_SALES);
                      // detailSalesInvoice(invoice);
                    },
                    hoverColor: invoice.purchaseOrder.value
                        ? Colors.amber[100]
                        : invoice.isDebtPaid.value
                            ? Colors.green[100]
                            : Colors.red[100],
                  ),
                  if (invoice.purchaseOrder.value) SizedBox(width: 4),
                  if (invoice.purchaseOrder.value)
                    TextButton(
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Konfirmasi",
                            middleText:
                                "Apakah anda yakin ingin menandai barang sudah diterima?",
                            textConfirm: "Ya",
                            textCancel: "Tidak",
                            confirmTextColor: Colors.white,
                            // cancelTextColor: Colors.white,
                            buttonColor: Get.theme.primaryColor,
                            onConfirm: () async {
                              await controller.purchaseOrderDoneHandle(invoice);
                              Get.back();
                            },
                            onCancel: () => Get.back(),
                          );
                        },
                        child: Text('Tandai barang diterima')),
                ]);
          },
        );
      },
    );
  }
}
