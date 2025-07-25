// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

// import '../../infrastructure/models/operating_cost_model.dart';
// import '../../infrastructure/utils/display_format.dart';
// import 'controllers/statistic.controller.dart';

// class OperatingCostList extends StatelessWidget {
//   const OperatingCostList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final StatisticController controller = Get.find();

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           // Container(
//           //   margin: const EdgeInsets.only(bottom: 8),
//           //   decoration: BoxDecoration(
//           //     color: Colors.grey[200],
//           //     borderRadius: const BorderRadius.all(
//           //       Radius.circular(12),
//           //     ),
//           //   ),
//           //   height: 50,
//           //   child: TextField(
//           //     decoration: const InputDecoration(
//           //       border: InputBorder.none,
//           //       labelText: "Cari Pelanggan",
//           //       labelStyle: TextStyle(color: Colors.grey),
//           //       prefixIcon: Icon(Symbols.search),
//           //     ),
//           //     onChanged: (value) => controller.filterCustomers(value),
//           //   ),
//           // ),
//           const TableHeader(),
//           Divider(color: Colors.grey[500]),
//           Expanded(
//             child: Obx(
//               () {
//                 print(controller.foundOperatingCosts.length);
//                 return ListView.separated(
//                   separatorBuilder: (context, index) =>
//                       Divider(color: Colors.grey[300]),
//                   itemCount: controller.foundOperatingCosts.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     final foundOperatingCost =
//                         controller.foundOperatingCosts[index];
//                     return TableContent(
//                         index: index, operatingCost: foundOperatingCost);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TableHeader extends StatelessWidget {
//   const TableHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: SizedBox(
//         width: 50,
//         child: Text(
//           'No',
//           style: context.textTheme.headlineSmall,
//         ),
//       ),
//       title: Row(
//         children: [
//           Expanded(
//             flex: 4,
//             child: SizedBox(
//               child: Text(
//                 'Tanggal',
//                 style: context.textTheme.headlineSmall,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: SizedBox(
//               child: Text(
//                 'Operasional',
//                 style: context.textTheme.headlineSmall,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 6,
//             child: SizedBox(
//               child: Text(
//                 'Jumlah Biaya',
//                 style: context.textTheme.headlineSmall,
//               ),
//             ),
//           ),
//         ],
//       ),
//       trailing: Text(
//         'Hapus',
//         style: context.textTheme.headlineSmall,
//       ),
//     );
//   }
// }

// class TableContent extends StatelessWidget {
//   const TableContent(
//       {super.key, required this.index, required this.operatingCost});

//   final int index;
//   final OperatingCostModel operatingCost;

//   @override
//   Widget build(BuildContext context) {
//     StatisticController controller = Get.find();

//     return ListTile(
//       leading: SizedBox(
//         width: 50,
//         child: Text(
//           (index + 1).toString(),
//           style: context.textTheme.bodySmall,
//         ),
//       ),
//       title: Row(
//         children: [
//           Expanded(
//             flex: 4,
//             child: Container(
//               padding: const EdgeInsets.only(right: 30),
//               child: Text(
//                 DateFormat('dd/MMM HH:mm', 'id')
//                     .format(operatingCost.createdAt!),
//                 style: context.textTheme.titleMedium,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: SizedBox(
//               child: Text(
//                 operatingCost.name ?? '',
//                 style: context.textTheme.titleMedium,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 6,
//             child: SizedBox(
//               child: Text(
//                 'Rp${currency.format(operatingCost.amount ?? 0)}',
//                 style: context.textTheme.titleMedium,
//               ),
//             ),
//           ),
//         ],
//       ),
//       trailing: IconButton(
//         onPressed: () async => await Get.defaultDialog(
//           title: 'Hapus',
//           middleText: 'Hapus Biaya?',
//           confirm: TextButton(
//             onPressed: () async {
//               controller.deleteOperatingCost(operatingCost);
//               Get.back();
//             },
//             child: const Text('Hapus'),
//           ),
//           cancel: TextButton(
//             onPressed: () {
//               Get.back();
//             },
//             child: Text(
//               'Batal',
//               style: TextStyle(color: Colors.black.withOpacity(0.5)),
//             ),
//           ),
//         ),
//         icon: const Icon(
//           Symbols.delete_forever,
//           color: Colors.red,
//         ),
//       ),
//     );
//   }
// }
