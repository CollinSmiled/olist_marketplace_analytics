# Olist Marketplace Analytics

## Project Overview

An analytics and data engineering project using the Brazilian E-Commerce Public Dataset by Olist. The project will transform raw marketplace data into reliable analytical models, business insights, and Power BI dashboards.

## Business Problem

The project investigates why orders are delayed, which sellers are underperforming, and how delivery performance is associated with customer satisfaction.

## Current Status

- Milestone 1: dataset understanding and source profiling
- Milestone 2: PostgreSQL raw ingestion
- Milestone 3: Dockerized PostgreSQL and ingestion
- Milestone 4: dbt source definitions, staging models, and data quality tests
- Milestone 5: reusable intermediate models and order-level processing
- Milestone 6: dimensional warehouse with four dimensions and two fact tables

## Planned Technology Stack

- Python for ingestion and data profiling
- PostgreSQL for data storage
- SQL and dbt for transformations and testing
- Power BI for dashboards
- Docker for a reproducible local environment
- Airflow for orchestration at a later stage

## Running Raw Ingestion

### Prerequisites

- Docker Desktop
- The nine Olist CSV files placed in `data/raw/`

### Setup

Copy the environment template and add your PostgreSQL password:

```powershell
Copy-Item .env.example .env
```

Build the ingestion image:

```powershell
docker compose build ingestion
```

Start PostgreSQL:

```powershell
docker compose up -d postgres
```

Load the raw CSV files:

```powershell
docker compose run --rm ingestion
```

The ingestion pipeline validates the source files, performs a transactional full refresh, and verifies the loaded row counts.

## Running dbt

Build the dbt image:

```powershell
docker compose build dbt
```

Verify the dbt configuration and database connection:

```powershell
docker compose run --rm dbt debug
```

Build and test the transformation project:

```powershell
docker compose run --rm dbt build
```

The dbt project builds nine cleaned and typed staging views in `warehouse_staging`, five intermediate views in `warehouse_intermediate`, and six dimensional tables in `warehouse_marts`. The complete build contains 20 models and 206 data quality tests.

A warning is logged for 13 products whose original Portuguese category names are missing from the translation table.

## Warehouse Design

The reporting layer uses a fact constellation with two grains:

- `fct_orders`: one row per order
- `fct_order_items`: one row per order item

![Olist warehouse conceptual schema](docs/diagrams/warehouse_schema_conceptual.png)

See [Warehouse Design](docs/warehouse_design.md) for the detailed schema.