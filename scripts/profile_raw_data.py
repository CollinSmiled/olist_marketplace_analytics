from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

EXPECTED_CSV_FILES = {
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
}

IDENTIFIERS_TO_PROFILE = {
    "olist_customers_dataset.csv": [
        ("customer_id",),
        ("customer_unique_id",),
    ],
    "olist_geolocation_dataset.csv": [
        ("geolocation_zip_code_prefix",),
    ],
    "olist_order_items_dataset.csv": [
        ("order_id",),
        ("order_id", "order_item_id"),
    ],
    "olist_order_payments_dataset.csv": [
        ("order_id",),
        ("order_id", "payment_sequential"),
    ],
    "olist_order_reviews_dataset.csv": [
        ("review_id",),
        ("order_id",),
        ("review_id", "order_id"),
    ],
    "olist_orders_dataset.csv": [
        ("order_id",),
        ("customer_id",),
    ],
    "olist_products_dataset.csv": [
        ("product_id",),
    ],
    "olist_sellers_dataset.csv": [
        ("seller_id",),
    ],
    "product_category_name_translation.csv": [
        ("product_category_name",),
    ],
}

RELATIONSHIPS_TO_PROFILE = [
    (
        "orders.customer_id -> customers.customer_id",
        "olist_orders_dataset.csv",
        "customer_id",
        "olist_customers_dataset.csv",
        "customer_id",
    ),
    (
        "order_items.order_id -> orders.order_id",
        "olist_order_items_dataset.csv",
        "order_id",
        "olist_orders_dataset.csv",
        "order_id",
    ),
    (
        "order_items.product_id -> products.product_id",
        "olist_order_items_dataset.csv",
        "product_id",
        "olist_products_dataset.csv",
        "product_id",
    ),
    (
        "order_items.seller_id -> sellers.seller_id",
        "olist_order_items_dataset.csv",
        "seller_id",
        "olist_sellers_dataset.csv",
        "seller_id",
    ),
    (
        "order_payments.order_id -> orders.order_id",
        "olist_order_payments_dataset.csv",
        "order_id",
        "olist_orders_dataset.csv",
        "order_id",
    ),
    (
        "order_reviews.order_id -> orders.order_id",
        "olist_order_reviews_dataset.csv",
        "order_id",
        "olist_orders_dataset.csv",
        "order_id",
    ),
    (
        "products.category -> category_translation.category",
        "olist_products_dataset.csv",
        "product_category_name",
        "product_category_name_translation.csv",
        "product_category_name",
    ),
]

COVERAGE_CHECKS = [
    (
        "orders without order items",
        "olist_orders_dataset.csv",
        "order_id",
        "olist_order_items_dataset.csv",
        "order_id",
    ),
    (
        "orders without payments",
        "olist_orders_dataset.csv",
        "order_id",
        "olist_order_payments_dataset.csv",
        "order_id",
    ),
    (
        "orders without reviews",
        "olist_orders_dataset.csv",
        "order_id",
        "olist_order_reviews_dataset.csv",
        "order_id",
    ),
    (
        "customers without geolocation coverage",
        "olist_customers_dataset.csv",
        "customer_zip_code_prefix",
        "olist_geolocation_dataset.csv",
        "geolocation_zip_code_prefix",
    ),
    (
        "sellers without geolocation coverage",
        "olist_sellers_dataset.csv",
        "seller_zip_code_prefix",
        "olist_geolocation_dataset.csv",
        "geolocation_zip_code_prefix",
    ),
]

ORDER_COMPONENTS_TO_PROFILE = [
    (
        "order items",
        "olist_order_items_dataset.csv",
    ),
    (
        "payments",
        "olist_order_payments_dataset.csv",
    ),
    (
        "reviews",
        "olist_order_reviews_dataset.csv",
    ),
]

def print_identifier_profiles(
    df: pd.DataFrame,
    file_name: str,
) -> None:
    print("\nIdentifier profiles:")

    for key_columns in IDENTIFIERS_TO_PROFILE[file_name]:
        column_list = list(key_columns)

        distinct_count = int(df[column_list].drop_duplicates().shape[0])
        duplicate_count = int(df.duplicated(subset=column_list).sum())
        null_count = int(df[column_list].isna().any(axis=1).sum())

        is_unique = duplicate_count == 0 and null_count == 0
        uniqueness_status = "unique" if is_unique else "not unique"
        identifier_name = " + ".join(key_columns)

        print(
            f"{identifier_name}: "
            f"\n{distinct_count:,} distinct, "
            f"\n{duplicate_count:,} duplicate rows after first, "
            f"\n{null_count:,} rows containing nulls, "
            f"\n{uniqueness_status}\n"
        )

def load_column(
    file_name: str,
    column_name: str,
) -> pd.Series:
    file_path = RAW_DATA_DIR / file_name

    return pd.read_csv(
        file_path,
        usecols=[column_name],
    )[column_name]


