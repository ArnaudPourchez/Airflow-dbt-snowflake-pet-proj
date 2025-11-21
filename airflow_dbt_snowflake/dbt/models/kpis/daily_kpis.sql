{{ config(
    materialized='incremental',
    unique_key='event_date',
    incremental_strategy='delete+insert'
) }}

with day_sessions as (
    select
        event_date,
        count(distinct session_id) as session_count,
        count(distinct user_id) as active_players
    from {{ ref('stg_events') }}
    group by event_date
),
day_sales as (
    select
        event_date,
        sum(case when action_type = 'purchase' then spend_usd else 0 end) as revenue_usd,
        sum(case when action_type = 'purchase' then quantity else 0 end) as items_sold
    from {{ ref('stg_events') }}
    group by event_date
),
session_stats as (
    select
        session_date as event_date,
        avg(session_duration_seconds) as avg_session_duration_seconds,
        avg(items_purchased) as avg_items_per_session,
        sum(total_revenue) as session_revenue
    from {{ ref('fct_sessions') }}
    group by session_date
)

select
    d.event_date,
    d.session_count,
    d.active_players,
    coalesce(s.avg_session_duration_seconds, 0) as avg_session_duration_seconds,
    coalesce(s.avg_items_per_session, 0) as avg_items_per_session,
    coalesce(sa.revenue_usd, 0) as revenue_usd,
    coalesce(sa.items_sold, 0) as items_sold,
    case when sa.items_sold > 0 then sa.revenue_usd / sa.items_sold else 0 end as avg_item_value,
    coalesce(s.session_revenue, 0) as session_revenue
from day_sessions d
left join day_sales sa on d.event_date = sa.event_date
left join session_stats s on d.event_date = s.event_date
{% if is_incremental() %}
where d.event_date >= dateadd('day', -7, (select coalesce(max(event_date), to_date('1970-01-01')) from {{ this }}))
{% endif %}
