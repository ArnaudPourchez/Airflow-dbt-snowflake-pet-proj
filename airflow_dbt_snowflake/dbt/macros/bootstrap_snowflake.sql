{% macro bootstrap_snowflake() %}
    {#-
        Legacy-named helper macro executed via `dbt run-operation bootstrap_snowflake`.
        In the Postgres-based local warehouse, it simply ensures the target schema exists.
    -#}

    {% set schema = var('bootstrap_schema', target.schema) %}
    {% set statements = [
        "create schema if not exists " ~ adapter.quote(schema)
    ] %}

    {% for statement in statements %}
        {% do log("bootstrap_schema: " ~ statement, info=True) %}
        {% do run_query(statement) %}
    {% endfor %}

    {% do log("bootstrap_schema: completed", info=True) %}
{% endmacro %}
