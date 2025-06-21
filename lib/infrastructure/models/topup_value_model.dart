class TopupValueModel {
  final int amount;
  final int handleTransaction;
  final int price;
  bool isSelected;
  String? note;

  TopupValueModel(this.amount, this.handleTransaction, this.price,
      {this.isSelected = false, this.note});
}
