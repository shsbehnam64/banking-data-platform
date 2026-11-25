{#- Bronze keeps source data as received (all text) and adds lineage columns. -#}
{% macro bronze_load(table_name) %}
select
    * exclude (filename),
    filename as _source_file,
    cast('{{ run_started_at.strftime("%Y-%m-%d %H:%M:%S") }}' as timestamp) as _loaded_into_bronze_at_utc
from {{ source('raw', table_name) }}
{% endmacro %}
