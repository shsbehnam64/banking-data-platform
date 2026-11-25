-- Data minimisation: names, email and full postcode are deliberately left out.
select
    customer_id,
    city,
    split_part(postcode, ' ', 1) as postcode_district,
    created_date as customer_since
from {{ ref('silver_customers') }}
