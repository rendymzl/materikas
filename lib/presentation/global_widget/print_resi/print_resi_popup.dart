// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// import '../popup_page_widget.dart';
// import 'print_resi_controller.dart';

// void printResiPopup() {
//   final controller = Get.put(PrintResiController());

//   showPopupPageWidget(
//     title: 'Cetak Resi',
//     height: MediaQuery.of(Get.context!).size.height * (0.5),
//     width: MediaQuery.of(Get.context!).size.width * (8 / 16),
//     content: Expanded(
//       child: ListView(
//         shrinkWrap: true,
//         padding: const EdgeInsets.all(16),
//         children: [
//           Obx(
//             () => ElevatedButton(
//               onPressed: controller.pickPdfFiles,
//               child: Text(
//                 controller.selectedPdfPaths.isEmpty
//                     ? "Pilih Resi PDF"
//                     : "${controller.selectedPdfPaths.length} file dipilih",
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Obx(
//             () => controller.selectedPdfPaths.isNotEmpty
//                 ? Flexible(
//                     fit: FlexFit.loose,
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: controller.selectedPdfPaths.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           leading: const Icon(Icons.picture_as_pdf),
//                           title: Text(
//                             controller.selectedPdfPaths[index].split("/").last,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () {
//                               controller.selectedPdfPaths.removeAt(index);
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 : const SizedBox(),
//           ),
//           const SizedBox(height: 16),
//           Obx(
//             () => ElevatedButton(
//               onPressed: controller.selectedPdfPaths.isNotEmpty &&
//                       !controller.isLoading.value
//                   ? controller.printPdfs
//                   : null,
//               child: controller.isLoading.value
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Cetak Semua"),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget buildTextFormField({
//   required TextEditingController controller,
//   required String labelText,
//   required Function(String) onChanged,
//   String? Function(String?)? validator,
//   Function(String)? onFieldSubmitted,
//   String prefixText = '',
//   bool isCurrency = false,
//   bool isNumeric = false,
// }) {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     child: TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.transparent),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Colors.transparent),
//         ),
//         border: InputBorder.none,
//         fillColor: Colors.grey[200],
//         filled: true,
//         labelText: labelText,
//         labelStyle: const TextStyle(color: Colors.grey),
//         floatingLabelStyle:
//             TextStyle(color: Theme.of(Get.context!).colorScheme.primary),
//         focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.red)),
//         errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.red)),
//         prefixText: prefixText,
//         prefixStyle: prefixText.isNotEmpty ? const TextStyle() : null,
//       ),
//       keyboardType: isNumeric || isCurrency
//           ? const TextInputType.numberWithOptions(decimal: true)
//           : TextInputType.text,
//       inputFormatters: isNumeric || isCurrency
//           ? isCurrency
//               ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
//               : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*'))]
//           : [],
//       onChanged: onChanged,
//       validator: validator,
//       onFieldSubmitted: onFieldSubmitted,
//     ),
//   );
// }
