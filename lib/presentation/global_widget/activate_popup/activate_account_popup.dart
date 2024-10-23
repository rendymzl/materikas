import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/midtrans/midtrans_controller.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../app_dialog_widget.dart';
import '../menu_widget/menu_controller.dart';
import '../popup_page_widget.dart';
import 'activate_account_controller.dart';

void activateAccountPopup({bool expired = false}) async {
  final ActivateAccountController controller =
      Get.put(ActivateAccountController());
  final MidtransController midtransC = Get.put(MidtransController());
  final AuthService authService = Get.find();
  // late final Box<dynamic> box;
  // await Future.delayed(const Duration(seconds: 2));
  // final box = midtransC.box;
  var orderId = authService.box.get('order_id');
  var package = authService.box.get('package');
  // if (package != null) {
  //   midtransC.selectedPackage.value = package;
  // }
  if (orderId != null) {
    await midtransC.checkPaymentStatus(orderId);
    if (midtransC.paymentStatus.value.toLowerCase().contains('kadaluarsa')) {
      midtransC.cancelPayment();
    } else {
      await midtransC.initiatePayment(package);
      // midtransC.startTimer(orderId);
    }
  }
  Color getStatusColor(String status) {
    switch (status) {
      case 'Pembayaran berhasil.':
        return Colors.green;
      case 'Menunggu pembayaran.':
        return Colors.orange;
      case 'Pembayaran ditolak.':
        return Colors.red;
      case 'Pembayaran dibatalkan.':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  showPopupPageWidget(
    barrierDismissible: expired,
    title: midtransC.snap.isEmpty
        ? 'Paket saat ini: ${authService.account.value!.accountType}'
        : 'Pembayaran Upgrade: ${controller.selectedCardType.value}',

    // iconButton: IconButton(
    //     onPressed: () async {
    //       await authService.box.delete('order_id');
    //       await authService.box.delete('snap_token');
    //       await authService.box.delete('package');
    //     },
    //     icon: const Icon(Symbols.body_system)),
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (8 / 11),
    content: Obx(
      () => midtransC.snap.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Pilih Paket:",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                // const SizedBox(height: 10),
                // const Padding(
                //   padding: EdgeInsets.all(8.0),
                //   child: Text(
                //     "Langganan sebelum masa percobaan berakhir untuk mendapatkan potongan harga!",
                //     style: TextStyle(fontStyle: FontStyle.italic),
                //   ),
                // ),
                const SizedBox(height: 10),
                // Menggunakan Row dan Expanded untuk kartu langganan
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: buildSubscriptionCard(
                          package: 'flexible',
                          icon: Symbols.kid_star,
                          title: 'Paket Flexible',
                          ext: '/transaksi',
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildSubscriptionCard(
                          package: 'subscription',
                          icon: Symbols.bookmark_star,
                          title: 'Paket Subscription',
                          ext: '/bulan',
                          index: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildSubscriptionCard(
                          package: 'full',
                          icon: Symbols.award_star,
                          title: 'Paket Business',
                          ext: '/sekali bayar',
                          index: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(Get.context!).size.height * 0.9,
                child: Webview(
                  midtransC.webviewController.value,
                ),
              ),
            ),
    ),
    buttonList: [
      Obx(() {
        return midtransC.snap.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (midtransC.isLoading.value)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed:
                          (controller.selectedCardType.value != 'flexible')
                              ? () => midtransC.initiatePayment(
                                  controller.selectedCardType.value)
                              : expired
                                  ? () => AppDialog.show(
                                        title: 'Konfirmasi',
                                        content: 'Kembali ke paket Flexible?',
                                        confirmText: 'ya',
                                        cancelText: 'batal',
                                        // confirmColor: Colors.grey[200],
                                        // cancelColor: Get.theme.primaryColor,
                                        onConfirm: () async =>
                                            await controller.backToFlexible(),
                                        onCancel: () => Get.back(),
                                      )
                                  : null,
                      child: Text((expired &&
                              controller.selectedCardType.value == 'flexible')
                          ? 'Pilih paket'
                          : 'Bayar'),
                    ),
                ],
              )
            : Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      midtransC.paymentStatus.value,
                      style: TextStyle(
                        color: getStatusColor(midtransC.paymentStatus.value),
                        fontSize: 24,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Theme.of(Get.context!).primaryColor,
                      ),
                      onPressed: () {
                        midtransC.snap.value = '';
                      },
                      child: const Text('Ubah Pilihan Paket'),
                    ),
                    // test
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.grey[800],
                    //     foregroundColor: Theme.of(Get.context!).primaryColor,
                    //   ),
                    //   onPressed: () async {
                    //     await midtransC.onSuccess();
                    //     // Get.back();
                    //   },
                    //   child: const Text('LUNASI TAGIHAN'),
                    // ),
                  ],
                ),
              );
      }),
    ],
  );
}

// Fungsi untuk menampilkan detail benefit langganan
Widget buildSubscriptionCard({
  required String package,
  required IconData icon,
  required String title,
  required String ext,
  required int index,
  // required SubscriptionController controller,
}) {
  final ActivateAccountController controller =
      Get.put(ActivateAccountController());
  // final MenuWidgetController menuC = Get.find();
  final MidtransController midtransC = Get.find();
  return Obx(() {
    // Mengubah warna jika dipilih
    bool isSelected = controller.selectedCardIndex.value == index;
    Color cardColor =
        isSelected ? Theme.of(Get.context!).colorScheme.primary : Colors.white;
    Color textColor = isSelected ? Colors.white : Colors.black;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          controller.handleSelectCard(index);
        },
        child: Container(
          // width: 300, // Atur lebar kartu
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        )),
                    Icon(icon, size: 40, color: textColor),
                  ],
                ),
                Text(
                    midtransC.price[package] is double
                        ? '1% $ext'
                        : 'Rp ${currency.format(midtransC.price[package])} $ext',
                    style: TextStyle(
                      fontSize: 20,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(Get.context!).primaryColor,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      midtransC.price[package] is double
                          ? 'Contoh: Transaksi 10.000 x 1% = Rp. 100'
                          : 'Rp ${currency.format(midtransC.oldPrice[package])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        decoration: midtransC.price[package] is double
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    // SizedBox(width: 8),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       vertical: 4, horizontal: 8),
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(Get.context!).colorScheme.primary,
                    //     borderRadius: BorderRadius.circular(4),
                    //   ),
                    //   child: menuC.countdown,
                    // ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey[100]),
                // Menampilkan detail benefit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: midtransC.features[package]!.map((feature) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            feature['feature'] as String,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...((feature['sub_feature'] as List).map((subFeature) {
                          var item = subFeature['feature'];
                          var isActive = subFeature['active'];
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              children: [
                                isActive
                                    ? Icon(Icons.check,
                                        size: 18, color: textColor)
                                    : Icon(Icons.close,
                                        size: 18, color: Colors.red),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: textColor,
                                      decoration: isActive
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });
}
