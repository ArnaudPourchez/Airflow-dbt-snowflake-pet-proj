{{ config(
    materialized='incremental',
    unique_key='event_date',
    incremental_strategy='delete+insert'
) }}

with daily_events as (
    select
        event_date,
        count(distinct session_id) as session_count,
        count(*) as event_count,
        count(distinct user_id) as active_users
    from {{ ref('stg_events') }}
    group by event_date
),
session_stats as (
    select
        session_date as event_date,
        avg(session_duration_seconds) as avg_session_duration_seconds,
        avg(event_count) as avg_events_per_session
    from {{ ref('fct_sessions') }}
    group by session_date
)

select
    e.event_date,
    e.session_count,
    e.event_count,
    e.active_users,
    coalesce(s.avg_session_duration_seconds, 0) as avg_session_duration_seconds,
    coalesce(s.avg_events_per_session, 0) as avg_events_per_session
from daily_events e
left join session_stats s on e.event_date = s.event_date
{% if is_incremental() %}
where e.event_date >= dateadd('day', -7, (select coalesce(max(event_date), to_date('1970-01-01')) from {{ this }}))
{% endif %}
