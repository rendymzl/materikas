import '../../../infrastructure/models/sales_model.dart';

abstract class SalesRepository {
  Future<void> subscribe();
  Future<void> insert(SalesModel product);
  Future<void> update(SalesModel updatedProduct);
  Future<void> delete(String id);
}
