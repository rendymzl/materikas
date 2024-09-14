import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/invoice_sales_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'buy_product_widget/buy_product_dialog.dart';
import 'controllers/sales.controller.dart';
import 'detail_invoice_sales/detail_invoice_sales.dart';
import 'detail_sales/detail_sales.dart';

class SelectedSalesInvoice extends StatelessWidget {
  const SelectedSalesInvoice({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Obx(
        () {
          return controller.selectedSales.value != null
              ? const SelectedSalesCard()
              : const Center(
                  child: Text('Sales yang dipilih akan ditampilkan disini'));
        },
      ),
    );
  }
}

class SelectedSalesCard extends StatelessWidget {
  const SelectedSalesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Column(
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(controller.selectedSales.value != null
                  ? 'Total Invoice ${controller.selectedSales.value!.getInvoiceListBySalesId(controller.salesInvoices).length}'
                  : '')),
              Text(
                controller.selectedSales.value!.name!,
                style: context.textTheme.titleLarge!.copyWith(fontSize: 24),
              ),
              IconButton(
                onPressed: () =>
                    controller.destroyHandle(controller.selectedSales.value!),
                icon: const Icon(
                  Symbols.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey[300]),
        const HeaderWidget(),
        const Expanded(child: BuildListTile()),
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 12),
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => buyProductDialog(),
                child: const Text('Beli Barang'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () =>
                    detailSales(selectedSales: controller.selectedSales.value),
                child: const Text('Edit Sales'),
              ),
            ],
          ),
        ),
      ],
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

        return ListView.builder(
          // separatorBuilder: (context, index) =>
          //     Divider(color: Colors.grey[200]),
          shrinkWrap: true,
          itemCount: invoiceById.length,
          itemBuilder: (BuildContext context, int index) {
            final invoice = invoiceById[index];
            print('invoice.isDebtPaid.value ${invoice.isDebtPaid.value}');
            return SizedBox(
              // height: 70,
              child: ListTile(
                dense: true,
                tileColor: index % 2 == 0 ? Colors.white : Colors.grey[100],
                title: Row(
                  children: [
                    Expanded(child: Text('${index + 1}.')),
                    Expanded(
                        flex: 3,
                        child: Text(
                          invoice.invoiceId!,
                          style: context.textTheme.titleLarge!
                              .copyWith(fontSize: 15),
                        )),
                    Expanded(
                        flex: 4,
                        child: Text(
                          'Rp${number.format(invoice.totalCost)}',
                          style: context.textTheme.titleLarge!
                              .copyWith(fontSize: 15),
                          textAlign: TextAlign.end,
                        )),
                    Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(left: 50),
                          decoration: BoxDecoration(
                            color: !invoice.isDebtPaid.value
                                ? Colors.red
                                : Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            !invoice.isDebtPaid.value
                                ? 'Rp${number.format(invoice.remainingDebt)}'
                                : 'Lunas',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        )),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    DateFormat('dd/MM HH:mm', 'id')
                        .format(invoice.createdAt.value!),
                    style: const TextStyle(fontSize: 15),
                    // textAlign: TextAlign.end,
                  ),
                ),
                onTap: () {
                  detailSalesInvoice(invoice);
                  // detailDialogInvoiceSales(
                  //     context, controller, invoiceById[index]);
                },
                hoverColor: !invoice.isDebtPaid.value
                    ? Colors.red[100]
                    : Colors.green[100],
              ),
            );
          },
        );
      },
    );
  }
}
