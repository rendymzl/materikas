import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
// import '../../infrastructure/dal/services/auth_service.dart';
// import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/billing_widget/subs_controller.dart';
import '../global_widget/billing_widget/subs_popup.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/home.controller.dart';
import 'layout/home_horizontal_layout.dart';
import 'layout/home_vertical_layout.dart';

class HomeScreen extends GetView<HomeController> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: vertical ? Colors.white : null,
        appBar: _buildAppBar(context),
        drawer: vertical ? buildDrawer(context) : null,
        body: Column(
          children: [
            if (!vertical) const MenuWidget(title: 'Transaksi'),
            _buildWarningSubs(),
            Obx(
              () {
                if (controller.showPopupSubs.value) {
                  Future.delayed(Duration.zero, () async {
                    final subsC = Get.put(SubsController());
                    subsC.init();
                    subsC.showPopupSubs.value = controller.showPopupSubs.value;
                    vertical
                        ? Get.toNamed(Routes.TOPUP)
                        : await subscriptionPopup();
                  });
                }

                return Expanded(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : vertical
                            ? HomeVerticalLayout(controller: controller)
                            : HomeHorizontalLayout(controller: controller));
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar? _buildAppBar(BuildContext context) {
    if (!vertical) return null;

    return AppBar(
      title: const Text("Transaksi"),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState!.openDrawer(),
      ),
      actions: _buildAppBarActions(context),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      // Obx(() => TextButton.icon(
      //       onPressed: () => Get.toNamed(Routes.TOPUP),
      //       label: Text(
      //         controller.token.value?.toString() ?? 'Unlimited',
      //         style: const TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       icon: const Icon(
      //         Symbols.toll,
      //         color: Colors.white,
      //       ),
      //     ))
    ];
  }

  Widget _buildWarningSubs() {
    return Obx(() {
      if (controller.showWarningSubs.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Langganan anda segera berakhir pada:',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      date.format(controller
                                          .authService.account.value!.endDate!),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                              ),
                              onPressed: () async {
                                final subsC = Get.put(SubsController());
                                subsC.init();
                                vertical
                                    ? Get.toNamed(Routes.TOPUP)
                                    : await subscriptionPopup();
                              },
                              child: const Text('Perpanjang Langganan'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: IconButton(
                    onPressed: () => controller.showWarningSubs.value = false,
                    icon: Icon(Symbols.close, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}
