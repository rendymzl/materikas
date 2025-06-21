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
    StoreModel? store;
    int retryCount = 0;
    const maxRetries = 5;
    const retryDelay = Duration(seconds: 3);

    while (store == null && retryCount < maxRetries) {
      try {
        final row = await db.get('SELECT * FROM stores WHERE id = ?', [id]);
        store = StoreModel.fromRow(row);
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        } else {
          throw Exception(
              'Gagal mengambil data toko setelah beberapa kali percobaan: $e');
        }
      }
    }
    return store!;
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
        'logo_url': store.logoUrl?.value,
        'text_print': store.textPrint?.map((e) => e).toList(),
      }
    ]);
  }

  Future<void> directInsert(StoreModel store) async {
    await Supabase.instance.client.from('stores').insert([store.toJson()]);
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
      billings = ?, 
      logo_url = ?, 
      text_print = ?, 
      promo = ?
    WHERE id = ?
    ''',
      [
        store.createdAt.toIso8601String(),
        store.name.value,
        store.address.value,
        store.phone.value,
        store.telp.value,
        store.billings?.map((e) => e.toJson()).toList(),
        store.logoUrl?.value,
        store.textPrint?.map((e) => e).toList(),
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
