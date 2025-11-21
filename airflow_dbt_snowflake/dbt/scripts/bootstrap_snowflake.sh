#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${PROJECT_ROOT:-/usr/app/dbt}"
cd "$PROJECT_ROOT"

echo "Bootstrapping warehouse schema via dbt run-operation bootstrap_snowflake"
dbt run-operation bootstrap_snowflake "$@"
