class Chart {
  DateTime date;
  String dateString;

  double totalSellPrice;
  double totalReturn;
  double totalChargeReturn;
  double totalDiscount;

  double cash;
  double transfer;

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
    required this.cash,
    required this.transfer,
    required this.salesCash,
    required this.salesTransfer,
    required this.totalCostPrice,
    required this.operatingCost,
    required this.totalInvoice,
  });

  double get totalCash => cash + salesCash;

  double get totalTransfer => transfer + salesTransfer;

  double get totalPay => cash + transfer;

  double get totalSalesPay => salesCash + salesTransfer;

  double get grossProfit => totalSellPrice - totalCostPrice;

  double get cleanProfit =>
      grossProfit - totalDiscount - operatingCost + totalChargeReturn;

  double get totalDebt =>
      totalSellPrice -
      // totalReturn +
      // totalChargeReturn -
      // totalDiscount -
      totalPay;
}
