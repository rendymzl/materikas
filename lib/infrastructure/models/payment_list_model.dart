import 'invoice_model/invoice_model.dart';
import 'invoice_sales_model.dart';

class PaymentArgsModel {
  bool? isEdit;
  bool? onlyPayment;
  InvoiceModel? invoice;

  PaymentArgsModel({
    this.isEdit,
    this.onlyPayment,
    this.invoice,
  });
}

class PaymentArgsSalesModel {
  bool? isEdit;
  bool? onlyPayment;
  InvoiceSalesModel? invoice;

  PaymentArgsSalesModel({
    this.isEdit,
    this.onlyPayment,
    this.invoice,
  });
}
