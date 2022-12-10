select r.relname,t.oid as toast_relid,t.relname as toast,i.relname as toast_index
from pg_class r, pg_class i, pg_index d, pg_class t
where r.relname = 'hacktoast'
and d.indrelid = r.reltoastrelid
and i.oid = d.indexrelid
and t.oid = r.reltoastrelid;
