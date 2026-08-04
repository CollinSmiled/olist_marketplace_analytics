# Olist Source Data Profile

## Purpose

This document summarizes the initial profiling of the raw Olist CSV files. The goal was to understand their structure, validate keys and relationships, and identify issues that may affect later analysis.

The raw files remain unchanged. Cleaning and business rules will be applied in later transformation layers.

## Dataset Inventory

- Customers: 99,441 rows and 5 columns
- Geolocation: 1,000,163 rows and 5 columns
- Order items: 112,650 rows and 7 columns
- Payments: 103,886 rows and 5 columns
- Reviews: 99,224 rows and 7 columns
- Orders: 99,441 rows and 8 columns
- Products: 32,951 rows and 9 columns
- Sellers: 3,095 rows and 4 columns
- Category translation: 71 rows and 2 columns

## Confirmed Table Grains

- Customers: one row per `customer_id`
- Orders: one row per `order_id`
- Order items: one row per `order_id` and `order_item_id`
- Payments: one row per `order_id` and `payment_sequential`
- Reviews: unique by `review_id` and `order_id`
- Products: one row per `product_id`
- Sellers: one row per `seller_id`
- Category translation: one row per Portuguese category

`customer_unique_id` is not unique because the same customer can place multiple orders. It should be used for repeat-customer analysis.

## Main Data-Quality Findings

The geolocation file contains 261,831 exact duplicate rows and multiple coordinates for the same ZIP prefix. It must be aggregated to one representative location per ZIP prefix before joining it to customers or sellers.

Review titles are missing for 88.34% of reviews, while review messages are missing for 58.70%. These fields are optional and should not cause the review record to be removed.

A total of 610 products have missing category and descriptive metadata. Two products have missing physical measurements, while four products have a recorded weight of zero.

Two Portuguese product categories are missing from the translation file:

- `portateis_cozinha_e_preparadores_de_alimentos`
- `pc_gamer`

## Relationship and Coverage Checks

All core foreign-key relationships are valid. No orphan records were found between orders, customers, items, products, sellers, payments, and reviews.

Some parent records have no related child records:

- 775 orders have no order items.
- One delivered order has no payment.
- 768 orders have no review.
- 278 customers lack geolocation coverage.
- Seven sellers lack geolocation coverage.

These gaps mean optional data should be joined with left joins to avoid removing valid orders, customers, or sellers.

## Order Lifecycle Issues

Several timestamp and status inconsistencies were identified:

- 166 carrier handoff timestamps occur before purchase.
- 23 customer-delivery timestamps occur before carrier handoff.
- Eight delivered orders lack a customer-delivery timestamp.
- Six non-delivered orders have a customer-delivery timestamp.

Invalid timestamp sequences should be flagged and excluded from duration calculations rather than corrected without evidence.

## Numeric and Payment Checks

No negative monetary values, invalid review scores, parsing failures, or globally invalid coordinates were found.

Other notable cases include:

- 383 order items have zero freight value.
- Nine payment components have zero payment value.
- Two credit-card payments have zero installments.
- Three canceled orders use the payment type `not_defined`.
- Four products have zero recorded weight.

Zero values are not automatically errors, but they require careful treatment in payment, freight, and product analysis.

## Modeling Implications

The project will:

- Preserve the raw source data.
- Aggregate geolocation before joining by ZIP prefix.
- Use `customer_unique_id` for repeat-customer metrics.
- Use left joins for optional order components.
- Add flags for invalid timestamps and incomplete records.
- Avoid calculating durations from invalid timestamp sequences.
- Keep the payment-less order in order and item analysis while excluding it from payment totals.
- Treat untranslated and missing categories explicitly.
- Exclude invalid product weights from weight-based analysis.

## Limitations

The profiling results describe the supplied dataset and do not explain why every source anomaly occurred. Missing values and unusual records will not be corrected unless a clear and documented business rule supports the change.