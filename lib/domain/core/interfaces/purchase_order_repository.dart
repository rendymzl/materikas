import '../../../infrastructure/models/purchase_order_model.dart';

abstract class PurchaseOrderRepository {
  Future<void> subscribe();
  Future<void> insert(PurchaseOrderModel invoice);
  Future<void> update(PurchaseOrderModel updatedInvoice);
  Future<void> delete(String id);
}
