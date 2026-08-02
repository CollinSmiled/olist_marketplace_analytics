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


def main() -> None:
    csv_files = sorted(RAW_DATA_DIR.glob("*.csv"))

    if not csv_files:
        raise FileNotFoundError(f"No CSV Files found in {RAW_DATA_DIR}")

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

        print()


if __name__ == "__main__":
    main()