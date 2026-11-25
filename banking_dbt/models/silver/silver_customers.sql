select
    customer_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    lower(trim(email)) as email,
    city,
    postcode,
    cast(created_date as date) as created_date,
    cast(updated_at as timestamp) as updated_at,
    _source_file,
    _loaded_into_bronze_at_utc
from {{ ref('bronze_customers') }}
