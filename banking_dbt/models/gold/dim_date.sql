with date_range as (

    select
        min(transaction_date) as first_date,
        max(transaction_date) as last_date
    from {{ ref('silver_transactions') }}

),

days as (

    select cast(unnest(generate_series(first_date, last_date, interval 1 day)) as date) as date_day
    from date_range

)

select
    date_day,
    year(date_day) as calendar_year,
    month(date_day) as month_number,
    monthname(date_day) as month_name,
    dayname(date_day) as day_name,
    isodow(date_day) in (6, 7) as is_weekend
from days
