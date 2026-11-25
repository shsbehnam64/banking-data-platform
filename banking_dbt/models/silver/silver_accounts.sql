select
    account_id,
    customer_id,
    account_type,
    currency,
    cast(opened_date as date) as opened_date,
    status as account_status,
    _source_file,
    _loaded_into_bronze_at_utc
from {{ ref('bronze_accounts') }}
