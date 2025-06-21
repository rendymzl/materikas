import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../profile/change_pin_widget.dart';
import '../../profile/controllers/pin_controller.dart';
import '../../profile/detail_profile_store.dart';

Future<void> handleSetup() async {
  final authService = Get.find<AuthService>();
  final accountService = Get.find<AccountService>();
  final pinController = Get.put(PinController());

  await detailStore(foundStore: authService.store.value, setup: true);
  await showPopupPageWidget(
    title: 'Pasang PIN',
    content: const ChangePinWidget(setup: true),
    buttonList: [
      Expanded(
        child: ElevatedButton(
          onPressed: pinController.changePinHandle,
          child: const Text('Simpan'),
        ),
      ),
    ],
    barrierDismissible: false,
  );

  final updatedAccount =
      AccountModel.fromJson(authService.account.value!.toJson());
  // updatedAccount.endDate = DateTime.now();
  updatedAccount.updatedAt = DateTime.now().toLocal();
  updatedAccount.accountType = 'subscription';

  // await accountService.insert(updatedAccount);
  await accountService.update(updatedAccount);
  Get.find<InternetService>().onClose();
  Get.offAllNamed(Routes.SPLASH);
}
