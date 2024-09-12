import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/invoice.controller.dart';
import 'detail_invoice/detail_invoice.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  @override
  Widget build(BuildContext context) {
    final InvoiceController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        border: InputBorder.none,
                        labelText: "Cari Invoice",
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Symbols.search),
                      ),
                      onChanged: (value) => controller.filterInvoices(value),
                    ),
                  ),
                ),
                const SizedBox(width: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Tampilkan berdasarkan tanggal:'),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () async => controller.handleFilteredDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.displayFilteredDate.value == ''
                              ? 'Pilih Tanggal'
                              : controller.displayFilteredDate.value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (controller.dateIsSelected.value)
                      TextButton(
                        onPressed: () => controller.clearHandle(),
                        child: const Text('Clear'),
                      ),
                    const SizedBox(width: 80),
                  ],
                ),
                Text('Total invoice: ${controller.invoices.length.toString()}')
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.green[100],
                    child: Text(
                      'INVOICE LUNAS',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge!.copyWith(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
              VerticalDivider(thickness: 1, color: Colors.grey[200]),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red[100],
                    child: Text(
                      'INVOICE BELUM LUNAS',
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleLarge!.copyWith(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(
                child: HeaderWidget(),
              ),
              VerticalDivider(thickness: 1, color: Colors.grey[200]),
              const Expanded(
                child: HeaderWidget(),
              ),
            ],
          ),
          Expanded(
            flex: 10,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: BuildListTile(isDebt: false)),
                VerticalDivider(thickness: 1, color: Colors.grey[200]),
                const Expanded(child: BuildListTile(isDebt: true)),
              ],
            ),
          ),
        ],
      ),
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
                flex: 4, child: Text('Pelanggan', textAlign: TextAlign.end)),
            Expanded(flex: 4, child: Text('Tagihan', textAlign: TextAlign.end)),
            Expanded(
                flex: 5, child: Text('Sisa bayar', textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}

//! Build BuildListTile
class BuildListTile extends StatelessWidget {
  const BuildListTile({
    super.key,
    required this.isDebt,
  });

  final bool isDebt;

  @override
  Widget build(BuildContext context) {
    final InvoiceController controller = Get.find();
    return Obx(
      () {
        List<InvoiceModel> inv = controller.foundInvoices.where((i) {
          return isDebt
              ? i.totalPaid < i.totalBill
              : i.totalPaid >= i.totalBill;
        }).map((purchased) {
          InvoiceModel invPurchase = InvoiceModel.fromJson(purchased.toJson());
          return invPurchase;
        }).toList();
        return ListView.builder(
          // separatorBuilder: (context, index) =>
          //     Divider(color: Colors.grey[200]),
          shrinkWrap: true,
          itemCount: inv.length,
          itemBuilder: (BuildContext context, int index) {
            final invoice = inv[index];
            return SizedBox(
              // height: 70,
              child: ListTile(
                dense: true,
                tileColor: index % 2 == 0 ? Colors.white : Colors.grey[100],
                title: Row(
                  children: [
                    Expanded(child: Text('${index + 1}.')),
                    Expanded(
                        flex: 4,
                        child: Text(
                          invoice.invoiceId!,
                          style: context.textTheme.titleLarge!
                              .copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        )),
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            invoice.customer.value!.name,
                            style: context.textTheme.titleLarge!
                                .copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 4,
                        child: Text(
                          'Rp${number.format(invoice.totalBill)}',
                          style: context.textTheme.titleLarge!
                              .copyWith(fontSize: 15),
                          textAlign: TextAlign.end,
                        )),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(left: 50),
                        decoration: BoxDecoration(
                          color: isDebt
                              ? Colors.red
                              : invoice.totalReturnFinal > 0
                                  ? Colors.amber
                                  : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isDebt
                              ? 'Rp${number.format(invoice.remainingDebt)}'
                              : 'Lunas',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
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
                  InvoiceModel editInvoice =
                      InvoiceModel.fromJson(invoice.toJson());
                  detailDialog(editInvoice);
                },
                hoverColor: isDebt ? Colors.red[100] : Colors.green[100],
              ),
            );
          },
        );
      },
    );
  }
}
