import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../controllers/invoice.controller.dart';

class InvoiceListVertical extends StatelessWidget {
  const InvoiceListVertical({super.key, required this.isDebt});

  final bool isDebt;

  @override
  Widget build(BuildContext context) {
    final InvoiceController controller = Get.find();
    ScrollController scrollC = ScrollController();

    void onScroll() async {
      double maxScroll = scrollC.position.maxScrollExtent;
      double currentScroll = scrollC.position.pixels;
      if (maxScroll == currentScroll &&
          (isDebt
              ? controller.hasMoreDebt.value
              : controller.hasMorePaid.value)) {
        isDebt ? controller.loadDebt() : controller.loadPaid();
      }
    }

    scrollC.addListener(onScroll);

    return Obx(
      () {
        final inv = isDebt
            ? controller.displayedItemsDebt
            : controller.displayedItemsPaid;

        var totalSelectedBill = isDebt
            ? inv.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue + element.remainingDebt)
            : controller.selectedInvoices.fold<double>(0,
                (previousValue, element) => previousValue + element.totalBill);

        return Column(
          children: [
            (inv.isEmpty && !controller.isFiltered() && !isDebt)
                ? Center(child: Text('Belum ada transaksi hari ini'))
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: controller.isFiltered() ? scrollC : null,
                      itemCount: isDebt ? inv.length : inv.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == inv.length) {
                          // Indikator loading di bagian bawah
                          if (isDebt && controller.isLoadingDebt.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (!isDebt &&
                              controller.isLoadingPaid.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (isDebt && !controller.hasMoreDebt.value) {
                            return const Center(
                                child: Text("Tidak ada data lagi"));
                          } else if (!isDebt && !controller.hasMorePaid.value) {
                            return const Center(
                                child: Text("Tidak ada data lagi"));
                          } else {
                            return const SizedBox.shrink();
                          }
                        }

                        String paymentMethod =
                            inv[index].payments.map((e) => e.method).join(', ');
                        final invoice = inv[index];
                        // print('payment data ${invoice.payments[0].toJson()}');
                        final isHover = false.obs;
                        return MouseRegion(
                          onHover: (event) {
                            isHover.value = true;
                          },
                          onExit: (event) {
                            isHover.value = false;
                          },
                          child: Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: controller.checkExisting(invoice)
                                    ? Colors.grey[300]
                                    : index % 2 == 0
                                        ? Colors.white
                                        : Colors.grey[100],
                              ),
                              child: ListTile(
                                dense: true,
                                // leading: Text('${index + 1}.'),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${index + 1}. '),
                                      Expanded(
                                          flex: 4,
                                          child: Text(
                                            invoice.invoiceId!,
                                            style: context.textTheme.titleLarge!
                                                .copyWith(
                                                    fontSize: 15,
                                                    color: controller
                                                            .checkExisting(
                                                                invoice)
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : null),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          )),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                invoice.customer.value?.name ??
                                                    '',
                                                style: context
                                                    .textTheme.titleLarge!
                                                    .copyWith(fontSize: 18),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                subtitle: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        DateFormat('dd/MM HH:mm', 'id')
                                            .format(invoice.createdAt.value!),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                isDebt
                                                    ? 'Tagihan:'
                                                    : 'Pembelian:',
                                                style: context
                                                    .textTheme.titleSmall!
                                                    .copyWith(
                                                        fontSize: 15,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                textAlign: TextAlign.end,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Rp${number.format(invoice.totalBill)}',
                                                style: context
                                                    .textTheme.titleLarge!
                                                    .copyWith(fontSize: 15),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                isDebt ? 'Sisa Bayar:' : '',
                                                style: context
                                                    .textTheme.titleSmall!
                                                    .copyWith(
                                                        fontSize: 15,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                textAlign: TextAlign.end,
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                margin: const EdgeInsets.only(
                                                    left: 20),
                                                decoration: BoxDecoration(
                                                  gradient: (paymentMethod
                                                              .contains(
                                                                  'cash') &&
                                                          paymentMethod
                                                              .contains(
                                                                  'transfer'))
                                                      ? const LinearGradient(
                                                          begin: Alignment
                                                              .topRight,
                                                          end: Alignment
                                                              .bottomLeft,
                                                          colors: [
                                                            Colors.blue,
                                                            Colors.green,
                                                          ],
                                                        )
                                                      : null,
                                                  color: isDebt
                                                      ? Colors.red
                                                      : invoice.totalReturnFinal >
                                                              0
                                                          ? Colors.amber
                                                          : paymentMethod
                                                                  .contains(
                                                                      'cash')
                                                              ? Colors.green
                                                              : paymentMethod.contains(
                                                                          'transfer') ||
                                                                      paymentMethod
                                                                          .contains(
                                                                              'deposit')
                                                                  ? Colors.blue
                                                                  : null,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  isDebt
                                                      ? 'Rp${number.format(invoice.remainingDebt)}'
                                                      : paymentMethod.contains(
                                                              'deposit')
                                                          ? 'Deposit'
                                                          : 'Lunas',
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: controller.selectedMode.value
                                    ? () => controller.selectedHandle(invoice)
                                    : () {
                                        controller.displayInvoice = invoice;
                                        Get.toNamed(Routes.INVOICE_DETAIL);
                                      },
                                onLongPress: controller.selectedMode.value
                                    ? null
                                    : () {
                                        controller.selectedModeHandle();
                                        controller.selectedHandle(invoice);
                                      },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            if (isDebt || controller.selectedMode.value)
              ListTile(
                tileColor: Colors.red[100],
                dense: true,
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
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
                            padding:
                                EdgeInsets.zero, // Menghapus padding default
                          ),
                        ),
                      if (!isDebt) SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDebt ? 'Total Sisa Bayar:' : 'Total Tagihan',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 15),
                          ),
                          if (!isDebt)
                            Text(
                              '(${controller.selectedInvoices.length} Invoice)',
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 15),
                            ),
                        ],
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(left: 50),
                          decoration: BoxDecoration(
                            color: isDebt ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rp${number.format(totalSelectedBill)}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
