import 'package:powersync/powersync.dart';

const schema = Schema([
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
    Column.text('updated_at')
  ]),
  Table('stores', [
    Column.text('owner_id'),
    Column.text('name'),
    Column.text('address'),
    Column.text('phone'),
    Column.text('telp'),
    Column.text('promo'),
    Column.text('created_at')
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
    Column.integer('is_debt_paid'),
    Column.text('other_costs'),
    Column.text('init_at'),
    Column.text('remove_at'),
    Column.text('remove_product')
  ]),
  Table('customers', [
    Column.text('store_id'),
    Column.text('customer_id'),
    Column.text('name'),
    Column.text('phone'),
    Column.text('address'),
    Column.text('created_at'),
    Column.text('note_address')
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
    Column.text('invoice_id'),
    Column.text('created_at'),
    Column.text('sales'),
    Column.text('purchase_list'),
    Column.real('discount'),
    Column.real('tax'),
    Column.text('payments'),
    Column.real('debt_amount'),
    Column.integer('is_debt_paid')
  ]),
  Table('products', [
    Column.text('product_id'),
    Column.text('store_id'),
    Column.text('created_at'),
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
    Column.text('barcode')
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
  ])
]);
