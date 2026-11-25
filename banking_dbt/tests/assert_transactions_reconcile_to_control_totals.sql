-- Fails for any day where Silver does not match the source control totals.
with actual as (

    select
        transaction_date,
        count(*) as actual_row_count,
        sum(amount) as actual_total_amount
    from {{ ref('silver_transactions') }}
    group by transaction_date

)

select
    transaction_date,
    expected_row_count,
    actual_row_count,
    expected_total_amount,
    actual_total_amount
from {{ ref('silver_control_totals') }}
full outer join actual using (transaction_date)
where expected_row_count is distinct from actual_row_count
   or expected_total_amount is distinct from actual_total_amount
