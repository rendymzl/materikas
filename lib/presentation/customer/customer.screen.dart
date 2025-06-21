import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/customer.controller.dart';
import 'customer_list.dart';
import 'customer_list_mobile.dart';
import 'detail_customer/detail_customer.dart';

class CustomerScreen extends GetView<CustomerController> {
  const CustomerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // final OtpController otpC = Get.put(OtpController()); //test
    // final BillingController billingC = Get.put(BillingController()); //test

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: vertical ? Colors.white : null,
        appBar: vertical
            ? AppBar(
                title: const Text("Pelanggan"),
                centerTitle: true,
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              )
            : null,
        drawer: vertical ? buildDrawer(context) : null,
        body: Column(
          children: [
            // billingC.buildHiddenReceipt(),//test
            if (!vertical) const MenuWidget(title: 'Pelanggan'),
            Expanded(
              child: vertical
                  ? buildMobileLayout(context)
                  : buildDesktopLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk tampilan desktop
  Widget buildDesktopLayout(BuildContext context) {
    // controller.vertical.value = false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: CustomerList()),
            Padding(
              padding: const EdgeInsets.all(16),
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
                              // ElevatedButton(
                              //   onPressed: () => addCustFromExcel(),
                              //   child: const Text('Tambah dari Excel'),
                              // ),
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
    );
  }

  // Fungsi untuk tampilan mobile
  Widget buildMobileLayout(BuildContext context) {
    // controller.vertical.value = true;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: CustomerListMobile()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  'Total Pelanggan: ${controller.customers.length.toString()}',
                  style: context.textTheme.bodySmall,
                ),
              ),
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
        ],
      ),
    );
  }
}
