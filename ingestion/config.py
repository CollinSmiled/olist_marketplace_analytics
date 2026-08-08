import os
from dataclasses import dataclass, field
from pathlib import Path

from dotenv import load_dotenv


PROJECT_ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class IngestionConfig:
    host: str
    port: int
    database: str
    user: str
    password: str = field(repr=False)
    raw_data_path: Path


def get_required_environment_variable(name: str) -> str:
    value = os.getenv(name)

    if value is None or not value.strip():
        raise ValueError(
            f"Required environment variable is missing: {name}"
        )

    return value


def load_config() -> IngestionConfig:
    load_dotenv(PROJECT_ROOT / ".env")

    port_text = get_required_environment_variable(
        "POSTGRES_PORT"
    )

    try:
        port = int(port_text)
    except ValueError as error:
        raise ValueError(
            "POSTGRES_PORT must be a valid integer"
        ) from error

    if not 1 <= port <= 65535:
        raise ValueError(
            "POSTGRES_PORT must be between 1 and 65535"
        )

    raw_data_path = Path(
        get_required_environment_variable("RAW_DATA_PATH")
    )

    if not raw_data_path.is_absolute():
        raw_data_path = PROJECT_ROOT / raw_data_path

    raw_data_path = raw_data_path.resolve()

    if not raw_data_path.is_dir():
        raise FileNotFoundError(
            f"Raw-data directory does not exist: {raw_data_path}"
        )

    return IngestionConfig(
        host=get_required_environment_variable("POSTGRES_HOST"),
        port=port,
        database=get_required_environment_variable("POSTGRES_DB"),
        user=get_required_environment_variable("POSTGRES_USER"),
        password=get_required_environment_variable(
            "POSTGRES_PASSWORD"
        ),
        raw_data_path=raw_data_path,
    )