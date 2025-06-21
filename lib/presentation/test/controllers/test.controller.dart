import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:materikas/infrastructure/dal/services/invoice_service.dart';
import 'package:materikas/infrastructure/dal/services/product_service.dart';
import 'package:materikas/infrastructure/models/invoice_sales_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powersync/powersync.dart' as powersync;

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/customer_model.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/payment_model.dart';
import '../../../infrastructure/models/product_model.dart';
import '../../../infrastructure/models/store_model.dart';

class TestController extends GetxController {
  final authService = Get.put(AuthService());
  final accountService = Get.put(AccountService());
  final storeService = Get.put(StoreService());
  final ProductService productService = Get.put(ProductService());
  final InvoiceService invoiceService = Get.put(InvoiceService());
  // final supabaseClient = Supabase.instance.client;
  // late final account = Rx<AccountModel?>(null);
  // late final store = Rx<StoreModel?>(null);

  late final invoices = <InvoiceModel>[].obs;
  late final invoicesSales = <InvoiceSalesModel>[].obs;
  final isLoading = false.obs;
  // final lenght = 0.obs;
  // final changeCount = 0.obs;

  // final isLoading = false.obs;

  @override
  void onInit() async {
    isLoading.value = true;
    final account = await accountService.get();
    authService.account(account);
    authService.store(await storeService.getStore(account.storeId!));
    productService.subscribe();
    await Future.delayed(Duration(seconds: 3));
    // invoicesSales.value = await getAllInvoicesSales();
    isLoading.value = false;
    super.onInit();
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    final query = '''
      SELECT * FROM invoices
    ''';
    final result = await db.getAll(query);
    final listInvoices = result.map((e) => InvoiceModel.fromJson(e)).toList();
    return listInvoices;
  }

  Future<List<InvoiceSalesModel>> getAllInvoicesSales() async {
    final query = '''
      SELECT * FROM invoices_sales
    ''';
    final result = await db.getAll(query);
    print('paymentsaa0 ${result}');
    final listInvoices =
        result.map((e) => InvoiceSalesModel.fromJson(e)).toList();
    return listInvoices;
  }

  Future<void> insertPayments() async {
    isLoading.value = true;
    invoices.value = await getAllInvoices();
    var paymentList = <PaymentModel>[];
    for (var invoice in invoices) {
      for (var pay in invoice.payments) {
        print('paymentsaa1 ${pay.date}');
        final payment = PaymentModel(
          invoiceId: invoice.invoiceId,
          storeId: invoice.storeId,
          date: pay.date,
          invoiceCreatedAt: invoice.createdAt.value,
          amountPaid: pay.amountPaid,
          finalAmountPaid: pay.finalAmountPaid,
          method: pay.method,
          remain: pay.remain,
          removeAt: invoice.removeAt.value,
        );
        paymentList.add(payment);
      }
    }
    await insertList(paymentList);
    print('paymentLenght berhasil ${paymentList.length}');
    isLoading.value = false;
  }

  Future<void> insertList(List<PaymentModel> paymentList) async {
    final List<List<Object?>> parameterSets = paymentList.map((payment) {
      print('paymentsaa ${payment.toJson()}');
      return [
        payment.invoiceId,
        payment.storeId,
        payment.invoiceCreatedAt!.toIso8601String(),
        payment.date!.toIso8601String(),
        payment.amountPaid,
        payment.method,
        payment.finalAmountPaid,
        payment.remain,
        payment.removeAt?.toIso8601String()
      ];
    }).toList();

    await db.executeBatch(
      '''
    INSERT INTO payments(
      id, invoice_id, store_id, invoice_created_at, date, amount_paid, method, final_amount_paid, remain, remove_at
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }

  Future<void> insertPaymentsSales() async {
    isLoading.value = true;
    invoicesSales.value = await getAllInvoicesSales();
    var paymentList = <PaymentModel>[];
    for (var invoice in invoicesSales) {
      for (var pay in invoice.payments) {
        print('paymentsaa1 ${invoice.invoiceNumber}');
        final payment = PaymentModel(
          invoiceId: invoice.invoiceNumber.toString(),
          storeId: invoice.storeId,
          date: pay.date,
          invoiceCreatedAt: invoice.createdAt.value,
          amountPaid: pay.amountPaid,
          finalAmountPaid: pay.finalAmountPaid,
          method: pay.method,
          remain: pay.remain,
        );
        paymentList.add(payment);
      }
    }
    await insertListSales(paymentList);
    print('paymentLenght berhasil ${paymentList.length}');
    isLoading.value = false;
  }

  Future<void> insertListSales(List<PaymentModel> paymentList) async {
    final List<List<Object?>> parameterSets = paymentList.map((payment) {
      print('paymentsaa ${payment.toJson()}');
      return [
        int.parse(payment.invoiceId!),
        payment.storeId,
        payment.invoiceCreatedAt!.toIso8601String(),
        payment.date!.toIso8601String(),
        payment.amountPaid,
        payment.method,
        payment.finalAmountPaid,
        payment.remain,
        payment.removeAt?.toIso8601String()
      ];
    }).toList();

    await db.executeBatch(
      '''
    INSERT INTO payments_sales(
      id, invoice_number, store_id, invoice_created_at, date, amount_paid, method, final_amount_paid, remain, remove_at
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }

  //!======================================================================================
  final processSequence = 1.obs;
  final isAddExcelLoading = false.obs;
  final processMessage = ''.obs;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      file.value = File(result.files.single.path!);
    }
  }

  Rx<File?> file = Rx<File?>(null);

