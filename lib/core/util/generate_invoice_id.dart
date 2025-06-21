//! GENERATE INVOICE ===
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../infrastructure/dal/services/invoice_service.dart';
import '../../infrastructure/models/customer_model.dart';
import '../../infrastructure/models/invoice_model/invoice_model.dart';

Future<String> generateInvoiceId(CustomerModel? customer) async {
  late InvoiceService _invoiceService = Get.find();

  String clientCode = customer != null
      ? customer.customerId != null
          ? customer.customerId!.toUpperCase()
          : 'G'
      : 'G';

  DateTime date = DateTime.now();
  PickerDateRange dateRange =
      PickerDateRange(date, date.add(Duration(days: 1)));
  String year = date.year.toString().substring(2);
  String month = date.month.toString().padLeft(2, '0');
  String day = date.day.toString().padLeft(2, '0');
  String hour = date.hour.toString().padLeft(2, '0');
  String minute = date.minute.toString().padLeft(2, '0');
  String second = date.second.toString().padLeft(2, '0');
  String millisecond = date.millisecond.toString().padLeft(3, '0');

  String dateCode = '$clientCode$month$day$year$hour$minute$second$millisecond';

  List<InvoiceModel> result = await _invoiceService.getByCreatedDate(dateRange);
  result = result
      .where((element) => element.invoiceId!.contains('$month$day$year'))
      .toList();

  int lastSerialNumber = result.length;
  lastSerialNumber++;

  String serialNumber = lastSerialNumber.toString().padLeft(3, '0');

  String invoiceNumber = 'INV$serialNumber/$dateCode';

  return invoiceNumber;
}
