// class Chart {
//   DateTime date;
//   String dateString;

//   double totalSellPrice;
//   double totalSellPriceSales;
//   double totalReturn;
//   double totalChargeReturn;
//   double totalDiscount;
//   double totalDiscountSales;
//   double totalOtherCost;

//   double cash;
//   double transfer;
//   double deposit;

//   double debtCash;
//   double debtTransfer;

//   double salesCash;
//   double salesTransfer;

//   double totalCostPrice;

//   double operatingCost;
//   int totalInvoice;
//   int totalInvoiceSales;

//   Chart({
//     required this.date,
//     required this.dateString,
//     required this.totalSellPrice,
//     required this.totalSellPriceSales,
//     required this.totalReturn,
//     required this.totalChargeReturn,
//     required this.totalDiscount,
//     required this.totalDiscountSales,
//     required this.totalOtherCost,
//     required this.cash,
//     required this.transfer,
//     required this.deposit,
//     required this.debtCash,
//     required this.debtTransfer,
//     required this.salesCash,
//     required this.salesTransfer,
//     required this.totalCostPrice,
//     required this.operatingCost,
//     required this.totalInvoice,
//     required this.totalInvoiceSales,
//   });

//   double get sellPrice =>
//       totalSellPrice - totalDiscount + totalOtherCost - finalReturn;

//   double get sellPriceSales => totalSellPriceSales - totalDiscountSales;

//   double get finalReturn => totalReturn - totalChargeReturn;

//   double get grossProfit => sellPrice - totalCostPrice;

//   double get cleanProfit => grossProfit - operatingCost;

//   double get totalDebt => sellPrice - totalPay;

//   double get totalPay => cash + transfer + deposit;

//   double get totalDebtPay => debtCash + debtTransfer;

//   double get totalSalesPay => salesCash + salesTransfer;

//   double get totalReceiveMoney =>
//       totalPay + totalDebtPay - operatingCost - totalSalesPay - deposit;
//   double get totalReceiveMoneyArca =>
//       totalPay + totalDebtPay - operatingCost - salesCash;

//   double get totalReceiveTransfer => transfer + debtTransfer;
//   double get totalReceiveTransferArca => transfer + debtTransfer;

//   double get totalReceiveCash => totalReceiveMoney - totalReceiveTransfer;
//   double get totalReceiveCashArca =>
//       totalReceiveMoneyArca - totalReceiveTransferArca;
// }
