import 'package:get/get.dart';

import '../../models/billing_model.dart';
import '../../utils/display_format.dart';
import 'auth_service.dart';
import 'invoice_service.dart';
import 'store_service.dart';

class BillingService extends GetxService {
  final InvoiceService invoiceService = Get.find();
  final StoreService storeService = Get.find();
  final AuthService authService = Get.find();

  final thisMonth = DateTime.now().obs;
  final prevMonth = DateTime.now().obs;
  final nextMonth = DateTime.now().obs;
  final selectedMonth = DateTime.now().obs;

  final isLastMonthBillPaid = true.obs;
  final isExpired = false.obs;
  late final billInvoices = invoiceService.monthlyInvoice;
  final billAmount = 0.0.obs;
  final billId = ''.obs;

  @override
  void onInit() {
    _initBilling();
    super.onInit();
  }

// if (authService.account.value!.accountType == 'flexible')
  void _initBilling() async {
    thisMonth.value = DateTime(DateTime.now().year, DateTime.now().month, 1);
    prevMonth.value = thisMonth.value.subtract(Duration(days: 1));
    nextMonth.value = thisMonth.value.add(Duration(days: 1));

    if (authService.store.value!.billings == null) {
      authService.store.value!.billings = <Billing>[].obs;
    }
    if (authService.store.value!.billings!.isNotEmpty) {
      getIsLastMonthBillPaid();

      if (isLastMonthBillPaid.value) {
        var isBillingSet = authService.store.value!.billings?.firstWhereOrNull(
            (bill) => bill.billingName == getMonthName(thisMonth.value.month));

        if (isBillingSet == null) {
          await setThisMonthBilling();
        }
      }

      selectedMonth.value =
          isLastMonthBillPaid.value ? thisMonth.value : prevMonth.value;

      await getBillAmount();

      isExpired.value = !isLastMonthBillPaid.value &&
          DateTime.now().isAfter(
              DateTime(thisMonth.value.year, thisMonth.value.month, 10));
      print('isExpired.value ${isExpired.value}');
    } else {
      // final thisMonthBill = Billing(
      //   billingName: getMonthName(thisMonth.value.month),
      //   billingNumber: invoiceService.generateInvoiceNumber(thisMonth.value),
      //   amountBill: 0.0,
      //   isPaid: false,
      // );
      // authService.store.value!.billings!.add(thisMonthBill);
      // await storeService.update(authService.store.value!);
      await setThisMonthBilling();
    }
  }

  Future<void> setThisMonthBilling() async {
    final thisMonthBill = Billing(
      billingName: getMonthName(thisMonth.value.month),
      billingNumber: invoiceService.generateInvoiceNumber(thisMonth.value),
      amountBill: await getBillAmount(),
      isPaid: false,
    );
    authService.store.value!.billings!.add(thisMonthBill);
    await storeService.update(authService.store.value!);
    await authService.getStore();
    await getBillAmount();
  }

  bool getIsLastMonthBillPaid() {
    var billing = authService.store.value!.billings?.firstWhereOrNull(
        (bill) => bill.billingName == getMonthName(prevMonth.value.month));
    isLastMonthBillPaid.value = billing?.isPaid ?? true;
    return isLastMonthBillPaid.value;
  }

  Future<double> getBillAmount() async {
    var prevBillAmount =
        await invoiceService.getBillAmount(selectedMonth.value);
    var billing = authService.store.value!.billings?.firstWhereOrNull(
        (bill) => bill.billingName == getMonthName(selectedMonth.value.month));
    billId.value = billing?.billingNumber ?? '';
    billAmount.value =
        isLastMonthBillPaid.value ? prevBillAmount : billing?.amountBill ?? 0.0;
    return billAmount.value;
    // return ;
  }

  Future<void> payBill() async {
    var updatetInvoices = billInvoices
        .where((billing) => billing.isAppBillPaid.value == true)
        .toList();

    await invoiceService.updateList(updatetInvoices);

    var billing = authService.store.value!.billings?.firstWhereOrNull(
        (bill) => bill.billingName == getMonthName(selectedMonth.value.month));
    print('billing ${billing}');
    if (billing != null) {
      billing.isPaid = true;
      billing.paymentDate = DateTime.now();
      await storeService.update(authService.store.value!);
      // isExpired.value = false;
    }
  }

  // Future<void> insertBilling() async {
  //   // if (authService.store.value!.billings == null) {
  //   //   authService.store.value!.billings = <Billing>[].obs;
  //   // }

  //   if (DateTime(thisMonth.value.year, thisMonth.value.month).isAfter(DateTime(
  //       authService.store.value!.createdAt.year,
  //       authService.store.value!.createdAt.month))) {
  //     var prevBilling =
  //         authService.store.value!.billings!.firstWhereOrNull((billing) {
  //       return billing.billingName == getMonthName(prevMonth.value.month);
  //     });

  //     if (prevBilling == null) {
  //       var billing = Billing(
  //         billingName: getMonthName(prevMonth.value.month),
  //         billingNumber: invoiceService.generateInvoiceNumber(prevMonth.value),
  //         amountPaid: authService.prevMonthAppBill.value,
  //         isPaid: false,
  //       );
  //       authService.store.value!.billings!.add(billing);
  //       // print('currentBilling $currentBilling');
  //       await storeService.update(authService.store.value!);
  //     }
  //   }

  //   var currentBilling =
  //       authService.store.value!.billings!.firstWhereOrNull((billing) {
  //     return billing.billingName == getMonthName(thisMonth.value.month);
  //   });

  //   if (currentBilling == null) {
  //     var billing = Billing(
  //       billingName: getMonthName(thisMonth.value.month),
  //       billingNumber: invoiceService.generateInvoiceNumber(thisMonth.value),
  //       amountPaid: authService.thisMonthAppBill.value,
  //       isPaid: false,
  //     );
  //     authService.store.value!.billings!.add(billing);
  //     await storeService.update(authService.store.value!);
  //   }
  // }
}
