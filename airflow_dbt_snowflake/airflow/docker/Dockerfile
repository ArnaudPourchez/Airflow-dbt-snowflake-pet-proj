FROM apache/airflow:2.9.1-python3.10

USER airflow
RUN pip install --no-cache-dir "dbt-snowflake==1.8.3"
ENV PATH="${PATH}:/home/airflow/.local/bin"
