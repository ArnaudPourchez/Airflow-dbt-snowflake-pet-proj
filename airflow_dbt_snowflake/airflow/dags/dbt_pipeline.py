"""Airflow DAG that orchestrates dbt commands against the local Postgres warehouse."""

from __future__ import annotations

import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


DEFAULT_ENV = {
    "WAREHOUSE_HOST": os.environ.get("WAREHOUSE_HOST", "analytics-db"),
    "WAREHOUSE_PORT": os.environ.get("WAREHOUSE_PORT", "5432"),
    "WAREHOUSE_USER": os.environ.get("WAREHOUSE_USER", "game"),
    "WAREHOUSE_PASSWORD": os.environ.get("WAREHOUSE_PASSWORD", "gamepass"),
    "WAREHOUSE_DB": os.environ.get("WAREHOUSE_DB", "game_warehouse"),
    "WAREHOUSE_SCHEMA": os.environ.get("WAREHOUSE_SCHEMA", "public"),
    "DBT_PROFILES_DIR": os.environ.get("DBT_PROFILES_DIR", "/opt/airflow/dbt"),
    "DBT_PROJECT_DIR": os.environ.get("DBT_PROJECT_DIR", "/opt/airflow/dbt"),
    "DBT_PARTIAL_PARSE": os.environ.get("DBT_PARTIAL_PARSE", "0"),
    "DBT_TARGET_PATH": os.environ.get("DBT_TARGET_PATH", "/tmp/dbt_target"),
    "PATH": os.environ.get("PATH", "/home/airflow/.local/bin:/usr/local/bin:/usr/bin:/bin"),
}

DBT_DIR = DEFAULT_ENV["DBT_PROJECT_DIR"]
BASH_PREFIX = f"cd {DBT_DIR} && set -euo pipefail && "

default_args = {
    "owner": "data-eng",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="dbt_daily_build",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 2 * * *",
    catchup=False,
    tags=["dbt", "postgres"],
) as dag:
    dbt_bootstrap = BashOperator(
        task_id="dbt_bootstrap",
        bash_command=BASH_PREFIX + "dbt run-operation bootstrap_snowflake",
        env=DEFAULT_ENV,
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=BASH_PREFIX + "dbt deps",
        env=DEFAULT_ENV,
    )

    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=BASH_PREFIX + "dbt seed --full-refresh",
        env=DEFAULT_ENV,
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=BASH_PREFIX + "dbt build",
        env=DEFAULT_ENV,
    )

    dbt_bootstrap >> dbt_deps >> dbt_seed >> dbt_build
