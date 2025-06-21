import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'no_connection_page.dart';
import 'payment_package_page.dart';
import 'payment_subs_windows/payment_subs_windows.dart';
import 'payment_subs_windows/payment_subs_windows_controller.dart';
import 'select_package_page.dart';
import 'subs_controller.dart';

import '../../global_widget/popup_page_widget.dart';

Future<void> subscriptionPopup() async {
  final controller = Get.put(SubsController());
  final internetService = Get.find<InternetService>();
  print('awdawdwad subscriptionPopup ${controller.showPopupSubs.value}');

  showPopupPageWidget(
    title: 'Pilih Langganan',
    height: MediaQuery.of(Get.context!).size.height * (vertical ? 0.65 : 0.85),
    width: MediaQuery.of(Get.context!).size.width * (vertical ? 1 : 0.3),
    // iconButton: IconButton(
    //   icon: const Icon(Icons.arrow_back),
    //   onPressed: controller.showPopupSubs.value
    //       ? null
    //       : () {
    //           controller.stopTimer();
    //           Get.back();
    //         },
    // ),
    barrierDismissible: !controller.showPopupSubs.value,
    // iconButton: IconButton(onPressed: onPressed, icon: icon),
    content: Obx(
      () => Expanded(
        child: Column(
          children: [
            if (controller.showPopupSubs.value)
              Text('Masa Aktif langganan anda telah berakhir.',
                  style: TextStyle(color: Colors.red)),
            if (controller.showPopupSubs.value)
              Text('Silahkan pilih langganan untuk menggunakan aplikasi.',
                  style: TextStyle(color: Colors.red)),
            if (controller.showPopupSubs.value) SizedBox(height: 12),
            Expanded(
              child: !internetService.isConnected.value
                  ? noConnectionPage()
                  : controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : controller.page.value == 'select'
                          ? selectPackageWidget()
                          : vertical
                              ? paymentPackageWidget()
                              : paymentSubsWindows(),
            ),
          ],
        ),
      ),
    ),
    buttonList: [
      Obx(() => internetService.isConnected.value
          ? Expanded(
              child: controller.page.value == 'select'
                  ? ElevatedButton(
                      onPressed: () async {
                        if (controller.selectedPackage.value != null) {
                          controller.goToPaymentPage();
                        } else {
                          ScaffoldMessenger.of(Get.context!).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Silakan pilih paket langganan terlebih dahulu"),
                            ),
                          );
                        }
                      },
                      child: const Text('Pilih Pembayaran'),
                    )
                  : OutlinedButton(
                      onPressed: () async => await controller.cancelPayment(),
                      child: const Text('Ubah Paket'),
                    ),
            )
          : const SizedBox()),
      // Obx(() => controller.page.value == 'payment'
      //     ? OutlinedButton(
      //         onPressed: () async => await controller.onSuccess(),
      //         child: const Text('bypass'),
      //       )
      //     : const SizedBox()),
      // Obx(() => controller.page.value == 'payment'
      //     ? Container(
      //         margin: EdgeInsets.only(left: 12),
      //         decoration: BoxDecoration(
      //           color: Get.theme.primaryColor,
      //           borderRadius:
      //               BorderRadius.circular(8), // Menambahkan border radius
      //         ),
      //         child: IconButton(
      //           icon: const Icon(Icons.refresh, color: Colors.white),
      //           onPressed: () {
      //             Get.find<BrowserWindowsController>()
      //                 .webViewController
      //                 ?.reload();
      //           },
      //         ),
      //       )
      //     : const SizedBox()),
    ],
    // barrierDismissible: false,
    onClose: () async {
      controller.stopTimer();
    },
  );
}
