{{ config(materialized='table') }}

with sessions as (
    select
        session_id,
        min(event_ts) as session_start,
        max(event_ts) as session_end,
        count(*) as event_count,
        count(distinct event_type) as distinct_events,
        min(event_date) as session_date
    from {{ ref('stg_events') }}
    group by session_id
)

select
    session_id,
    session_start,
    session_end,
    event_count,
    distinct_events,
    coalesce(
        datediff('second', session_start, session_end),
        extract(epoch from session_end) - extract(epoch from session_start),
        0
    ) as session_duration_seconds,
    session_date
from sessions
