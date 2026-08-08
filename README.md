# Olist Marketplace Analytics

## Project Overview

An analytics and data engineering project using the Brazilian E-Commerce Public Dataset by Olist. The project will transform raw marketplace data into reliable analytical models, business insights, and Power BI dashboards.

## Business Problem

The project investigates why orders are delayed, which sellers are underperforming, and how delivery performance is associated with customer satisfaction.

## Current Status

Milestone 1: dataset understanding and data profiling is in progress.
Milestone 2: source profiling and PostgreSQL raw ingestion completed.

## Planned Technology Stack

- Python for ingestion and data profiling
- PostgreSQL for data storage
- SQL and dbt for transformations and testing
- Power BI for dashboards
- Docker for a reproducible local environment
- Airflow for orchestration at a later stage

## Running Raw Ingestion

1. Place the nine Olist CSV files in `data/raw/`.
2. Create and activate a Python 3.12 virtual environment.
3. Install the dependencies:

   ```powershell
   python -m pip install -r requirements.txt
   ```

4. Copy `.env.example` to `.env` and add your local PostgreSQL credentials:

   ```powershell
   Copy-Item .env.example .env
   ```

5. Run the ingestion pipeline:

   ```powershell
   python -m ingestion.load_raw_data
   ```

The pipeline validates the source files and loads them into the PostgreSQL `raw` schema. Each run performs a transactional full refresh and verifies the loaded row counts.