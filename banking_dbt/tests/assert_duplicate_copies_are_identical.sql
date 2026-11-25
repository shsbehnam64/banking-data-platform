-- De-duplication is only safe if every copy of a transaction has the same values.
select transaction_id
from (
    select distinct * exclude (_source_file, _loaded_into_bronze_at_utc)
    from {{ ref('bronze_transactions') }}
) as distinct_rows
group by transaction_id
having count(*) > 1
