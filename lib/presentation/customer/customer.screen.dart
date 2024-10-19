import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:materikas/presentation/global_widget/billing_widget/billing_controller.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import '../global_widget/otp/otp_controller.dart';
import 'controllers/customer.controller.dart';
import 'customer_list.dart';
import 'detail_customer/detail_customer.dart';

class CustomerScreen extends GetView<CustomerController> {
  const CustomerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // final OtpController otpC = Get.put(OtpController()); //test
    // final BillingController billingC = Get.put(BillingController()); //test
    return Scaffold(
      body: Column(
        children: [
          // billingC.buildHiddenReceipt(),//test
          const MenuWidget(title: 'Pelanggan'),
          Expanded(
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: CustomerList()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              'Total Pelanggan: ${controller.customers.length.toString()}',
                              style: context.textTheme.bodySmall,
                            )),
                        Obx(() {
                          return controller.addCustomer.value
                              ? Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => detailCustomer(),
                                      child: const Text('Tambah Pelanggan'),
                                    ),
                                    // ElevatedButton(
                                    //   onPressed: () => otpC.test(),//test
                                    //   child: const Text('tes'),
                                    // ),
                                  ],
                                )
                              : const SizedBox();
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
