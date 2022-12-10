begin;
select a from hackmxid for update;
savepoint a;
update hackmxid set a = 3;
update hackmxid set a = 4;
update hackmxid set a = 5;
commit;
checkpoint;
