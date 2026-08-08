import csv
import logging
import psycopg
from psycopg import sql
from pathlib import Path

from ingestion.config import IngestionConfig, load_config
from ingestion.database import create_database_connection


LOGGER = logging.getLogger(__name__)
RAW_SCHEMA = "raw"
COPY_CHUNK_SIZE = 1024 * 1024

TABLE_FILES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "product_category_translation": (
        "product_category_name_translation.csv"
    ),
}

EXPECTED_COLUMNS = {
    "customers": (
        "customer_id",
        "customer_unique_id",
        "customer_zip_code_prefix",
        "customer_city",
        "customer_state",
    ),
    "geolocation": (
        "geolocation_zip_code_prefix",
        "geolocation_lat",
        "geolocation_lng",
        "geolocation_city",
        "geolocation_state",
    ),
    "order_items": (
        "order_id",
        "order_item_id",
        "product_id",
        "seller_id",
        "shipping_limit_date",
        "price",
        "freight_value",
    ),
    "order_payments": (
        "order_id",
        "payment_sequential",
        "payment_type",
        "payment_installments",
        "payment_value",
    ),
    "order_reviews": (
        "review_id",
        "order_id",
        "review_score",
        "review_comment_title",
        "review_comment_message",
        "review_creation_date",
        "review_answer_timestamp",
    ),
    "orders": (
        "order_id",
        "customer_id",
        "order_status",
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ),
    "products": (
        "product_id",
        "product_category_name",
        "product_name_lenght",
        "product_description_lenght",
        "product_photos_qty",
        "product_weight_g",
        "product_length_cm",
        "product_height_cm",
        "product_width_cm",
    ),
    "sellers": (
        "seller_id",
        "seller_zip_code_prefix",
        "seller_city",
        "seller_state",
    ),
    "product_category_translation": (
        "product_category_name",
        "product_category_name_english",
    ),
}

def read_csv_header(csv_path: Path) -> tuple[str, ...]:
    try:
        with csv_path.open(
            mode="r",
            encoding="utf-8-sig",
            newline="",
        ) as csv_file:
            reader = csv.reader(csv_file)
            header = next(reader)
    except StopIteration as error:
        raise ValueError(
            f"CSV file is empty: {csv_path.name}"
        ) from error
    except UnicodeDecodeError as error:
        raise ValueError(
            f"CSV file is not valid UTF-8: {csv_path.name}"
        ) from error

    if not header or any(not column.strip() for column in header):
        raise ValueError(
            f"CSV contains an empty column name: {csv_path.name}"
        )

    if len(header) != len(set(header)):
        raise ValueError(
            f"CSV contains duplicate column names: {csv_path.name}"
        )

    return tuple(header)


def count_csv_rows(csv_path: Path) -> int:
    with csv_path.open(
        mode="r",
        encoding="utf-8-sig",
        newline="",
    ) as csv_file:
        reader = csv.reader(csv_file)

        try:
            next(reader)
        except StopIteration as error:
            raise ValueError(
                f"CSV file is empty: {csv_path.name}"
            ) from error

        return sum(1 for _ in reader)

def load_raw_table(
    connection: psycopg.Connection,
    table_name: str,
    csv_path: Path,
    columns: tuple[str, ...],
) -> int:
    expected_row_count = count_csv_rows(csv_path)

    table_identifier = sql.Identifier(RAW_SCHEMA, table_name)

    column_definitions = sql.SQL(", ").join(
        sql.SQL("{} text").format(sql.Identifier(column))
        for column in columns
    )

    copy_columns = sql.SQL(", ").join(
        sql.Identifier(column) for column in columns
    )

    with connection.cursor() as cursor:
        cursor.execute(
            sql.SQL("CREATE TABLE IF NOT EXISTS {} ({})").format(
                table_identifier,
                column_definitions,
            )
        )

        cursor.execute(
            sql.SQL("TRUNCATE TABLE {}").format(table_identifier)
        )

        copy_statement = sql.SQL(
            "COPY {} ({}) FROM STDIN "
            "WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8')"
        ).format(
            table_identifier,
            copy_columns,
        )

        with cursor.copy(copy_statement) as copy:
            with csv_path.open("rb") as source_file:
                while True:
                    chunk = source_file.read(COPY_CHUNK_SIZE)

                    if not chunk:
                        break

                    copy.write(chunk)

        cursor.execute(
            sql.SQL("SELECT COUNT(*) FROM {}").format(table_identifier)
        )
        result = cursor.fetchone()

    if result is None:
        raise RuntimeError(f"Could not count rows in raw.{table_name}")

    loaded_row_count = int(result[0])

    if loaded_row_count != expected_row_count:
        raise RuntimeError(
            f"Row-count mismatch for raw.{table_name}: "
            f"expected {expected_row_count:,}, "
            f"loaded {loaded_row_count:,}"
        )

    return loaded_row_count


def validate_source_files(
    raw_data_path: Path,
) -> dict[str, Path]:
    expected_file_names = set(TABLE_FILES.values())
    actual_file_names = {
        path.name for path in raw_data_path.glob("*.csv")
    }

    missing_files = expected_file_names - actual_file_names
    unexpected_files = actual_file_names - expected_file_names

    if missing_files:
        raise FileNotFoundError(
            "Required CSV files are missing: "
            f"{sorted(missing_files)}"
        )

    if unexpected_files:
        LOGGER.warning(
            "Ignoring unexpected CSV files: %s",
            sorted(unexpected_files),
        )

    validated_files: dict[str, Path] = {}

    for table_name, file_name in TABLE_FILES.items():
        csv_path = raw_data_path / file_name
        actual_columns = read_csv_header(csv_path)
        expected_columns = EXPECTED_COLUMNS[table_name]

        if actual_columns != expected_columns:
            raise ValueError(
                f"Unexpected columns in {file_name}. "
                f"Expected: {expected_columns}. "
                f"Received: {actual_columns}."
            )

        validated_files[table_name] = csv_path

    return validated_files

def load_all_raw_tables(
    config: IngestionConfig,
    source_files: dict[str, Path],
) -> None:
    with create_database_connection(config) as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                sql.SQL("CREATE SCHEMA IF NOT EXISTS {}").format(
                    sql.Identifier(RAW_SCHEMA)
                )
            )

        for table_name, csv_path in source_files.items():
            LOGGER.info("Loading raw.%s", table_name)

            loaded_row_count = load_raw_table(
                connection=connection,
                table_name=table_name,
                csv_path=csv_path,
                columns=EXPECTED_COLUMNS[table_name],
            )

            LOGGER.info(
                "Loaded raw.%s: %s rows",
                table_name,
                f"{loaded_row_count:,}",
            )

def main() -> None:
    logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s",
)
    config = load_config()

    source_files = validate_source_files(config.raw_data_path)

    LOGGER.info("Validated %s source files", len(source_files))

    load_all_raw_tables(
        config=config,
        source_files=source_files,
    )

    LOGGER.info("Raw ingestion completed successfully")

if __name__ == "__main__":
    main()