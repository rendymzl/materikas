import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../domain/core/entities/sales.dart';
import 'invoice_sales_model.dart';

class SalesModel extends Sales {
  SalesModel({
    super.id,
    super.salesId,
    super.createdAt,
    super.name,
    super.phone,
    super.address,
    super.storeId,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      id: json['id'],
      salesId: json['sales_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      storeId: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['sales_id'] = salesId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    data['store_id'] = storeId;
    return data;
  }

  factory SalesModel.fromRow(sqlite.Row row) {
    return SalesModel(
      id: row['id'],
      salesId: row['sales_id'],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at']).toLocal()
          : null,
      name: row['name'],
      phone: row['phone'],
      address: row['address'],
      storeId: row['store_id'],
    );
  }

  List<InvoiceSalesModel> getInvoiceListBySalesId(
      List<InvoiceSalesModel> salesInvoices) {
    return salesInvoices
        .where((invoice) =>
            invoice.sales.value?.id?.toLowerCase() == id!.toLowerCase())
        .toList();
  }

  double getTotalDebt(List<InvoiceSalesModel> salesInvoices) {
    double totalDebt = getInvoiceListBySalesId(salesInvoices)
        .fold(0, (prev, invoice) => prev + invoice.remainingDebt);

    return totalDebt;
  }
}
