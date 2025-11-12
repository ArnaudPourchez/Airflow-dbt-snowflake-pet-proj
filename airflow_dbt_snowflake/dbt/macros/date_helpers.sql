{% macro beginning_of_week(date_col) %}
    date_trunc('week', {{ date_col }})
{% endmacro %}
