// // import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// // Simulasi kelas SyncStatus
// class SyncStatus {
//   final bool? hasSynced;

//   SyncStatus({this.hasSynced});
// }

// // Simulasi database dengan stream sinkronisasi
// class PowerSyncDatabase {
//   Stream<SyncStatus> get statusStream => Stream.periodic(
//         const Duration(seconds: 2),
//         (count) => SyncStatus(hasSynced: count % 2 == 0),
//       );
// }

// // Global reference to the database
// final PowerSyncDatabase db = PowerSyncDatabase();

// class SyncController extends GetxController {
//   RxBool hasSynced = false.obs;
//   late StreamSubscription<SyncStatus> _syncStatusSubscription;

//   @override
//   void onInit() {
//     super.onInit();
//     // Listen to statusStream and update hasSynced accordingly
//     _syncStatusSubscription = db.statusStream.listen((status) {
//       hasSynced.value = status.hasSynced ?? false;
//     });
//   }

//   @override
//   void onClose() {
//     _syncStatusSubscription.cancel();
//     super.onClose();
//   }
// }

// // class SyncStatusView extends StatelessWidget {
// //   final SyncController syncController = Get.put(SyncController());

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Sync Status')),
// //       body: Center(
// //         child: Obx(() {
// //           if (syncController.hasSynced.value) {
// //             return const Text(
// //               'Initial sync completed!',
// //               style: TextStyle(fontSize: 20),
// //             );
// //           } else {
// //             return const Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 CircularProgressIndicator(), // Widget loading
// //                 SizedBox(height: 20),
// //                 Text(
// //                   'Busy with initial sync...',
// //                   style: TextStyle(fontSize: 18),
// //                 ),
// //               ],
// //             );
// //           }
// //         }),
// //       ),
// //     );
// //   }
// // }

// // void main() {
// //   runApp(GetMaterialApp(home: SyncStatusView()));
// // }
