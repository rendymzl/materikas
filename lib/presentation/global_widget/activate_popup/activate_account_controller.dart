import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

class ActivateAccountController extends GetxController {
  var selectedCardIndex = 0.obs;
  var isMonthly = true.obs;
  var selectedCardType = 'basic'.obs;

  void handleSelectCard(int index) {
    selectedCardIndex.value = index;
    switch (index) {
      case 0:
        selectedCardType.value = 'basic';
        break;
      case 1:
        selectedCardType.value = 'premium';
        break;
      case 2:
        selectedCardType.value = 'full';
        break;
      default:
        selectedCardType.value = '';
    }
  }

  // Future<void> handleLaunchUrl() async {
  //   if (!await launchUrl(Uri.parse(url.value))) {
  //     throw Exception('Could not launch ${url.value}');
  //   }
  // }
}
