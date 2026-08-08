import psycopg

from ingestion.config import IngestionConfig


def create_database_connection(
    config: IngestionConfig,
) -> psycopg.Connection:
    return psycopg.connect(
        host=config.host,
        port=config.port,
        dbname=config.database,
        user=config.user,
        password=config.password,
    )


def check_database_connection(
    config: IngestionConfig,
) -> tuple[str, str, bool]:
    with create_database_connection(config) as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                select
                    current_user,
                    current_database(),
                    exists (
                        select 1
                        from information_schema.schemata
                        where schema_name = 'raw'
                    );
                """
            )

            result = cursor.fetchone()

    if result is None:
        raise RuntimeError(
            "Database connection check returned no result"
        )

    user, database, raw_schema_exists = result

    return (
        str(user),
        str(database),
        bool(raw_schema_exists),
    )