-- No transaction or money may be lost or duplicated between Silver and the Gold mart.
with silver as (

    select count(*) as row_count, sum(amount) as total_amount
    from {{ ref('silver_transactions') }}

),

gold as (

    select
        sum(transaction_count) as row_count,
        sum(total_debit_amount + total_credit_amount) as total_amount
    from {{ ref('mart_daily_channel_summary') }}

)

select
    silver.row_count as silver_rows,
    gold.row_count as gold_rows,
    silver.total_amount as silver_amount,
    gold.total_amount as gold_amount
from silver
cross join gold
where silver.row_count is distinct from gold.row_count
   or silver.total_amount is distinct from gold.total_amount
