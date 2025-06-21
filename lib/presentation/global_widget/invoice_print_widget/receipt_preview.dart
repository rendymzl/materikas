import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'print_usb_controller.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({
    super.key,
    required this.invoice,
    required this.printerC,
    required this.filteredPurchase,
    required this.returned,
    this.isSupplier = false,
  });

  final InvoiceModel invoice;
  final PrinterUsbController printerC;
  final List<CartItem> filteredPurchase;
  final List<CartItem> returned;
  final bool isSupplier;

  @override
  Widget build(BuildContext context) {
    final double width = printerC.selectedPaperSize.value == '58 mm'
        ? 250
        : (printerC.selectedPaperSize.value == '76 mm' ? 300 : 350);
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //! HEADER
              buildHeader(invoice),
              //! DETAIL INVOICE
              if (printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildText('SURAT JALAN',
                        bold: true, align: TextAlign.center),
                  ],
                ),

              if (printerC.isPrintTransport.value) SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: buildText('${invoice.invoiceId}')),
                  Expanded(
                    child: buildText(
                      DateFormat('dd-MM-y, HH:mm', 'id').format(
                        invoice.createdAt.value!,
                      ),
                      align: TextAlign.right,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildText('${invoice.customer.value!.name}'),
                  buildText(
                      isSupplier ? '' : 'Kasir: ${invoice.account.value.name}'),
                ],
              ),
              buildText('${invoice.customer.value!.phone}'),
              buildText('${invoice.customer.value!.address}'),
              const SizedBox(height: 10),
              //! HEADER TABLE

              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 25, child: buildText('No', bold: true)),
                      buildText('Nama Barang', bold: true),
                    ],
                  ),
                  buildText(printerC.isPrintTransport.value ? 'Qty' : 'Harga',
                      bold: true),
                ],
              ),

              Divider(),
              //! PURCHASE DETAIL
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredPurchase.length,
                itemBuilder: (context, index) {
                  var item = filteredPurchase[index];
                  var price = currency.format(isSupplier
                      ? item.product.costPrice.value
                      : item.product.getPrice(invoice.priceType.value).value);
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width: 25, child: buildText('${index + 1}')),
                              buildText('${item.product.productName},'),
                            ],
                          ),
                          if (printerC.isPrintTransport.value)
                            buildText(
                                '${number.format(item.quantity.value)} ${item.product.unit}'),
                        ],
                      ),
                      if (!printerC.isPrintTransport.value)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 25, child: buildText('')),
                                buildText(
                                    '$price x ${number.format(item.quantity.value)} ${item.product.unit}'),
                              ],
                            ),
                            buildText(currency.format(isSupplier
                                ? item.product.costPrice.value *
                                    item.quantity.value
                                : item.getBill(invoice.priceType.value))),
                          ],
                        ),
                    ],
                  );
                },
              ),

              Divider(),
              //! RETURN DETAIL
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Subtotal:', bold: true),
                    buildText(
                        currency.format(isSupplier
                            ? invoice.subtotalCost
                            : invoice.subtotalBill),
                        bold: true),
                  ],
                ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                const SizedBox(height: 20),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                buildText('-- Barang yang direturn --', bold: true),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Divider(),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: returned.length,
                  itemBuilder: (context, index) {
                    var item = returned[index];
                    return item.quantityReturn.value > 0
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 35,
                                          child: buildText('${index + 1}')),
                                      buildText('${item.product.productName},'),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 35, child: buildText('')),
                                      buildText(
                                          '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.quantityReturn.value)} ${item.product.unit}'),
                                    ],
                                  ),
                                  buildText(currency.format(
                                      item.getReturn(invoice.priceType.value))),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox();
                  },
                ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Divider(),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Subtotal return:'),
                    buildText(invoice.totalReturn > 0
                        ? '-${currency.format((invoice.totalReturn))}'
                        : '0'),
                  ],
                ),

              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Biaya return:'),
                    buildText(currency.format(invoice.returnFee.value)),
                  ],
                ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buildText('----------', bold: true),
                  ],
                ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Total return:', bold: true),
                    buildText('-${currency.format(invoice.totalReturnFinal)}',
                        bold: true),
                  ],
                ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                const SizedBox(height: 20),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Divider(),
              //! CALCULATE
              if (!printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('SUBTOTAL HARGA:', bold: true),
                    buildText(
                        currency.format(isSupplier
                            ? invoice.totalCost
                            : invoice.subTotalPurchase),
                        bold: true),
                  ],
                ),
              if (!printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Total diskon:'),
                    buildText(invoice.totalDiscount > 0
                        ? '-${currency.format(invoice.totalDiscount)}'
                        : '0'),
                  ],
                ),
              if (!printerC.isPrintTransport.value)
                if (invoice.totalOtherCosts > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('Biaya lainnya:'),
                      buildText(invoice.totalOtherCosts > 0
                          ? currency.format(invoice.totalOtherCosts)
                          : '0'),
                    ],
                  ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Divider(),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Tagihan sebelum return:', bold: true),
                    buildText(currency.format(invoice.totalPurchase),
                        bold: true),
                  ],
                ),

              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText('Total return:'),
                    buildText('-${currency.format(invoice.totalReturnFinal)}'),
                  ],
                ),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Divider(),
              if (invoice.isReturn && !printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText(
                        invoice.isReturn
                            ? 'Tagihan setelah return:'
                            : 'Total tagihan:',
                        bold: true),
                    buildText(
                        currency.format(
                            isSupplier ? invoice.totalCost : invoice.totalBill),
                        bold: true),
                  ],
                ),
              if (!printerC.isPrintTransport.value)
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: invoice.payments.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText(
                            'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                            bold: true),
                        buildText(
                            currency.format(invoice.totalPaidByIndex(index) ==
                                    invoice.totalBill
                                ? invoice.payments[index].amountPaid
                                : invoice.payments[index].finalAmountPaid),
                            bold: true),
                      ],
                    );
                  },
                ),
              if (!printerC.isPrintTransport.value) Divider(),
              if (!printerC.isPrintTransport.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText(
                        invoice.remainingDebt <= 0
                            ? 'Kembalian:'
                            : 'Kurang Bayar:',
                        bold: true),
                    buildText(
                        currency.format((isSupplier
                                ? invoice.remainingCost
                                : invoice.remainingDebt) *
                            -1),
                        bold: true),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),

          //! ADDITIONAL TEXT PRINT
          if (!printerC.isPrintTransport.value && !isSupplier)
            Obx(
              () => ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: printerC.store!.textPrint!.length,
                itemBuilder: (context, index) {
                  var textPrint = printerC.store!.textPrint![index];
                  return Column(
                    children: [
                      buildText(textPrint, align: TextAlign.center),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          Obx(() {
            if (printerC.printDate.value) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'dicetak: ${date.format(DateTime.now())}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildHeader(InvoiceModel invoice) {
    final controller = Get.put(PrinterUsbController());
    String phone = controller.store!.phone.value;
    String telp = controller.store!.telp.value;
    String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() => controller.logo.value != null
            ? Image.file(controller.logo.value!)
            : const SizedBox.shrink()),
        Text(
          controller.store!.name.value,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          controller.store!.address.value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 12,
          ),
        ),
        Text(
          '$phone $slash $telp',
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 12,
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget buildText(String text,
      {bool bold = false, TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: 14, // Increased font size
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
