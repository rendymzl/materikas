import 'package:get/get.dart';
import 'package:intl/intl.dart';

final currency = NumberFormat('#,##0', 'id_ID');
final number = NumberFormat.decimalPattern('id');
final date = DateFormat('dd MMMM y, HH:mm', 'id');
final dateWihtoutTime = DateFormat('dd MMMM y', 'id');
final dateShortMonth = DateFormat('dd MMM y, HH:mm', 'id');
final shortDate = DateFormat('dd/MM', 'id');
final dayName = DateFormat('EEE', 'id');

String getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Januari';
    case 2:
      return 'Februari';
    case 3:
      return 'Maret';
    case 4:
      return 'April';
    case 5:
      return 'Mei';
    case 6:
      return 'Juni';
    case 7:
      return 'Juli';
    case 8:
      return 'Agustus';
    case 9:
      return 'September';
    case 10:
      return 'Oktober';
    case 11:
      return 'November';
    case 12:
      return 'Desember';
    default:
      return '';
  }
}

bool vertical = Get.width < 600;
bool windows = GetPlatform.isWindows;
bool android = GetPlatform.isAndroid;
