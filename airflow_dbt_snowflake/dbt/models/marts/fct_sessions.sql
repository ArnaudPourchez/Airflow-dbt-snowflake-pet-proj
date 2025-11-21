{{ config(materialized='table') }}

with sessions as (
    select
        session_id,
        min(session_start_ts) as session_start,
        max(event_ts) as session_end,
        min(event_date) as session_date,
        max(user_id) as user_id,
        max(user_level) as user_level,
        count(*) as event_count,
        count(distinct item_name) as distinct_items_viewed,
        sum(case when action_type = 'purchase' then quantity else 0 end) as items_purchased,
        sum(case when action_type = 'purchase' then spend_usd else 0 end) as total_revenue
    from {{ ref('stg_events') }}
    group by session_id
)

select
    session_id,
    user_id,
    user_level,
    session_start,
    session_end,
    session_date,
    event_count,
    distinct_items_viewed,
    items_purchased,
    total_revenue,
    coalesce(
        datediff('second', session_start, session_end),
        extract(epoch from session_end) - extract(epoch from session_start),
        0
    ) as session_duration_seconds,
    case when items_purchased > 0 then total_revenue / items_purchased else 0 end as avg_item_value
from sessions
