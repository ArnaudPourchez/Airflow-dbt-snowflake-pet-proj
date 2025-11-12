{% macro bootstrap_snowflake() %}
    {#-
        Helper macro executed via `dbt run-operation bootstrap_snowflake`
        to provision the warehouse/database/schema and grants required by
        the local Snowflake emulator.
    -#}

    {% set warehouse = var('bootstrap_snowflake_warehouse', target.warehouse) %}
    {% set database = var('bootstrap_snowflake_database', target.database) %}
    {% set schema = var('bootstrap_snowflake_schema', target.schema) %}
    {% set role = var('bootstrap_snowflake_role', 'PUBLIC') %}
    {% set user = var('bootstrap_snowflake_user', target.user | default('TEST')) %}

    {% set statements = [
        "create warehouse if not exists " ~ adapter.quote(warehouse) ~ " with warehouse_size = 'XSMALL' auto_suspend = 60 auto_resume = true initially_suspended = true",
        "create database if not exists " ~ adapter.quote(database),
        "create schema if not exists " ~ adapter.quote(database) ~ "." ~ adapter.quote(schema),
        "grant usage on warehouse " ~ adapter.quote(warehouse) ~ " to role " ~ adapter.quote(role),
        "grant usage on database " ~ adapter.quote(database) ~ " to role " ~ adapter.quote(role),
        "grant usage on schema " ~ adapter.quote(database) ~ "." ~ adapter.quote(schema) ~ " to role " ~ adapter.quote(role),
        "grant all privileges on schema " ~ adapter.quote(database) ~ "." ~ adapter.quote(schema) ~ " to role " ~ adapter.quote(role),
        "grant role " ~ adapter.quote(role) ~ " to user " ~ adapter.quote(user)
    ] %}

    {% for statement in statements %}
        {% do log("bootstrap_snowflake: " ~ statement, info=True) %}
        {% do run_query(statement) %}
    {% endfor %}

    {% do log("bootstrap_snowflake: completed", info=True) %}
{% endmacro %}
