{{ config(materialized='view') }}

select
    cast(event_id as number(38,0)) as event_id,
    user_id,
    session_id,
    event_type,
    cast(event_ts as timestamp_ntz) as event_ts,
    cast(event_ts as date) as event_date
from {{ ref('events_seed') }}
