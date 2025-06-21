import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
// import 'package:webview_windows/webview_windows.dart';

import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'topup_controller.dart';

void topupToken() {
  TopupController controller = Get.put(TopupController());
  showPopupPageWidget(
    title: 'Beli Token',
    height: MediaQuery.of(Get.context!).size.height * (0.75),
    width: MediaQuery.of(Get.context!).size.width * (0.3),
    content: Expanded(
      child: Obx(() {
        var priceList = controller.priceList;
        var selectedPrice = controller.selectedPrice.value;
        return controller.isPaymentExist.value
            ? Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest:
                        URLRequest(url: WebUri(controller.snapUrl.value)),
                    onWebViewCreated: (webViewController) {},
                    onLoadStart: (c, url) {
                      controller.updateLoading(true);
                    },
                    onLoadStop: (c, url) async {
                      controller.updateLoading(false);
                      if (url != null &&
                          url.toString().contains('your-redirect-url')) {
                        Get.back(); // Kembali jika pembayaran selesai
                      }
                    },
                  ),
                  if (controller.isLoading.value)
                    Center(child: CircularProgressIndicator())
                ],
              )
            // Webview(controller.webviewController.value)
            // Text('data')
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 270,
                  // crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: priceList.length,
                itemBuilder: (context, index) {
                  var nominal = priceList[index];
                  return GestureDetector(
                    onTap: () => controller.selectNominal(index),
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: nominal == selectedPrice
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nominal.amount > 200000
                                ? 'PAKET SELAMANYA'
                                : '${currency.format(nominal.amount)} Token',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: nominal == selectedPrice
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nominal.amount > 200000
                                ? 'Menangani transaksi tanpa token'
                                : 'Menangani total transaksi Rp${currency.format(nominal.handleTransaction)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: nominal == selectedPrice
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp${currency.format(nominal.price)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: nominal == selectedPrice
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          if (nominal.note != null) const SizedBox(height: 8),
                          if (nominal.note != null)
                            Text(
                              nominal.note!,
                              style: TextStyle(
                                fontSize: 12,
                                color: nominal == selectedPrice
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
      }),
    ),
    buttonList: [
      Obx(() => controller.isPaymentExist.value
          ? ElevatedButton(
              onPressed: controller.cancelPayment,
              child: Text("Batalkan Pesanan"),
            )
          : ElevatedButton(
              onPressed: controller.confirmPurchase,
              child: Text("Konfirmasi Pembelian"),
            )),
      ElevatedButton(
        onPressed: controller.cancelPayment,
        child: Text("LUNASUN"),
      )
    ],
  );
}
