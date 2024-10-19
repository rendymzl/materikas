import 'package:powersync/sqlite3_common.dart' as sqlite;

class Billing {
  String billingName;
  DateTime? paymentDate;
  String billingNumber;
  double amountBill;
  bool isPaid;

  Billing({
    required this.billingName,
    this.paymentDate,
    required this.billingNumber,
    required this.amountBill,
    required this.isPaid,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      billingName: json['billing_name'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date']).toLocal()
          : null,
      billingNumber: json['billing_number'],
      amountBill: json['amount_bill'],
      isPaid: json['is_paid'],
    );
  }

  factory Billing.fromRow(sqlite.Row row) {
    return Billing(
      billingName: row['billing_name'],
      paymentDate: row['payment_date'] != null
          ? DateTime.parse(row['payment_date']).toLocal()
          : null,
      billingNumber: row['billing_number'],
      amountBill: row['amount_bill'],
      isPaid: row['is_paid'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['billing_name'] = billingName;
    data['payment_date'] = paymentDate?.toIso8601String();
    data['billing_number'] = billingNumber;
    data['amount_bill'] = amountBill;
    data['is_paid'] = isPaid;
    return data;
  }
}
