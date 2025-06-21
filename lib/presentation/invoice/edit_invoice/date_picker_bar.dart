// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../infrastructure/utils/display_format.dart';
// import '../../global_widget/date_picker_widget/date_picker_widget.dart';
// import 'edit_invoice_controller.dart';

// class DatePickerBar extends StatelessWidget {
//   const DatePickerBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return vertical ? VerticalView() : HorizontalView();
//   }
// }

// class HorizontalView extends StatelessWidget {
//   const HorizontalView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final editInvC = Get.find<EditInvoiceController>();

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildPriceTypeSelector(editInvC, context),
//         const DatePickerWidget(),
//       ],
//     );
//   }

//   Widget _buildPriceTypeSelector(
//       EditInvoiceController controller, BuildContext context) {
//     return Row(
//       children: [
//         _buildPriceTypeItem(
//           controller: controller,
//           context: context,
//           priceType: 2,
//           label: controller.accountC.account.value!.name.toLowerCase() ==
//                   'arca nusantara'
//               ? 'masuk gang'
//               : '2',
//         ),
//         const SizedBox(width: 20),
//         _buildPriceTypeItem(
//           controller: controller,
//           context: context,
//           priceType: 3,
//           label: controller.accountC.account.value!.name.toLowerCase() ==
//                   'arca nusantara'
//               ? 'material'
//               : '3',
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceTypeItem({
//     required EditInvoiceController controller,
//     required BuildContext context,
//     required int priceType,
//     required String label,
//   }) {
//     return Obx(
//       () => InkWell(
//         onTap: () {
//           controller.priceTypeHandleCheckBox(priceType);
//           controller.editInvoice.updateIsDebtPaid();
//         },
//         child: SizedBox(
//           child: Row(
//             children: [
//               Checkbox(
//                 value: controller.editInvoice.priceType.value == priceType,
//                 onChanged: (value) {
//                   controller.priceTypeHandleCheckBox(priceType);
//                   controller.editInvoice.updateIsDebtPaid();
//                 },
//               ),
//               Text(
//                 'Harga $label',
//                 style: controller.editInvoice.priceType.value == priceType
//                     ? context.textTheme.bodySmall!
//                         .copyWith(color: Theme.of(context).colorScheme.primary)
//                     : context.textTheme.bodySmall,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class VerticalView extends StatelessWidget {
//   const VerticalView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final EditInvoiceController controller = Get.find();

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.blueGrey[50],
//                 ),
//                 child: Obx(
//                   () => DropdownButtonFormField<int>(
//                     value: controller.editInvoice.priceType.value,
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                     ),
//                     items: [
//                       DropdownMenuItem(
//                         value: 1,
//                         child: const Text('Harga Normal'),
//                       ),
//                       DropdownMenuItem(
//                         value: 2,
//                         child: Text(
//                           'Harga ${controller.accountC.account.value!.name.toLowerCase() == 'arca nusantara' ? 'masuk gang' : '2'}',
//                         ),
//                       ),
//                       DropdownMenuItem(
//                         value: 3,
//                         child: Text(
//                           'Harga ${controller.accountC.account.value!.name.toLowerCase() == 'arca nusantara' ? 'material' : '3'}',
//                         ),
//                       ),
//                     ],
//                     onChanged: (value) {
//                       controller.priceTypeHandleCheckBox(value!);
//                     },
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[800],
//                     ),
//                     dropdownColor: Colors.white,
//                     iconEnabledColor: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             const DatePickerWidget(),
//           ],
//         ),
//       ],
//     );
//   }
// }
