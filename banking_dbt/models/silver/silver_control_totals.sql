select
    cast(transaction_date as date) as transaction_date,
    cast(row_count as integer) as expected_row_count,
    cast(total_amount as decimal(18, 2)) as expected_total_amount,
    _source_file,
    _loaded_into_bronze_at_utc
from {{ ref('bronze_control_totals') }}
