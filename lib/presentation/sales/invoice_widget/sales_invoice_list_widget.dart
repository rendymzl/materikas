import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../controllers/sales.controller.dart';
import '../detail_invoice_sales/detail_invoice_sales.dart';

class SalesInvoiceList extends StatelessWidget {
  const SalesInvoiceList({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();
    final ScrollController scrollC = ScrollController();

    scrollC.addListener(() {
      if (scrollC.position.pixels == scrollC.position.maxScrollExtent &&
          controller.hasMore.value) {
        controller.loadInvoice();
      }
    });

    return Obx(() {
      final invoices = controller.displayedItems;
      final invoiceById = controller.invoiceById;
      List<InvoiceSalesModel> invoiceList =
          controller.selectedSales.value == null ? invoices : invoiceById;

      if (controller.selectedSales.value != null) {
        if (controller.selectedFilterCheckBox.value == 'paid') {
          invoiceList =
              invoiceById.where((invoice) => invoice.isDebtPaid.value).toList();
        } else if (controller.selectedFilterCheckBox.value == 'debt') {
          invoiceList = invoiceById
              .where((invoice) => !invoice.isDebtPaid.value)
              .toList();
        }
      }

      return ListView.builder(
        controller: controller.selectedSales.value == null ? scrollC : null,
        shrinkWrap: true,
        itemCount: invoiceList.length,
        itemBuilder: (context, index) {
          final invoice = invoiceList[index];
          return _buildInvoiceListTile(context, invoice, index, controller);
        },
      );
    });
  }

  Widget _buildInvoiceListTile(BuildContext context, InvoiceSalesModel invoice,
      int index, SalesController controller) {
    return SizedBox(
      child: ListTile(
        dense: true,
        tileColor: index % 2 == 0 ? Colors.white : Colors.grey[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    '${index + 1}. ${invoice.invoiceName.value}  |  ',
                    style:
                        context.textTheme.titleMedium!.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(child: Text(invoice.sales.value?.name ?? '')),
                ],
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Rp${number.format(invoice.totalCost)}',
              style: context.textTheme.titleMedium!.copyWith(fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date.format(invoice.createdAt.value!),
                style: const TextStyle(fontSize: 12),
              ),
              Row(
                children: [
                  if (invoice.purchaseOrder.value)
                    _buildPurchaseOrderButton(invoice, controller),
                  if (invoice.purchaseOrder.value) const SizedBox(width: 4),
                  _buildStatusIndicator(invoice),
                ],
              ),
            ],
          ),
        ),
        onTap: () => detailSalesInvoice(invoice),
        hoverColor: invoice.purchaseOrder.value
            ? Colors.amber[100]
            : !invoice.isDebtPaid.value
                ? Colors.red[100]
                : Colors.green[100],
      ),
    );
  }

  Widget _buildPurchaseOrderButton(
      InvoiceSalesModel invoice, SalesController controller) {
    return TextButton(
      onPressed: () {
        Get.defaultDialog(
          title: "Konfirmasi",
          middleText: "Apakah anda yakin ingin menandai barang sudah diterima?",
          textConfirm: "Ya",
          textCancel: "Tidak",
          confirmTextColor: Colors.white,
          buttonColor: Get.theme.primaryColor,
          onConfirm: () async {
            await controller.purchaseOrderDoneHandle(invoice);
            Get.back();
          },
          onCancel: () => Get.back(),
        );
      },
      child: const Text('Tandai barang diterima'),
    );
  }

  Widget _buildStatusIndicator(InvoiceSalesModel invoice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                : 'Sisa Bayar:   Rp${number.format(invoice.remainingDebt)}',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
