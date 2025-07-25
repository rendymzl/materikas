import '../../../infrastructure/models/invoice_sales_model.dart';

abstract class InvoiceSalesRepository {
  Future<void> subscribe();
  Future<void> insert(InvoiceSalesModel invoice);
  Future<void> update(InvoiceSalesModel updatedInvoice);
  Future<void> delete(String id);
}
