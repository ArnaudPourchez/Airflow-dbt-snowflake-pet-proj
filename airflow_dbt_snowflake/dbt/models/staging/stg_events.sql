{{ config(materialized='view') }}

select
    cast(event_id as numeric(38,0)) as event_id,
    cast(user_id as numeric(38,0)) as user_id,
    cast(user_level as numeric(38,0)) as user_level,
    session_id,
    cast(session_start_ts as timestamp) as session_start_ts,
    cast(event_ts as timestamp) as event_ts,
    cast(event_ts as date) as event_date,
    action_type,
    item_name,
    item_category,
    cast(quantity as numeric(38,0)) as quantity,
    cast(spend_usd as numeric(12,2)) as spend_usd
from {{ ref('events_seed') }}
