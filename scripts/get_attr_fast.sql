select
*
FROM
generate_series(172145, 172145) blkno ,
heap_page_item_attrs(get_raw_page('hack', blkno::int), 'hack'::regclass) as page_items where page_items.t_attrs[1]::text like '%x12b59e01%';
