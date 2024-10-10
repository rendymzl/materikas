import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/store_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/store_repository.dart';
import '../database/powersync.dart';

class StoreService extends GetxService implements StoreRepository {
  final supabaseClient = Supabase.instance.client;
  late final stores = Rx<StoreModel?>(null);

  @override
  Future<StoreModel> getStore(id) async {
    final response =
        await supabaseClient.from('stores').select().eq('owner_id', id);
    if (response.isNotEmpty) {
      stores.value = StoreModel.fromJson(response[0]);
    }
    return stores.value!;
  }

  @override
  Future<void> insert(StoreModel store) async {
    await supabaseClient.from('stores').insert([
      {
        // 'id': store.id,
        'created_at': store.createdAt.toIso8601String(),
        'name': store.name.value,
        'address': store.address.value,
        'phone': store.phone.value,
        'telp': store.telp.value,
        'promo': store.promo?.value,
        'owner_id': store.ownerId,
      }
    ]);
  }

  @override
  Future<void> update(StoreModel store) async {
    await db.execute(
      '''
    UPDATE stores SET
      created_at = ?, 
      name = ?, 
      address = ?, 
      phone = ?, 
      telp = ?, 
      promo = ?
    WHERE id = ?
    ''',
      [
        store.createdAt.toIso8601String(),
        store.name.value,
        store.address.value,
        store.phone.value,
        store.telp.value,
        store.promo?.value,
        store.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      'DELETE FROM stores WHERE id = ?',
      [id],
    );
  }
}
