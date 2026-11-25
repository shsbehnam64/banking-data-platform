select
    account_id,
    customer_id,
    account_type,
    currency,
    opened_date,
    account_status
from {{ ref('silver_accounts') }}
