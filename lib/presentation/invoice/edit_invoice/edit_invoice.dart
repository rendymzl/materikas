import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/field_customer_widget/field_customer_widget.dart';
import '../../global_widget/invoice_widget/price_type_header_horizontal.dart';
import '../../global_widget/payment_widget/payment_list_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/invoice_widget/transaction/calculate_price.dart';
import '../cart_list_widget.dart';
import 'edit_invoice_controller.dart';

void editInvoice() {
  final editInvC = Get.find<EditInvoiceController>();

  showPopupPageWidget(
    title: 'Edit Invoice ${editInvC.editInvoice.invoiceId}',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.65),
    content: _buildEditInvoiceContent(editInvC),
    buttonList: [
      ElevatedButton(
        onPressed: () => _saveChanges(editInvC),
        child: const Text('Simpan Perubahan'),
      ),
    ],
  );
}

Widget _buildEditInvoiceContent(EditInvoiceController controller) {
  return Expanded(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        HorizontalPriceTypeView(
          priceType: controller.editInvoice.priceType,
          datetime: controller.editInvoice.createdAt,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const CustomerInputField(),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CardListWidget(),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Pembayaran',
                      style: Get.context!.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PaymentListWidget(editInvoice: controller.editInvoice),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: CalculatePrice(
                editableInvoice: controller.editInvoice,
                isEdit: true,
                onlyPayment: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _saveChanges(EditInvoiceController controller) {
  AppDialog.show(
    title: 'Simpan Perubahan',
    content: 'Simpan perubahan Invoice?',
    confirmText: 'Simpan',
    cancelText: 'Batal',
    onConfirm: () async {
      await controller.updateInvoice();
      Get.back();
      // Get.back();
    },
    // onCancel: () => Get.back(),
  );
}


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../global_widget/app_dialog_widget.dart';
// import '../../global_widget/field_customer_widget/field_customer_widget.dart';
// import '../../global_widget/payment_widget/payment_list_widget.dart';
// import '../../global_widget/popup_page_widget.dart';
// import '../../home/selected_product_widget/calculate_price.dart';
// import '../../home/selected_product_widget/price_type_widget.dart';
// import '../cart_list_widget.dart';
// // import 'date_picker_bar.dart';
// import 'edit_invoice_controller.dart';

// void editInvoice(InvoiceModel invoice) {
//   final editInvC = Get.put(EditInvoiceController());
//   // final datePickerC = Get.put(DatePickerController());
//   // final customerInputFieldC = Get.put(CustomerInputFieldController());

//   // datePickerC.asignDateTime(invoice.createdAt.value!);
//   // editInvC.currentInvoice = invoice;
//   // editInvC.editInvoice = InvoiceModel.fromJson(invoice.toJson());
//   // editInvC.editInvoice.returnList.value ??= Cart(items: <CartItem>[].obs);

//   // if (invoice.customer.value != null) {
//   //   customerInputFieldC.asignCustomer(editInvC.editInvoice.customer.value!);
//   // }

//   showPopupPageWidget(
//     title: 'Edit Invoice ${editInvC.editInvoice.invoiceId}',
//     height: MediaQuery.of(Get.context!).size.height * (6 / 7),
//     width: MediaQuery.of(Get.context!).size.width * (0.65),
//     content: _buildEditInvoiceContent(editInvC),
//     buttonList: [
//       ElevatedButton(
//         onPressed: () => _saveChanges(editInvC, invoice),
//         child: const Text('Simpan Perubahan'),
//       ),
//     ],
//     onClose: () => _handleOnClose(editInvC),
//   );
// }

// Widget _buildEditInvoiceContent(EditInvoiceController controller) {
//   return Expanded(
//     child: ListView(
//       shrinkWrap: true,
//       padding: const EdgeInsets.all(16),
//       children: [
//         PriceTypeAndDatePickerHeader(
//           priceType: controller.editInvoice.priceType,
//           datetime: controller.editInvoice.createdAt,
//         ),
//         const SizedBox(height: 12),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: const CustomerInputField(),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: CardListWidget(),
//           ),
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 3,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   ListTile(
//                     title: Text(
//                       'Pembayaran',
//                       style: Get.context!.textTheme.titleLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   PaymentListWidget(editInvoice: controller.editInvoice),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               flex: 4,
//               child: CalculatePrice(
//                   editableInvoice: controller.editInvoice, isEdit: true),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// void _saveChanges(EditInvoiceController controller, InvoiceModel invoice) {
//   AppDialog.show(
//     title: 'Simpan Perubahan',
//     content: 'Simpan perubahan Invoice?',
//     confirmText: 'Simpan',
//     cancelText: 'Batal',
//     onConfirm: () async {
//       double prevTotalAppBill = invoice.appBillAmount.value;
//       final editInvoice = controller.editInvoice;
//       invoice.id = editInvoice.id;
//       invoice.invoiceId = editInvoice.invoiceId;
//       invoice.createdAt.value = editInvoice.createdAt.value;
//       invoice.customer.value = editInvoice.customer.value;
//       invoice.purchaseList.value = editInvoice.purchaseList.value;
//       invoice.priceType.value = editInvoice.priceType.value;
//       invoice.discount.value = editInvoice.discount.value;
//       invoice.payments.value = editInvoice.payments;
//       invoice.debtAmount.value = editInvoice.debtAmount.value;
//       invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
//       invoice.otherCosts.value = editInvoice.otherCosts;
//       await controller.updateInvoice(invoice,
//           prevTotalAppBill: prevTotalAppBill);
//       Get.back();
//       Get.back();
//     },
//     onCancel: () => Get.back(),
//   );
// }

// void _handleOnClose(EditInvoiceController controller) {
//   for (final cartItem in controller.initCartList) {
//     final product = controller.foundProducts
//         .firstWhereOrNull((p) => p.id == cartItem.product.id);
//     if (product != null) {
//       product.stock.value = cartItem.product.stock.value;
//     }
//   }
//   controller.clear();
// }
