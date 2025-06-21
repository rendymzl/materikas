import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../controllers/invoice.controller.dart';
import '../detail_invoice/detail_invoice.dart';

class InvoiceListHorizontal extends StatelessWidget {
  const InvoiceListHorizontal({super.key, required this.isDebt});

  final bool isDebt;

  @override
  Widget build(BuildContext context) {
    final InvoiceController controller = Get.find();
    return Obx(() {
      final inv = isDebt
          ? controller.displayedItemsDebt
          : controller.displayedItemsPaid;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDebt ? Colors.red[100] : Colors.green[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      isDebt ? 'INVOICE BELUM LUNAS' : 'INVOICE LUNAS',
                      textAlign: TextAlign.center,
                      style: Get.context!.textTheme.titleLarge!.copyWith(
                        color: isDebt ? Colors.red[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),
          _buildInvoiceList(context, inv, controller),
          if (isDebt) _buildTotalRemainingDebt(inv),
          if (!isDebt && controller.selectedMode.value)
            _buildTotalRemainingDebt(controller.selectedInvoices),
        ],
      );
    });
  }

  Widget _buildInvoiceList(BuildContext context, List<InvoiceModel> inv,
      InvoiceController controller) {
    final scrollC = ScrollController();
    scrollC.addListener(() {
      double maxScroll = scrollC.position.maxScrollExtent;
      double currentScroll = scrollC.position.pixels;
      if (maxScroll == currentScroll &&
          (isDebt
              ? controller.hasMoreDebt.value
              : controller.hasMorePaid.value)) {
        isDebt ? controller.loadDebt() : controller.loadPaid();
      }
    });
    return (inv.isEmpty && !controller.isFiltered() && !isDebt)
        ? Center(child: Text('Belum ada transaksi hari ini'))
        : Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: controller.isFiltered() ? scrollC : null,
              itemCount: isDebt ? inv.length : inv.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == inv.length) {
                  return _buildLoadingIndicator(isDebt, controller);
                }
                return _buildInvoiceItem(context, index, inv[index]);
              },
            ),
          );
  }

  Widget _buildLoadingIndicator(bool isDebt, InvoiceController controller) {
    if (isDebt && controller.isLoadingDebt.value) {
      return const Center(child: CircularProgressIndicator());
    } else if (!isDebt && controller.isLoadingPaid.value) {
      return const Center(child: CircularProgressIndicator());
    } else if (isDebt && !controller.hasMoreDebt.value) {
      return const Center(child: Text("Tidak ada data lagi"));
    } else if (!isDebt && !controller.hasMorePaid.value) {
      return const Center(child: Text("Tidak ada data lagi"));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInvoiceItem(
      BuildContext context, int index, InvoiceModel invoice) {
    String paymentMethod = invoice.payments.map((e) => e.method).join(', ');
    final isHover = false.obs;
    return MouseRegion(
      onHover: (event) => isHover.value = true,
      onExit: (event) => isHover.value = false,
      child: Obx(
        () => _buildInvoiceListTile(
            context, index, invoice, paymentMethod, isHover),
      ),
    );
  }

  Widget _buildInvoiceListTile(BuildContext context, int index,
      InvoiceModel invoice, String paymentMethod, RxBool isHover) {
    final InvoiceController controller = Get.find();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        gradient: isHover.value
            ? (paymentMethod.contains('cash') &&
                    paymentMethod.contains('transfer'))
                ? const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue,
                      Colors.green,
                    ],
                  )
                : null
            : null,
        color: controller.checkExisting(invoice)
            ? Colors.grey[300]
            : isHover.value
                ? invoice.totalReturnFinal > 0
                    ? Colors.amber[100]
                    : isDebt
                        ? Colors.red[100]
                        : !paymentMethod.contains('transfer')
                            ? Colors.green[100]
                            : !paymentMethod.contains('cash')
                                ? Colors.blue[100]
                                : null
                : index % 2 == 0
                    ? Colors.white
                    : Colors.grey[100],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        dense: true,
        title: _buildInvoiceTitle(context, index, invoice),
        subtitle: _buildInvoiceSubtitle(context, invoice, paymentMethod),
        onTap: controller.selectedMode.value
            ? () => controller.selectedHandle(invoice)
            : () => detailDialog(invoice),
        onLongPress: controller.selectedMode.value
            ? null
            : () {
                controller.selectedModeHandle();
                controller.selectedHandle(invoice);
              },
      ),
    );
  }

  Widget _buildInvoiceTitle(
      BuildContext context, int index, InvoiceModel invoice) {
    final InvoiceController controller = Get.find();
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '${index + 1}.',
            style: context.textTheme.titleLarge!.copyWith(
                fontSize: 15,
                color: controller.checkExisting(invoice)
                    ? Theme.of(context).primaryColor
                    : null),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            invoice.invoiceId!,
            style: context.textTheme.titleLarge!.copyWith(
                fontSize: 15,
                color: controller.checkExisting(invoice)
                    ? Theme.of(context).primaryColor
                    : null),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  invoice.customer.value?.name ?? '',
                  style: context.textTheme.titleLarge!.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSubtitle(
      BuildContext context, InvoiceModel invoice, String paymentMethod) {
    var purchaseReturn = invoice.purchaseList.value.items
        .where((itm) => itm.quantityReturn.value > 0)
        .toList();
    var totalReturn =
        (invoice.returnList.value?.items.length ?? 0) + purchaseReturn.length;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: Text(
                date.format(invoice.createdAt.value!),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Expanded(
              flex: 7,
              child: _buildInvoiceAmount(
                  context, invoice, isDebt ? 'Tagihan:' : 'Pembelian:'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: Text(
                invoice.totalReturnFinal > 0
                    ? '$totalReturn barang direturn'
                    : '',
                style: context.textTheme.labelSmall!.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: _buildRemainingPayment(context, invoice, paymentMethod),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceAmount(
      BuildContext context, InvoiceModel invoice, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: context.textTheme.titleSmall,
          textAlign: TextAlign.end,
        ),
        const SizedBox(width: 4),
        Text(
          'Rp${number.format(invoice.totalBill)}',
          style: context.textTheme.titleLarge!.copyWith(fontSize: 15),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  Widget _buildRemainingPayment(
      BuildContext context, InvoiceModel invoice, String paymentMethod) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          isDebt ? 'Sisa Bayar:' : '',
          style: context.textTheme.titleSmall!.copyWith(fontSize: 12),
          textAlign: TextAlign.end,
        ),
        // const SizedBox(width: 4),
        _buildPaymentStatusContainer(invoice, paymentMethod),
      ],
    );
  }

  Widget _buildPaymentStatusContainer(
      InvoiceModel invoice, String paymentMethod) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        gradient: (paymentMethod.contains('cash') &&
                paymentMethod.contains('transfer'))
            ? const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Colors.green,
                ],
              )
            : null,
        color: invoice.totalReturnFinal > 0
            ? Colors.amber
            : isDebt
                ? Colors.red
                : paymentMethod.toLowerCase().contains('cash')
                    ? Colors.green
                    : paymentMethod.toLowerCase().contains('transfer') ||
                            paymentMethod.toLowerCase().contains('deposit')
                        ? Colors.blue
                        : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDebt
            ? 'Rp${number.format(invoice.remainingDebt)}'
            : paymentMethod.contains('deposit')
                ? 'Deposit'
                : 'Lunas',
        textAlign: TextAlign.end,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget _buildTotalRemainingDebt(RxList<InvoiceModel> inv) {
    final InvoiceController controller = Get.find();
    return Obx(() {
      var total = inv.fold<double>(
          0,
          (previousValue, element) =>
              previousValue +
              (isDebt ? element.remainingDebt : element.totalBill));

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDebt ? Colors.red[100] : Colors.green[100],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (!isDebt)
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      onPressed: () => controller.selectedModeHandle(),
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      iconSize: 18, // Menambahkan iconSize
                      padding: EdgeInsets.zero, // Menghapus padding default
                    ),
                  ),
                if (!isDebt) SizedBox(width: 8),
                Text(
                  isDebt
                      ? 'Total Sisa Bayar:'
                      : 'Total Tagihan (${controller.selectedInvoices.length} Invoice)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDebt ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rp${number.format(total)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }
}
