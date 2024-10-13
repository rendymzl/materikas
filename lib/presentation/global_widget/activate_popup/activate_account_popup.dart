import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/midtrans/midtrans_controller.dart';
import '../../../infrastructure/utils/display_format.dart';
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
  if (package != null) {
    midtransC.selectedPackage.value = package;
  }
  if (orderId != null) {
    midtransC.startTimer(orderId);
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
    title: 'Aktivasi Akun',
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
                    "Pilih Langganan:",
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
                          icon: Icons.calendar_today,
                          title: 'Langganan Bulanan',
                          price:
                              'Rp ${currency.format(midtransC.packages['monthly'])} per bulan',
                          subPrice: 'Rp 150.000',
                          benefits: [
                            'Fitur full akses',
                            'Support 24/7',
                          ],
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildSubscriptionCard(
                          icon: Icons.calendar_month,
                          title: 'Langganan Tahunan',
                          price:
                              'Rp ${currency.format(midtransC.packages['yearly'])}  per tahun',
                          subPrice: 'Rp 1.800.000',
                          benefits: [
                            'Fitur full akses',
                            'Cukup bayar untuk 10 bulan',
                            'Support prioritas'
                          ],
                          index: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildSubscriptionCard(
                          icon: Icons.access_time,
                          title: 'Selamanya',
                          price:
                              'Rp ${currency.format(midtransC.packages['full'])}  sekali bayar',
                          subPrice: 'Rp 3.500.000',
                          benefits: [
                            'Fitur full akses selamanya',
                            'Sekali bayar akses selamanya',
                            'Support prioritas'
                          ],
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
                      onPressed: () {
                        midtransC
                            .initiatePayment(controller.selectedCardType.value);
                      },
                      child: const Text('Bayar dengan Midtrans'),
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
                      onPressed: () {
                        midtransC.cancelPayment();
                      },
                      child: const Text('Batalkan Pesanan'),
                    ),
                  ],
                ),
              );
      }),
    ],
    onClose: () => midtransC.stopTimer(),
  );
}

// Fungsi untuk menampilkan detail benefit langganan
Widget buildSubscriptionCard({
  required IconData icon,
  required String title,
  required String price,
  required String subPrice,
  required List<String> benefits,
  required int index,
  // required SubscriptionController controller,
}) {
  final ActivateAccountController controller =
      Get.put(ActivateAccountController());
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
                Icon(icon, size: 40, color: textColor),
                const SizedBox(height: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                Text(price, style: TextStyle(fontSize: 18, color: textColor)),
                Text(
                  subPrice,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 10),
                // Menampilkan detail benefit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: benefits.map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 18, color: textColor),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
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
