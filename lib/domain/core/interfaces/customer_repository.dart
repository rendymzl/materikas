import '../../../infrastructure/models/customer_model.dart';

abstract class CustomerRepository {
  Future<void> subscribe();
  Future<void> insert(CustomerModel product);
  Future<void> update(CustomerModel updatedProduct);
  Future<void> delete(String id);
}
