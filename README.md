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

Copy-Item .env.example .env


Build the ingestion image:

docker compose build ingestion


Start PostgreSQL:

docker compose up -d postgres


Load the raw CSV files:

docker compose run --rm ingestion


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

The staging part cleans and type-casts the nine raw datasets as views in the `warehouse_staging` schema. The build currently includes 9 models and 76 data quality tests.

A warning is logged for 13 products whose original Portuguese category names are missing from the translation table.