  Future<void> readAndUploadExcel() async {
    if (file.value == null) return;

    var bytes = file.value!.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Ambil sheet pertama
    Sheet sheet = excel.sheets.values.first;

    var updatedProductList = <InvoiceModel>[];

    isAddExcelLoading.value = true;
    int dataLenght = sheet.rows.skip(1).length;

    // List<InvoiceModel> invoiceList = [];

    for (var row in sheet.rows.skip(1)) {
      processMessage.value =
          'Menambahkan Invoice ke ${processSequence.value} dari $dataLenght';

      String storeId = authService.account.value!.storeId!;

      String? invoiceId = row[0]?.value?.toString();
      Rx<DateTime?> createdAt =
          DateTime.tryParse(row[1]?.value.toString() ?? '').obs;
      String? productName = row[9]?.value?.toString();
      double? quantity =
          double.tryParse(row[12]?.value?.toString() ?? '0') ?? 0;
      double? price = double.tryParse(row[16]?.value?.toString() ?? '0') ?? 0;
      double? totalBill =
          double.tryParse(row[20]?.value?.toString() ?? '0') ?? 0;
      String? paymentType = row[26]?.value?.toString();
      print('product ex ${productName}');

      var product = productService.products.firstWhereOrNull((p) {
        var pName =
            '${p.productName} ${p.unit.isNotEmpty ? '- ${p.unit}' : ''}';
        print('product db ${pName}');
        return productName == pName;
      });

      product ??= ProductModel(
          storeId: storeId,
          productId: 'br${processSequence.value}',
          productName: productName!,
          unit: '',
          costPrice: price.obs,
          sellPrice1: price.obs,
          stock: 10.0.obs,
          stockMin: 10.0.obs);

      Rx<AccountModel> account = Rx(authService.account.value!);

      Rx<CustomerModel> customer =
          Rx(CustomerModel(name: row[11]?.value?.toString() ?? ''));
      CartItem cartItem = CartItem(
        product: product!,
        quantity: quantity,
      );
      // Rx<Cart> purchaseList = Rx(
      //   Cart(
      //     items: <CartItem>[
      //       CartItem(
      //         product: product!,
      //         quantity: quantity,
      //       )
      //     ].obs,
      //   ),
      // );

      var payments = PaymentModel(
        id: powersync.uuid.v4(),
        invoiceId: invoiceId,
        storeId: storeId,
        method: paymentType,
        amountPaid: totalBill,
        remain: 0,
        finalAmountPaid: totalBill,
        date: createdAt.value,
        invoiceCreatedAt: createdAt.value,
      );

      var invoiceExist = updatedProductList
          .firstWhereOrNull((inv) => inv.invoiceId == invoiceId);
      if (invoiceExist != null) {
        invoiceExist.purchaseList.value.items.add(cartItem);
        invoiceExist.payments.add(payments);
      } else {
        var invoice = InvoiceModel(
          storeId: storeId,
          invoiceId: invoiceId,
          account: account.value,
          createdAt: createdAt.value,
          customer: customer.value,
          purchaseList: Cart(
            items:
                <CartItem>[CartItem(product: product, quantity: quantity)].obs,
          ),
          returnList: Cart(items: <CartItem>[].obs),
          priceType: 1,
          discount: 0,
          tax: 0,
          returnFee: 0,
          payments: [payments],
          removeProduct: [],
          debtAmount: 0,
          appBillAmount: 0,
          isDebtPaid: true,
          isAppBillPaid: true,
          initAt: createdAt.value,
        );
        updatedProductList.add(invoice);
      }

      // RxDouble sold =
      //     (double.tryParse(row[1]?.value?.toString() ?? '0') ?? 0).obs;
      // String? productName = row[2]?.value?.toString() ?? '';
      // RxDouble costPrice =
      //     (double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0).obs;
      // RxDouble sellPrice1 =
      //     (double.tryParse(row[4]?.value?.toString() ?? '0') ?? 0).obs;
      // RxDouble sellPrice2 =
      //     (double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0).obs;
      // RxDouble sellPrice3 =
      //     (double.tryParse(row[6]?.value?.toString() ?? '0') ?? 0).obs;
      // RxDouble stock = (double.tryParse(
      //             row[7]?.value?.toString().replaceAll(',', '.') ?? '0') ??
      //         0)
      //     .obs;
      // String? unit = row[8]?.value?.toString() ?? '';
      // RxDouble stockMin =
      //     (double.tryParse(row[9]?.value?.toString() ?? '0') ?? 0).obs;
      // String? imgUrl = row[10]?.value?.toString();
      // String? imageUrl;
      // if (imgUrl != null) {
      //   imageUrl = await uploadImage(null, imgUrl);
      // }

      // var product = ProductModel(
      //   id: powersync.uuid.v4(),
      //   storeId: authService.store.value!.id!,
      //   productId:
      //       'BR${(numberId + processSequence.value).toString().padLeft(4, '0')}',
      //   barcode: barcode,
      //   productName: productName,
      //   unit: unit,
      //   costPrice: costPrice,
      //   sellPrice1: sellPrice1,
      //   sellPrice2: sellPrice2,
      //   sellPrice3: sellPrice3,
      //   stock: stock,
      //   sold: sold,
      //   stockMin: stockMin,
      //   imageUrl: imageUrl,
      // );
      // updatedProductList.add(product);
      processSequence.value++;
    }
    // await invoiceService.insert(updatedProductList);
    // await productService.insertList(updatedProductList);
    print('tambah barang dimulai ${updatedProductList.length} ');
    for (var a in updatedProductList) {
      // print(a.toJson());
      await invoiceService.insert(a);
    }
    processSequence.value = 1;
    processMessage.value = '';
    isAddExcelLoading.value = false;
  }
}
