import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global_widget/popup_page_widget.dart';
import 'operating_cost_list.dart';

void detailOperatingCost() {
  showPopupPageWidget(
      title: 'Biaya Operasional',
      height: MediaQuery.of(Get.context!).size.height * (0.9),
      width: MediaQuery.of(Get.context!).size.width * (0.9),
      content: Container(
          color: Colors.amber,
          height: MediaQuery.of(Get.context!).size.height * (0.70),
          width: MediaQuery.of(Get.context!).size.width * (0.9),
          child: const OperatingCostList()),
      buttonList: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ),
        // const SizedBox(width: 8),
        // Expanded(
        //   child: ElevatedButton(
        //     onPressed: () async => await controller.handleSave(foundCustomer),
        //     child: const Text('Simpan'),
        //   ),
        // ),
      ]);
}
