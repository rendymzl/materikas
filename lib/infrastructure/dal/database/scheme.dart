import 'package:powersync/powersync.dart';
import 'package:powersync_attachments_helper/powersync_attachments_helper.dart';

const productsTable = 'products';

Schema schema = Schema([
  Table('accounts', [
    Column.text('account_id'),
    Column.text('store_id'),
    Column.text('name'),
    Column.text('email'),
    Column.text('role'),
    Column.text('created_at'),
    Column.text('users'),
    Column.text('password'),
    Column.text('account_type'),
    Column.text('start_date'),
    Column.text('end_date'),
    Column.integer('is_active'),
    Column.text('updated_at'),
    Column.text('affiliate_id'),
    Column.integer('token')
  ]),
  Table('stores', [
    Column.text('owner_id'),
    Column.text('name'),
    Column.text('address'),
    Column.text('phone'),
    Column.text('telp'),
    Column.text('promo'),
    Column.text('created_at'),
    Column.text('logo_url'),
    Column.text('text_print'),
    Column.text('billings')
  ]),
  Table('invoices', [
    Column.text('store_id'),
    Column.text('invoice_id'),
    Column.text('account'),
    Column.text('created_at'),
    Column.text('customer'),
    Column.text('purchase_list'),
    Column.text('return_list'),
    Column.text('after_return_list'),
    Column.integer('price_type'),
    Column.real('discount'),
    Column.real('tax'),
    Column.real('return_fee'),
    Column.text('payments'),
    Column.real('debt_amount'),
    Column.real('app_bill_amount'),
    Column.integer('is_debt_paid'),
    Column.integer('is_app_bill_paid'),
    Column.text('other_costs'),
    Column.text('init_at'),
    Column.text('remove_at'),
    Column.text('remove_product')
  ], indexes: [
    Index('remove', [IndexedColumn('remove_at')]),
    Index('invoice', [
      IndexedColumn('invoice_id'),
      IndexedColumn('customer'),
    ]),
    Index('payment', [IndexedColumn('payments')])
  ]),
  Table('customers', [
    Column.text('store_id'),
    Column.text('customer_id'),
    Column.text('name'),
    Column.text('phone'),
    Column.text('address'),
    Column.text('created_at'),
    Column.text('note_address'),
    Column.real('deposit')
  ]),
  Table('payments', [
    Column.text('invoice_id'),
    Column.text('date'),
    Column.text('remove_at'),
    Column.real('amount_paid'),
    Column.real('remain'),
    Column.real('final_amount_paid'),
    Column.text('store_id'),
    Column.text('invoice_created_at'),
    Column.text('method')
  ], indexes: [
    Index('method_idx', [IndexedColumn('method')]),
    Index('created_at_idx', [IndexedColumn('date')]),
    Index('invoice_id_idx', [IndexedColumn('invoice_id')]),
  ]),
  Table('sales', [
    Column.text('store_id'),
    Column.text('sales_id'),
    Column.text('name'),
    Column.text('phone'),
    Column.text('address'),
    Column.text('created_at')
  ]),
  Table('invoices_sales', [
    Column.text('store_id'),
    Column.text('invoice_number'),
    Column.text('invoice_name'),
    Column.text('created_at'),
    Column.text('sales'),
    Column.text('purchase_list'),
    Column.real('discount'),
    Column.real('tax'),
    Column.text('payments'),
    Column.real('debt_amount'),
    Column.integer('is_debt_paid'),
    Column.text('remove_at'),
    Column.integer('purchase_order')
  ], indexes: [
    Index('invoice_sales', [
      IndexedColumn('invoice_name'),
      IndexedColumn('sales'),
    ]),
    Index('payment_sales_idx', [IndexedColumn('payments')])
  ]),
  Table('payments_sales', [
    Column.text('invoice_number'),
    Column.text('date'),
    Column.text('remove_at'),
    Column.real('amount_paid'),
    Column.real('remain'),
    Column.real('final_amount_paid'),
    Column.text('store_id'),
    Column.text('invoice_created_at'),
    Column.text('method')
  ], indexes: [
    Index('method_sales_idx', [IndexedColumn('method')]),
    Index('created_at_payment_sales_idx', [IndexedColumn('date')]),
    Index('invoice_number_sales_idx', [IndexedColumn('invoice_number')]),
  ]),
  Table('products', [
    Column.text('product_id'),
    Column.text('store_id'),
    Column.text('created_at'),
    Column.text('last_updated'),
    Column.text('image_url'),
    Column.integer('featured'),
    Column.text('product_name'),
    Column.text('unit'),
    Column.text('sales'),
    Column.real('cost_price'),
    Column.real('sell_price1'),
    Column.real('sell_price2'),
    Column.real('sell_price3'),
    Column.real('stock'),
    Column.real('stock_min'),
    Column.real('sold'),
    Column.text('last_sold'),
    Column.text('category'),
    Column.text('attributes'),
    Column.text('barcode')
  ], indexes: [
    // Index('idx_products_id ', [IndexedColumn('id')]),
    Index('idx_products_product_id', [IndexedColumn('product_id')]),
    Index('idx_product_name', [IndexedColumn('product_name')]),
    Index('idx_products_last_updated', [IndexedColumn('last_updated')]),
  ]),
  Table('operating_costs', [
    Column.text('store_id'),
    Column.text('created_at'),
    Column.text('name'),
    Column.integer('amount'),
    Column.text('note')
  ]),
  Table('purchase_orders', [
    Column.text('created_at'),
    Column.text('purchase_order_list'),
    Column.text('order_id'),
    Column.text('store_id'),
    Column.text('sales')
  ]),
  Table('log_stock', [
    Column.text('created_at'),
    Column.text('product_id'),
    Column.text('product_uuid'),
    Column.text('product'),
    Column.text('store_id'),
    Column.text('label'),
    Column.real('amount')
  ], indexes: [
    Index('idx_log_stock_product_uuid', [IndexedColumn('product_uuid')]),
    Index('idx_log_stock_created_at', [IndexedColumn('created_at')]),
    Index('idx_log_stock_label', [IndexedColumn('label')]),
  ]),
  Table('return_items', [
    Column.text('created_at'),
    Column.text('product'),
    Column.real('quantity_return'),
    Column.real('individual_discount'),
    Column.real('return_fee'),
    Column.integer('price_type'),
    Column.text('invoice_id'),
    Column.text('store_id')
  ], indexes: [
    Index('idx_return_items_invoice_id', [IndexedColumn('invoice_id')]),
    Index('idx_return_items_created_at', [IndexedColumn('created_at')]),
  ]),
  AttachmentsQueueTable(
      attachmentsQueueTableName: defaultAttachmentsQueueTableName)
]);
