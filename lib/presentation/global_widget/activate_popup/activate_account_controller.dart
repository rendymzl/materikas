import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivateAccountController extends GetxController {
  var selectedCardIndex = 0.obs;
  var selectedCardType = ''.obs;
  final url =
      'https://app.sandbox.midtrans.com/payment-links/1728117263496'.obs;

  void handleSelectCard(int index) {
    selectedCardIndex.value = index;
    switch (index) {
      case 0:
        selectedCardType.value = 'monthly';
        break;
      case 1:
        selectedCardType.value = 'yearly';
        break;
      case 2:
        selectedCardType.value = 'full';
        break;
      default:
        selectedCardType.value = '';
    }
  }

  Future<void> handleLaunchUrl() async {
    if (!await launchUrl(Uri.parse(url.value))) {
      throw Exception('Could not launch ${url.value}');
    }
  }
}
