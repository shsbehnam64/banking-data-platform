select transaction_date, channel
from {{ ref('mart_daily_channel_summary') }}
group by transaction_date, channel
having count(*) > 1
