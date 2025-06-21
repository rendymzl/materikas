import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/billing_widget/subs_controller.dart';
import '../global_widget/billing_widget/subs_popup.dart';
import '../global_widget/popup_page_widget.dart';
import 'change_pin_widget.dart';
import 'controllers/pin_controller.dart';
import 'controllers/profile.controller.dart';
import 'detail_profile_store.dart';
import 'logo_widget.dart';

class ProfileStoreWidget extends StatelessWidget {
  const ProfileStoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController controller = Get.find();
    Get.put(PinController());
    return Obx(() {
      controller.selectedImage.value = null;
      controller.croppedImg.value = null;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.account.value!.endDate != null)
                  InkWell(
                    onTap: () {
                      final subsC = Get.put(SubsController());
                      subsC.init();
                      vertical
                          ? Get.toNamed(Routes.TOPUP)
                          : subscriptionPopup();
                    },
                    child: Card(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              print(controller.account.value?.endDate);
                              return Text(
                                'Aktif Sampai: ${dateWihtoutTime.format(controller.account.value!.endDate!)}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              );
                            }),
                            // Text(
                            //   'Token: ${controller.account.value!.token!}',
                            //   style: TextStyle(
                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //       fontSize: 16),
                            // ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Symbols.add,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Divider(color: Colors.grey[200]),
                // if (!vertical)
                ListTile(
                  leading: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => showPopupPageWidget(
                          title: 'Upload Logo',
                          content: Obx(
                            () {
                              return controller.croppedImg.value != null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                              width: 200,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  controller.croppedImg.value!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                    )
                                                  ]),
                                              child: IconButton(
                                                icon: Icon(Icons.close,
                                                    color: Colors.red),
                                                onPressed: () => controller
                                                    .croppedImg.value = null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () =>
                                          controller.pickImage(context),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.cloud_upload,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'Klik untuk memilih file logo',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Format: JPG, PNG (Maks. 2MB) Rasio 1:1',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            },
                          ),
                          buttonList: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Obx(() => ElevatedButton(
                                    onPressed: controller.croppedImg.value ==
                                            null
                                        ? null
                                        : () => controller.uploadLogoHandle(),
                                    child: const Text('Simpan'),
                                  )),
                            ),
                          ]),
                      child: Obx(() {
                        print(
                            'controller.store.value!.logoUrl?.value ${controller.store.value!.logoUrl?.value}');
                        var isExistUrl = controller.store.value!.logoUrl !=
                                null &&
                            controller.store.value!.logoUrl!.value.isNotEmpty;
                        return controller.loadingLogo.value
                            ? Icon(
                                Symbols.store,
                                color: Colors.white,
                              )
                            : CircleAvatar(
                                // radius:
                                //     100, //Tambahkan radius untuk membuat lingkaran
                                backgroundColor: isExistUrl
                                    ? Colors.amber
                                    : Theme.of(context).primaryColor,
                                child: isExistUrl
                                    ? LogoWidget(
                                        store: controller.store.value!,
                                        imgFile: controller.displayImg.value,
                                      )
                                    : Icon(
                                        Symbols.store,
                                        color: Colors.white,
                                      ),
                              );
                      }),
                    ),
                  ),
                  title: Text(controller.store.value!.name.value),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.store.value!.address.value),
                      Row(
                        children: [
                          Text(controller.store.value!.phone.value),
                          if (controller.store.value!.phone.value.isNotEmpty &&
                              controller.store.value!.telp.value.isNotEmpty)
                            Text(' / '),
                          Text(controller.store.value!.telp.value),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => detailStore(
                        foundStore: controller.store.value, isMobile: vertical),
                    icon: Icon(
                      Symbols.edit_square,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => showPopupPageWidget(
                      title: 'Ubah PIN',
                      content: const ChangePinWidget(),
                      buttonList: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => controller.changePinHandle(),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ]),
                  child: const Text('Ubah PIN'),
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     TextButton(
            //       onPressed: () => showPopupPageWidget(
            //           title: 'Ubah PIN',
            //           content: const ChangePinWidget(),
            //           buttonList: [
            //             Expanded(
            //               child: OutlinedButton(
            //                 onPressed: () => Get.back(),
            //                 child: const Text('Batal'),
            //               ),
            //             ),
            //             const SizedBox(width: 12),
            //             Expanded(
            //               child: ElevatedButton(
            //                 onPressed: () => controller.changePinHandle(),
            //                 child: const Text('Simpan'),
            //               ),
            //             ),
            //           ]),
            //       child: const Text('Ubah PIN'),
            //     ),
            //   ],
            // ),
          ],
        ),
      );
    });
  }
}
