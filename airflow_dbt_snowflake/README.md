## Airflow + dbt + Snowflake Emulator Stack

This scaffold spins up a fully local analytics stack that emulates Snowflake, runs dbt transformations, and orchestrates pipelines with Airflow running in Celery mode (scheduler + 2 workers + Redis + Postgres). Everything runs inside Docker, so no external cloud resources are required.

The bundled dbt project now models a **video game shop telemetry pipeline**: seeded events capture players purchasing consumable items (ammo, health kits, lamps, etc.) with session-level timestamps, user levels, quantities, and spend. dbt aggregates the raw events into session facts and daily KPIs so you can experiment with commerce-oriented metrics end-to-end inside LocalStack.

### Services
- **LocalStack Snowflake emulator** (`localstack/snowflake:1.3.0`) exposed on `https://snowflake.localhost.localstack.cloud/`
- **dbt CLI** (`ghcr.io/dbt-labs/dbt-snowflake:1.8.7`) mounted to `./dbt`
- **Airflow** (custom image with `dbt-snowflake`): scheduler, webserver (`localhost:8080`), and two Celery workers
- **Airflow metadata DB**: Postgres 15
- **Celery broker**: Redis 7

### Prerequisites
- Docker Engine + Docker Compose Plugin
- No network access is required once the container images are present locally.

### Environment Variables
Default values are baked into `docker-compose.yml`, but you can export overrides before running docker-compose:

```bash
export SNOWFLAKE_ACCOUNT=test
export SNOWFLAKE_USER=test
export SNOWFLAKE_PASSWORD=test
export SNOWFLAKE_ROLE=PUBLIC
export SNOWFLAKE_WAREHOUSE=LOCAL
export SNOWFLAKE_DATABASE=TEST
export SNOWFLAKE_SCHEMA=PUBLIC
```

### Run the stack
```bash
cd airflow_dbt_snowflake
docker compose up -d --build
```
This command starts Snowflake, dbt, Postgres, Redis, plus the Airflow scheduler, webserver, and two workers.

### Develop dbt locally
```bash
docker compose run --rm dbt dbt deps
docker compose run --rm dbt dbt seed --full-refresh
docker compose run --rm dbt dbt build
```

### Airflow tips
- Visit http://localhost:8080 for the Airflow UI.
- Scheduler and workers start automatically. Scale workers via `docker compose up -d --scale airflow-worker-1=0 --scale airflow-worker-2=3` if you want more parallelism.
- Follow logs with `docker compose logs -f airflow-scheduler`.

### Tear down
```bash
docker compose down -v
```
