import '../../../infrastructure/models/invoice_model/invoice_model.dart';

abstract class InvoiceRepository {
  Future<void> subscribe(String storeId);
  Future<void> insert(InvoiceModel invoice);
  Future<void> update(InvoiceModel updatedInvoice);
  Future<void> delete(String id);
}
