select transaction_id, amount
from {{ ref('silver_transactions') }}
where amount <= 0
