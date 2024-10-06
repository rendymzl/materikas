import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../infrastructure/dal/services/midtrans/midtrans_controller.dart';
import '../popup_page_widget.dart';
import 'activate_account_controller.dart';

void activateAccountPopup() async {
  final ActivateAccountController controller =
      Get.put(ActivateAccountController());
  final MidtransController midtransC = Get.put(MidtransController());

  // late final Box<dynamic> box;
  final box = await Hive.openBox('midtrans');
  var orderId = box.get('order_id');
  if ((orderId?.isNotEmpty ?? false)) {
    midtransC.startTimer(orderId);
  }
  Color getStatusColor(String status) {
    switch (status) {
      case 'Pembayaran berhasil.':
        return Colors.green;
      case 'Pembayaran sedang menunggu konfirmasi.':
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
    title: 'Aktivasi Akun',
    height: MediaQuery.of(Get.context!).size.height * (5 / 7),
    width: MediaQuery.of(Get.context!).size.width * (8 / 11),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Pilih Langganan:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
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
                  price: 'Rp 100.000 per bulan',
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
                  price: 'Rp 1.000.000 per tahun',
                  benefits: [
                    'Fitur full akses',
                    'Diskon 10%',
                    'Support prioritas'
                  ],
                  index: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildSubscriptionCard(
                  icon: Icons.access_time,
                  title: 'Langganan Selamanya',
                  price: 'Rp 2.500.000 sekali bayar',
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
        Obx(
          () => Text(
            midtransC.paymentStatus.value,
            style: TextStyle(
              color: getStatusColor(midtransC.paymentStatus.value),
              fontSize: 24,
            ),
          ),
        ),
      ],
    ),
    buttonList: [
      Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (midtransC.isLoading.value)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  midtransC.initiatePayment();
                },
                child: const Text('Bayar dengan Midtrans'),
              ),
          ],
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
  required List<String> benefits,
  required int index,
  // required SubscriptionController controller,
}) {
  final ActivateAccountController controller = Get.find();
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
