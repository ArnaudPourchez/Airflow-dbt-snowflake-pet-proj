{#-
Override problematic Snowflake macros so they work against the LocalStack
emulator (which translates to Postgres and is stricter about input types).
-#}

{% macro snowflake__try_to_timestamp(value, format=none, timezone=none) %}
    {#-
        LocalStack fails when Snowflake's TRY_TO_TIMESTAMP receives an already
        typed TIMESTAMP. Casting covers both cases and keeps dbt snapshots happy.
    -#}
    cast({{ value }} as timestamp_ntz)
{% endmacro %}
