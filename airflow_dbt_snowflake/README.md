## Airflow + dbt + Snowflake Emulator Stack

! Warning ! This setup IS NOT SUITED FOR PRODUCTION. There are defaults user:passwords in the docker-compose.yml and in the configs. DO NOT EXPOSE ANYTHING from this project on the internet ! This is made to have a LOCAL sandbox. 
AGAIN, DO NOT expose any ports to anything else than localhost.

This scaffold spins up a fully local analytics stack that emulates Snowflake, runs dbt transformations, and orchestrates pipelines with Airflow running in Celery mode (scheduler + 2 workers + Redis + Postgres). Everything runs inside Docker, so no external cloud resources are required.

### Services
- **LocalStack Snowflake emulator** (`localstack/snowflake:1.3.0`) exposed on `localhost:8083`
- **dbt CLI** (`ghcr.io/dbt-labs/dbt-snowflake:1.8.7`) mounted to `./dbt`
- **Airflow** (custom image with `dbt-snowflake`): scheduler, webserver (`localhost:8080`), and two Celery workers
- **Airflow metadata DB**: Postgres 15
- **Celery broker**: Redis 7

### Prerequisites
- Docker Engine + Docker Compose Plugin
- Create a free LocalStack account and save the auth token from there in your .env variables (cf: https://pandeysudhendu.medium.com/localstack-for-snowflake-developing-and-testing-locally-37c55c4cb5d8)
- You will still need to have an internet access as you have to confirm the license with LocalStack.

### Environment Variables
Default values are baked into `docker-compose.yml`, but you can export overrides before running docker compose:

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
- you will need to first open the shell terminal of the Airflow webserver to create an admin user:
  `airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin`
- Visit http://localhost:8080 for the Airflow UI.
- Scheduler and workers start automatically. Scale workers via `docker compose up -d --scale airflow-worker-1=0 --scale airflow-worker-2=3` if you want more parallelism.
- Follow logs with `docker compose logs -f airflow-scheduler`.

### Tear down
```bash
docker compose down -v
```
