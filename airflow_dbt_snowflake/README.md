## Airflow + dbt + Postgres Warehouse Stack

This scaffold spins up a fully local analytics stack backed by Postgres, runs dbt transformations, and orchestrates pipelines with Airflow running in Celery mode (scheduler + 2 workers + Redis + Postgres). Everything runs inside Docker, so no external cloud resources are required.

The bundled dbt project models a **video game shop telemetry pipeline**: seeded events capture players purchasing consumable items (ammo, health kits, lamps, etc.) with session-level timestamps, user levels, quantities, and spend. dbt aggregates the raw events into session facts and daily KPIs so you can experiment with commerce-oriented metrics end-to-end against a Postgres warehouse.

### Services
- **Analytics warehouse**: Postgres 15 (`analytics-db`, exposed on `localhost:5433`)
- **dbt CLI** (`ghcr.io/dbt-labs/dbt-postgres:1.8.3`) mounted to `./dbt`
- **Airflow** (custom image with `dbt-postgres`): scheduler, webserver (`localhost:8080`), and two Celery workers
- **Airflow metadata DB**: Postgres 15
- **Celery broker**: Redis 7
- **CloudBeaver** (`localhost:8978`) to practice SQL via JDBC (Snowflake driver jar mounted for completeness, but Postgres works out of the box)

### Prerequisites
- Docker Engine + Docker Compose Plugin
- Internet access for the initial image/driver downloads

### Environment Variables
Default values are baked into `docker-compose.yml`, but you can export overrides before running docker compose:

```bash
export WAREHOUSE_HOST=analytics-db
export WAREHOUSE_PORT=5432
export WAREHOUSE_USER=game
export WAREHOUSE_PASSWORD=gamepass
export WAREHOUSE_DB=game_warehouse
export WAREHOUSE_SCHEMA=public
```

### Run the stack
```bash
cd airflow_dbt_snowflake
docker compose up -d --build
```
This command starts the analytics Postgres warehouse, dbt, the Airflow metadata Postgres instance, Redis, plus the Airflow scheduler, webserver, and two workers.

### Develop dbt locally
```bash
docker compose run --rm dbt dbt deps
docker compose run --rm dbt dbt seed --full-refresh
docker compose run --rm dbt dbt build
```

### Airflow tips
- you will need to first open the shell terminal of the Airflow webserver to create an admin user:
  `airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin`
- Visit http://localhost:8080 for the Airflow UI.
- Scheduler and workers start automatically. Scale workers via `docker compose up -d --scale airflow-worker-1=0 --scale airflow-worker-2=3` if you want more parallelism.
- Follow logs with `docker compose logs -f airflow-scheduler`.

### Tear down
```bash
docker compose down -v
```
