import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';

abstract class InvoiceRepository {
  Future<void> subscribe(String storeId);
  Future<List<InvoiceModel>> getByCreatedDate(PickerDateRange pickerDateRange,
      {bool? paid});
  Future<List<InvoiceModel>> getByPaymentDate(DateTime datetime);
  Future<void> insert(InvoiceModel invoice);
  Future<void> update(InvoiceModel updatedInvoice);
  Future<void> delete(String id);
}
