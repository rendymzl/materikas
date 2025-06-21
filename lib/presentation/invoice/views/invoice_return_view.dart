import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../add_product_dialog.dart';
import '../controllers/invoice.controller.dart';
import '../edit_invoice/edit_invoice_controller.dart';
import '../edit_invoice/return_cart_list.dart';

class InvoiceReturnView extends GetView {
  const InvoiceReturnView({super.key});
  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.put(EditInvoiceController());

    var invoice = controller.currentInvoice;

    Get.lazyPut(() => DatePickerController());
    late DatePickerController datePickerC = Get.find();
    late CustomerInputFieldController customerInputFieldC =
        Get.put(CustomerInputFieldController());
    datePickerC.asignDateTime(controller.editInvoice.createdAt.value!);

    if (controller.editInvoice.customer.value != null) {
      customerInputFieldC.asignCustomer(controller.editInvoice.customer.value!);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text('Return Barang'),
          centerTitle: true,
        ),
        // backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Card(
                      child: ReturnCartList(
                        // cartItemList: controller.editInvoice.purchaseList.value,
                        isPureReturn: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () {
                        return controller
                                .editInvoice.returnList.value!.items.isNotEmpty
                            ? Card(
                                // padding: EdgeInsets.only(top: 8),
                                color: Colors.red[100],
                                child: Column(
                                  children: [
                                    // Divider(color: Colors.grey[200]),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Return Tambahan',
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleLarge,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),

                                    ReturnCartList(
                                        // cartItemList: controller
                                        //     .editInvoice.returnList.value!,
                                        ),
                                  ],
                                ),
                              )
                            : const SizedBox();
                      },
                    ),
                    // editInvoice.purchaseList.value.bundleDiscount.value > 0
                    //     ? ListTile(
                    //         title: Text(
                    //           'Diskon Tambahan: Rp-${currency.format(editInvoice.purchaseList.value.bundleDiscount.value)}',
                    //           textAlign: TextAlign.right,
                    //         ),
                    //       )
                    //     : const SizedBox(),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 2,
                    //       child: Container(
                    //         width: double.infinity,
                    //         padding: const EdgeInsets.all(12),
                    //         child: ElevatedButton(
                    //           onPressed: () => addProductDialog(
                    //             isMobile: true,
                    //             isPopUp: true,
                    //             editInvoice.returnList.value!,
                    //             isReturnPage: true,
                    //           ),
                    //           child: const Text(
                    //             'Tambah Barang',
                    //             textAlign: TextAlign.center,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     //                       Expanded(
                    //     //   flex: 3,
                    //     //   child: SizedBox(
                    //     //     height: 150,
                    //     //     child: ReturnFeeWidget(editInvoice: editInvoice),
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                    ReturnFeeWidget(),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: CardListWidget(
                    //       editInvoice: editInvoice, isReturnPage: true),
                    // ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                // height: 70,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    print(
                        'xxzczcxcx editInvoice ${controller.editInvoice.returnFee.value}');
                    print('xxzczcxcx invoice ${invoice.returnFee.value}');
                    AppDialog.show(
                      title: 'Simpan Perubahan',
                      content: 'Simpan perubahan Invoice?',
                      confirmText: 'Simpan',
                      cancelText: 'Batal',
                      onConfirm: () async {
                        // invoice.id = controller.editInvoice.id;
                        // invoice.invoiceId = controller.editInvoice.invoiceId;
                        // invoice.createdAt.value =
                        //     controller.editInvoice.createdAt.value;
                        // invoice.customer.value =
                        //     controller.editInvoice.customer.value;
                        // invoice.purchaseList.value =
                        //     controller.editInvoice.purchaseList.value;
                        // invoice.returnList.value =
                        //     controller.editInvoice.returnList.value;
                        // invoice.priceType.value =
                        //     controller.editInvoice.priceType.value;
                        // invoice.discount.value =
                        //     controller.editInvoice.discount.value;
                        // invoice.returnFee.value =
                        //     controller.editInvoice.returnFee.value;
                        // invoice.payments.value =
                        //     controller.editInvoice.payments;
                        // invoice.debtAmount.value =
                        //     controller.editInvoice.debtAmount.value;
                        // invoice.isDebtPaid.value =
                        //     controller.editInvoice.isDebtPaid.value;
                        // invoice.otherCosts.value =
                        //     controller.editInvoice.otherCosts;

                        await controller.updateInvoice();
                        Get.back();
                      },
                    );
                  },
                  child: const Text(
                    'Simpan Return',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReturnFeeWidget extends StatelessWidget {
  const ReturnFeeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () {
              print('xxzczcxcx 111 ${controller.editInvoice.returnFee.value}');
              final returnFeeTextC = TextEditingController();
              returnFeeTextC.text = controller.editInvoice.returnFee.value == 0
                  ? '-'
                  : currency.format(controller.editInvoice.returnFee.value);
              returnFeeTextC.selection = TextSelection.fromPosition(
                TextPosition(offset: returnFeeTextC.text.length),
              );
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: () => addProductDialog(
                        // isPopUp: true,
                        controller.editInvoice.returnList.value!,
                        isReturnPage: true,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Tambah Barang'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: returnFeeTextC,
                      textAlign: TextAlign.right,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: 'Biaya Return',
                        labelStyle: Get.context!.textTheme.bodySmall!
                            .copyWith(fontStyle: FontStyle.italic),
                        prefixText: 'Rp',
                        counterText: '',
                        filled: true,
                        fillColor: Theme.of(Get.context!)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                        contentPadding: const EdgeInsets.all(10),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        isDense: true,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onChanged: (value) {
                        controller.editInvoice.returnFee.value = value == ''
                            ? 0
                            : double.parse(value.replaceAll('.', ''));

                        controller.editInvoice.updateReturn();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'TOTAL RETURN',
                  // textAlign: TextAlign.right,
                  style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(Get.context!).colorScheme.primary),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    'Rp${currency.format(controller.editInvoice.totalReturnFinal)}',
                    textAlign: TextAlign.end,
                    style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(Get.context!).colorScheme.primary,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