def print_relationship_profiles() -> None:
    print("\nForeign-key relationship profiles:")

    for (
        relationship_name,
        child_file,
        child_column,
        parent_file,
        parent_column,
    ) in RELATIONSHIPS_TO_PROFILE:
        child_values = load_column(child_file, child_column)
        parent_values = load_column(parent_file, parent_column)

        null_child_count = int(child_values.isna().sum())
        non_null_child_values = child_values.dropna()

        parent_value_set = parent_values.dropna().unique()
        orphan_mask = ~non_null_child_values.isin(parent_value_set)
        orphan_values = non_null_child_values[orphan_mask]

        orphan_row_count = int(len(orphan_values))
        orphan_distinct_count = int(orphan_values.nunique())

        status = (
            "valid"
            if orphan_row_count == 0
            else "orphaned values found"
        )

        print(
            f"- {relationship_name}: "
            f"{orphan_row_count:,} orphan rows, "
            f"{orphan_distinct_count:,} distinct orphan values, "
            f"{null_child_count:,} null child values, "
            f"{status}"
        )

def print_coverage_profiles() -> None:
    print("\nReverse coverage profiles:")

    for (
        check_name,
        base_file,
        base_column,
        reference_file,
        reference_column,
    ) in COVERAGE_CHECKS:
        base_values = load_column(base_file, base_column)
        reference_values = load_column(
            reference_file,
            reference_column,
        )

        null_base_count = int(base_values.isna().sum())
        non_null_base_values = base_values.dropna()

        reference_value_set = reference_values.dropna().unique()
        uncovered_mask = ~non_null_base_values.isin(
            reference_value_set
        )
        uncovered_values = non_null_base_values[uncovered_mask]

        uncovered_row_count = int(len(uncovered_values))
        uncovered_distinct_count = int(
            uncovered_values.nunique()
        )

        base_row_count = int(len(non_null_base_values))

        uncovered_percentage = (
            uncovered_row_count / base_row_count * 100
            if base_row_count > 0
            else 0.0
        )

        print(
            f"- {check_name}: "
            f"{uncovered_row_count:,} affected rows, "
            f"{uncovered_distinct_count:,} distinct values, "
            f"{null_base_count:,} null base values, "
            f"{uncovered_percentage:.3f}% uncovered"
        )

def print_missing_order_component_statuses() -> None:
    orders = pd.read_csv(
        RAW_DATA_DIR / "olist_orders_dataset.csv",
        usecols=["order_id", "order_status"],
    )

    print("\nMissing order components by order status:")

    for component_name, component_file in ORDER_COMPONENTS_TO_PROFILE:
        covered_order_ids = load_column(
            component_file,
            "order_id",
        ).dropna().unique()

        missing_orders = orders[
            ~orders["order_id"].isin(covered_order_ids)
        ]

        missing_order_count = int(len(missing_orders))

        print(
            f"\nOrders without {component_name}: "
            f"{missing_order_count:,}"
        )

        if missing_orders.empty:
            continue

        status_counts = missing_orders[
            "order_status"
        ].value_counts(dropna=False)

        for order_status, status_count in status_counts.items():
            status_percentage = (
                status_count / missing_order_count * 100
            )

            print(
                f"- {order_status}: "
                f"{status_count:,} "
                f"({status_percentage:.2f}%)"
            )

def main() -> None:
    csv_files = sorted(RAW_DATA_DIR.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError(f"No CSV files found in {RAW_DATA_DIR}")

    actual_csv_files = {csv_file.name for csv_file in csv_files}

    missing_files = EXPECTED_CSV_FILES - actual_csv_files
    unexpected_files = actual_csv_files - EXPECTED_CSV_FILES

    if missing_files or unexpected_files:
        raise ValueError(
            "Dataset files do not match expectations. "
            f"Missing: {sorted(missing_files)}; "
            f"Unexpected: {sorted(unexpected_files)}"
        )

    print(f"Found {len(csv_files)} CSV files")

    for csv_file in csv_files:
        df = pd.read_csv(csv_file)
        row_count, column_count = df.shape
        duplicate_row_count = int(df.duplicated().sum())
        missing_value_count = int(df.isna().sum().sum())
        missing_by_column = df.isna().sum()
        missing_by_column = missing_by_column[missing_by_column > 0]

        print(
            f"\n{csv_file.name}: "
            f"\n{row_count:,} rows"
            f"\n{column_count} columns"
            f"\n{duplicate_row_count:,} duplicate rows"
            f"\n{missing_value_count:,} missing values\n"
        )

        print("Columns and inferred data types:")

        for column_name, data_type in df.dtypes.items():
            print(f"- {column_name}: {data_type}")

        if not missing_by_column.empty:
            print("\nMissing values by column: ")

            for column_name, missing_count in missing_by_column.items():
                missing_percentage = missing_count / row_count * 100

                print(
                    f"- {column_name}: "
                    f"{missing_count:,} "
                    f"({missing_percentage:.2f}%)"
                )

        print_identifier_profiles(df, csv_file.name)

        print()

    print_relationship_profiles()
    print_coverage_profiles()
    print_missing_order_component_statuses()

if __name__ == "__main__":
    main()
