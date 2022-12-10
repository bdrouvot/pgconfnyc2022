select
page_items.ctid,
page_items.data,
('x'||regexp_replace(substr(page_items.data,1,11),'(\w\w) (\w\w) (\w\w) (\w\w)','\4\3\2\1'))::bit(32)::int as chunk_id,
('x'||regexp_replace(substr(page_items.data,13,23),'(\w\w) (\w\w) (\w\w) (\w\w)','\4\3\2\1'))::bit(32)::int as chunk_seq
FROM
generate_series(1, pg_relation_size('pg_toast.pg_toast_16440_index'::regclass::text) / 8192 - 1) blkno ,
bt_page_items('pg_toast.pg_toast_16440_index', blkno::int) as page_items where ctid::text like '(12,%';
