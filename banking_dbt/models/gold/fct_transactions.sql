-- Grain: one row per transaction.
select
    t.transaction_id,
    t.account_id,
    a.customer_id,
    t.transaction_date,
    t.transaction_ts,
    t.direction,
    t.channel,
    t.amount,
    case when t.direction = 'debit' then -t.amount else t.amount end as signed_amount,
    t.is_late_arriving,
    t.is_channel_missing
from {{ ref('silver_transactions') }} as t
left join {{ ref('silver_accounts') }} as a
    on t.account_id = a.account_id
