import 'package:get/get.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/navigation/routes.dart';
// import 'package:url_launcher/url_launcher.dart';

class ActivateAccountController extends GetxController {
  AccountService accountSecvice = Get.find();
  AuthService authC = Get.find();
  var selectedCardIndex = 0.obs;
  // var isMonthly = true.obs;
  var selectedCardType = 'flexible'.obs;

  void handleSelectCard(int index) {
    selectedCardIndex.value = index;
    switch (index) {
      case 0:
        selectedCardType.value = 'flexible';
        break;
      case 1:
        selectedCardType.value = 'subscription';
        break;
      case 2:
        selectedCardType.value = 'full';
        break;
      default:
        selectedCardType.value = '';
    }
  }

  Future<void> backToFlexible() async {
    authC.account.value!.accountType = 'flexible';
    authC.account.value!.endDate = null;
    await accountSecvice.update(authC.account.value!);
    Get.offAllNamed(Routes.SPLASH);
  }

  // Future<void> handleLaunchUrl() async {
  //   if (!await launchUrl(Uri.parse(url.value))) {
  //     throw Exception('Could not launch ${url.value}');
  //   }
  // }
}
