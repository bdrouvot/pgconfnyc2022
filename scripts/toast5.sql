select
page_item_attrs.t_ctid,
page_item_attrs.t_attrs[2],
substr(substr(page_item_attrs.t_attrs[2],octet_length(page_item_attrs.t_attrs[2])-7,4)::text,3) as substr_for_chunk_id,
('x'||regexp_replace(substr(substr(page_item_attrs.t_attrs[2],octet_length(page_item_attrs.t_attrs[2])-7,4)::text,3),'(\w\w)(\w\w)(\w\w)(\w\w)','\4\3\2\1'))::bit(32)::int as chunk_id,
substr(substr(page_item_attrs.t_attrs[2],octet_length(page_item_attrs.t_attrs[2])-3,4)::text,3) as substr_for_toast_relid,
('x'||regexp_replace(substr(substr(page_item_attrs.t_attrs[2],octet_length(page_item_attrs.t_attrs[2])-3,4)::text,3),'(\w\w)(\w\w)(\w\w)(\w\w)','\4\3\2\1'))::bit(32)::int as toast_relid
FROM
generate_series(0, pg_relation_size('hacktoast'::regclass::text) / 8192 - 1) blkno ,
heap_page_item_attrs(get_raw_page('hacktoast', blkno::int), 'hacktoast'::regclass) as page_item_attrs
where
substr(page_item_attrs.t_attrs[2]::text,3,2)='01' and ('x'||regexp_replace(substr(substr(page_item_attrs.t_attrs[2],octet_length(page_item_attrs.t_attrs[2])-7,4)::text,3),'(\w\w)(\w\w)(\w\w)(\w\w)','\4\3\2\1'))::bit(32)::int = 16453;
