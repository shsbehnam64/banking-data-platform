-- Grain: one row per day and channel. Feeds the dashboard.
select
    transaction_date,
    channel,
    count(*) as transaction_count,
    sum(case when direction = 'debit' then amount else 0 end) as total_debit_amount,
    sum(case when direction = 'credit' then amount else 0 end) as total_credit_amount,
    sum(signed_amount) as net_amount,
    count(*) filter (where is_late_arriving) as late_transaction_count
from {{ ref('fct_transactions') }}
group by transaction_date, channel
