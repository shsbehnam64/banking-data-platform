-- One row per transaction_id: typed, de-duplicated and flagged for quality issues.
with typed as (

    select
        transaction_id,
        account_id,
        cast(transaction_ts as timestamp) as transaction_ts,
        cast(loaded_at as timestamp) as loaded_at,
        direction,
        cast(amount as decimal(18, 2)) as amount,
        currency,
        nullif(trim(channel), '') as channel,
        _source_file,
        _loaded_into_bronze_at_utc
    from {{ ref('bronze_transactions') }}

),

deduplicated as (

    -- keep the first copy received, and record how many copies arrived
    select
        *,
        count(*) over (partition by transaction_id) as source_copy_count
    from typed
    qualify row_number() over (partition by transaction_id order by loaded_at) = 1

)

select
    transaction_id,
    account_id,
    transaction_ts,
    cast(transaction_ts as date) as transaction_date,
    loaded_at,
    direction,
    amount,
    currency,
    coalesce(channel, 'unknown') as channel,
    channel is null as is_channel_missing,
    loaded_at > transaction_ts + interval '{{ var("late_arrival_hours") }} hours' as is_late_arriving,
    source_copy_count,
    _source_file,
    _loaded_into_bronze_at_utc
from deduplicated
