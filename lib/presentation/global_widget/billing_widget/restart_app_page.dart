import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/popup_page_widget.dart';

Future<void> restartAppPage() async {
  await showPopupPageWidget(
    barrierDismissible: false,
    title: 'Pembayaran Berhasil',
    height: MediaQuery.of(Get.context!).size.height * (0.75),
    width: MediaQuery.of(Get.context!).size.width * (0.3),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.refresh,
          size: 100,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        const Text(
          'Harap mulai ulang aplikasi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Aplikasi perlu di mulai ulang untuk melanjutkan.',
          style: TextStyle(fontSize: 16),
        ),
        // ElevatedButton(onPressed: () {}, child: Text("Restart"))
      ],
    ),
    // buttonList: [
    //   Obx(
    //     () => ElevatedButton(
    //       onPressed: controller.isLoading.value
    //           ? null
    //           : () async {
    //               // Get.back();
    //               controller.isLoading.value = true;
    //               var path =
    //                   await generateAndSaveReceiptInBackground(globalKey);

    //               await Get.put(OtpController()).successImage(
    //                   authService.store.value!.phone.value,
    //                   path: path);

    //               controller.stopTimer();
    //               controller.paymentDone.value = true;
    //               // Get.back();
    //             },
    //       child: const Text('Restart Aplikasi'),
    //     ),
    //   ),
    // ],
  );
}

// Widget buildText(String text, {bool bold = false, TextAlign? align}) {
//   return Text(
//     text,
//     textAlign: align,
//     style: TextStyle(
//       // fontFamily: 'Courier',
//       fontSize: 12,
//       fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//     ),
//   );
// }

// Future<String> generateAndSaveReceiptInBackground(GlobalKey globalKey) async {
//   try {
//     // Tunggu hingga widget sepenuhnya dirender
//     RenderRepaintBoundary? boundary =
//         globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

//     if (boundary == null) {
//       print('Boundary is null, widget belum dirender.');
//       return '';
//     }

//     var image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();

//     return base64Encode(pngBytes);
//   } catch (e) {
//     print('Error: $e');
//     return '';
//   }
// }



// Widget restartAppPage() {
//   return Scaffold(
//     body: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.refresh,
//             size: 100,
//             color: Colors.blue,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Harap mulai ulang aplikasi',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Aplikasi perlu di mulai ulang untuk melanjutkan.',
//             style: TextStyle(fontSize: 16),
//           ),
//           ElevatedButton(onPressed: () {}, child: Text("Restart"))
//         ],
//       ),
//     ),
//   );
// }
