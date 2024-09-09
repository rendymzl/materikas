import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/product_list_widget/product_list_widget.dart';
import 'date_picker_bar.dart';
import 'edit_cart_list.dart';
import 'edit_invoice_controller.dart';

void editInvoice(InvoiceModel invoice) {
  late EditInvoiceController controller = Get.put(EditInvoiceController());
  Get.lazyPut(() => DatePickerController());
  late DatePickerController _datePickerC = Get.find();
  late CustomerInputFieldController _customerInputFieldC =
      Get.put(CustomerInputFieldController());
  _datePickerC.asignDateTime(invoice.createdAt.value!);

  if (invoice.customer.value != null) {
    _customerInputFieldC.asignCustomer(invoice.customer.value!);
  }

  InvoiceModel editInvoice = InvoiceModel.fromJson(invoice.toJson());

  showPopupPageWidget(
    title: 'Edit Invoice ${editInvoice.invoiceId}',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (5 / 11),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        DatePickerBar(editInvoice: editInvoice),
        const CustomerInputField(),
        Card(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Obx(
                () {
                  final returnFeeTextC = TextEditingController();
                  returnFeeTextC.text = editInvoice.returnFee.value == 0
                      ? '-'
                      : currency.format(editInvoice.returnFee.value);
                  returnFeeTextC.selection = TextSelection.fromPosition(
                    TextPosition(offset: returnFeeTextC.text.length),
                  );
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (editInvoice.purchaseList.value
                                  .getTotalReturnPurchase(
                                      editInvoice.priceType.value) !=
                              -1)
                            Expanded(
                              child: Column(
                                children: [
                                  Text('Return',
                                      style: Theme.of(Get.context!)
                                          .textTheme
                                          .titleLarge,
                                      textAlign: TextAlign.end),
                                  const SizedBox(height: 12),
                                  EditCartList(
                                    invoice: editInvoice,
                                    cartItemList:
                                        editInvoice.purchaseList.value,
                                    isReturn: true,
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            controller: returnFeeTextC,
                                            textAlign: TextAlign.center,
                                            maxLength: 15,
                                            decoration: InputDecoration(
                                              labelText: 'Biaya Return',
                                              labelStyle: Get
                                                  .context!.textTheme.bodySmall!
                                                  .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic),
                                              prefixText: 'Rp',
                                              counterText: '',
                                              filled: true,
                                              fillColor: Theme.of(Get.context!)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.2),
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              border: const OutlineInputBorder(
                                                  borderSide: BorderSide.none),
                                              isDense: true,
                                            ),
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]'))
                                            ],
                                            onChanged: (value) {
                                              editInvoice.returnFee.value =
                                                  value == ''
                                                      ? 0
                                                      : double.parse(value
                                                          .replaceAll('.', ''));

                                              editInvoice.updateReturn();
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          title: Row(
                                            children: [
                                              const Expanded(
                                                  flex: 5, child: Text('')),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  'TOTAL RETURN',
                                                  textAlign: TextAlign.right,
                                                  style: Theme.of(Get.context!)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  Get.context!)
                                                              .colorScheme
                                                              .primary),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Obx(
                                                  () => Text(
                                                    'Rp${currency.format(editInvoice.totalReturn)}',
                                                    textAlign: TextAlign.end,
                                                    style: Theme.of(
                                                            Get.context!)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(Get
                                                                    .context!)
                                                                .colorScheme
                                                                .primary),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: SizedBox(
                              child: Column(
                                children: [
                                  Text('Pembelian',
                                      style: Theme.of(Get.context!)
                                          .textTheme
                                          .titleLarge,
                                      textAlign: TextAlign.end),
                                  const SizedBox(height: 12),
                                  EditCartList(
                                    invoice: editInvoice,
                                    cartItemList:
                                        editInvoice.purchaseList.value,
                                    isReturn: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          PopupPageWidget(
                            title: 'Tambah Barang',
                            content: Card(
                              child: ProductListWidget(onClick: (product) {
                                // controller.addToCart(product);
                              }),
                            ),
                          );
                          // Get.defaultDialog(
                          //   content: Container(
                          //     margin: const EdgeInsets.all(8),
                          //     height: MediaQuery.of(Get.context!).size.height *
                          //         (3 / 4),
                          //     width: MediaQuery.of(Get.context!).size.width *
                          //         (7 / 9),
                          //     child: AddProductDialog(
                          //       editInvoice: editInvoice,
                          //       controller: controller,
                          //       isEdit: true,
                          //     ),
                          //   ),
                          // );
                        },
                        child: const Text(
                          'Tambah Barang',
                        ),
                      ),
                    ],
                  );
                },
              )),
        ),
      ],
    ),
    buttonList: [],
  );
}
