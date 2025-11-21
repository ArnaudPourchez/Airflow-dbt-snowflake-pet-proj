FROM apache/airflow:2.9.1-python3.10

USER airflow
RUN pip install --no-cache-dir "dbt-postgres==1.9.0"
ENV PATH="${PATH}:/home/airflow/.local/bin"
