class Chart {
  DateTime date;
  String dateString;

  double totalSellPrice;
  double totalReturn;
  double totalChargeReturn;
  double totalDiscount;
  double totalOtherCost;

  double cash;
  double transfer;

  double debtCash;
  double debtTransfer;

  double salesCash;
  double salesTransfer;

  double totalCostPrice;

  double operatingCost;
  int totalInvoice;

  Chart({
    required this.date,
    required this.dateString,
    required this.totalSellPrice,
    required this.totalReturn,
    required this.totalChargeReturn,
    required this.totalDiscount,
    required this.totalOtherCost,
    required this.cash,
    required this.transfer,
    required this.debtCash,
    required this.debtTransfer,
    required this.salesCash,
    required this.salesTransfer,
    required this.totalCostPrice,
    required this.operatingCost,
    required this.totalInvoice,
  });

  // double get totalCash => cash + debtCash + salesCash;

  // double get totalTransfer => transfer + debtTransfer + salesTransfer;

  double get sellPrice =>
      totalSellPrice - totalDiscount + totalOtherCost - finalReturn;

  double get finalReturn => totalReturn - totalChargeReturn;

  double get grossProfit => sellPrice - totalCostPrice;

  double get cleanProfit => grossProfit - operatingCost;

  double get totalDebt => sellPrice - totalPay;

  double get totalPay => cash + transfer;

  double get totalDebtPay => debtCash + debtTransfer;

  double get totalSalesPay => salesCash + salesTransfer;

  double get totalReceiveMoney =>
      totalPay + totalDebtPay - operatingCost - totalSalesPay;

  double get totalReceiveMoneyArca =>
      totalPay + totalDebtPay - operatingCost - salesCash;
}
