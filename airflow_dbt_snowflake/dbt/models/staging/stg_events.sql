{{ config(materialized='view') }}

select
    cast(event_id as number(38,0)) as event_id,
    cast(user_id as number(38,0)) as user_id,
    cast(user_level as number(38,0)) as user_level,
    session_id,
    cast(session_start_ts as timestamp_ntz) as session_start_ts,
    cast(event_ts as timestamp_ntz) as event_ts,
    cast(event_ts as date) as event_date,
    action_type,
    item_name,
    item_category,
    cast(quantity as number(38,0)) as quantity,
    cast(spend_usd as number(12,2)) as spend_usd
from {{ ref('events_seed') }}
