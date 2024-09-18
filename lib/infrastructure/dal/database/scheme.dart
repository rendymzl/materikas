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
    Column.text('password')
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
    Column.text('other_costs')
  ]),
  Table('customers', [
    Column.text('store_id'),
    Column.text('customer_id'),
    Column.text('name'),
    Column.text('phone'),
    Column.text('address'),
    Column.text('created_at')
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
    Column.text('barcode'),
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
    Column.real('sold')
  ]),
  Table('operating_costs', [
    Column.text('store_id'),
    Column.text('created_at'),
    Column.text('name'),
    Column.integer('amount'),
    Column.text('note')
  ])
]);
