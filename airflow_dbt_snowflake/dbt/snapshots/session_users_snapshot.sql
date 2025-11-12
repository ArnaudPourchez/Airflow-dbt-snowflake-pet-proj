{% snapshot session_users_snapshot %}

{{
    config(
        target_database=target.database,
        target_schema=target.schema,
        unique_key='session_id',
        strategy='check',
        check_cols=['user_id', 'event_ts']
    )
}}

select
    session_id,
    user_id,
    event_ts
from {{ ref('stg_events') }}

{% endsnapshot %}
