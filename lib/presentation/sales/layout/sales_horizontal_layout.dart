import 'package:flutter/material.dart';

import '../invoice_widget/sales_invoice_list_footer.dart';
import '../invoice_widget/sales_invoice_list_header.dart';
import '../controllers/sales.controller.dart';
import '../sales_list_widget.dart';
import '../invoice_widget/sales_invoice_list_widget.dart';

class SalesHorizontalLayout extends StatelessWidget {
  final SalesController controller;

  const SalesHorizontalLayout({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLeftCard(),
          _buildRightCard(),
        ],
      ),
    );
  }

  Widget _buildLeftCard() {
    return Expanded(
      flex: 3,
      child: Card(
        elevation: 0,
        child: SalesListWidget(
          onSalesTap: (sales) => controller.selectedSalesHandle(
            controller.selectedSales.value == sales ? null : sales,
          ),
        ),
      ),
    );
  }

  Widget _buildRightCard() {
    return Expanded(
      flex: 5,
      child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildHeader(controller),
                _buildBody(controller),
                _buildFooter(controller),
              ],
            ),
          )),
    );
  }

  Widget _buildHeader(SalesController controller) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      color: Colors.white,
      child: Column(
        children: [
          SalesInvoiceListHeader(),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildBody(SalesController controller) {
    return Expanded(child: SalesInvoiceList());
  }

  Widget _buildFooter(SalesController controller) {
    return Container(
      padding: EdgeInsetsDirectional.only(bottom: 16),
      color: Colors.white,
      child: Column(
        children: [
          Divider(color: Colors.grey[300]),
          SalesInvoiceListFooter(),
        ],
      ),
    );
  }
}
