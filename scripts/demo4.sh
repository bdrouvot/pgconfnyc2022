YEL="\033[38;5;11m"
RESET="\033[0m"

echo
read -p "$(echo $YEL"Link the user table tuples to the toast pages by using user table tuples and toast index data (not querying the toast at all)"$RESET)"
echo
read -p "Let's work on this hacktoast table"

echo "psql -c \"\d hacktoast;\""
echo
psql -c "\d hacktoast;"
echo
read -p "check the toast and toast index names"
echo
cat ./toast1.sql
echo
psql -f ./toast1.sql

echo
read -p "the toast relation looks like"
echo
echo "psql -c \"\d pg_toast.pg_toast_16440;\""
echo
psql -c "\d pg_toast.pg_toast_16440;"

read -p ""

view +56 ~/postgres/postgres/src/include/postgres.h

read -p "So we can get the information with pageinspect, so let’s use it to build a query to retrieve the chunk_id and the toast relation id from the tuples"
echo
cat ./toast2.sql
read -p ""
echo
psql -f ./toast2.sql
read -p ""

open /System/Applications/Calculator.app

read -p ""
echo
read -p "let's verify those values make sense"
echo
echo "psql -c \"select distinct(chunk_id) from pg_toast.pg_toast_16440 order by 1;\""
echo
psql -c "select distinct(chunk_id) from pg_toast.pg_toast_16440 order by 1;"

read -p "Retrieve the chunk_id and chunk_seq directly from the toast index"
echo
cat ./toast3.sql
read -p ""
echo
psql -f ./toast3.sql
echo

read -p "Note that the chunk_ids coming from the index, the user table tuples and the toast itself match"
echo


read -p "$(echo $YEL"Use case example: a toast’s page is corrupted and I want to know which tuples from the user table are affected"$RESET)"
echo
read -p "Say the page 12 of the toast is corrupted, then we could get the affected chunk_id and chunk_seq from the toast index that way (by filtering on the ctid)"
echo
cat ./toast4.sql
read -p ""
echo
psql -f ./toast4.sql

read -p "And then look back at the user table tuples that way by filtering on the chunk_id"
echo
cat ./toast5.sql
read -p ""
echo
psql -f ./toast5.sql

echo
read -p "$(echo $YEL"Search for tuples (dead or not) based on attributes values"$RESET)"
echo
read -p "Say that i want to retrieve the tuples (dead or not) from the hack relation that have the id field = 27178258"
echo
read -p "First let’s check the id attribute number for my relation hack"

echo "psql -c \"select attnum from pg_attribute where attrelid = 'hack'::regclass and attname = 'id';\""
echo
psql -c "select attnum from pg_attribute where attrelid = 'hack'::regclass and attname = 'id';"
attnum=$(psql -tA -c "select attnum from pg_attribute where attrelid = 'hack'::regclass and attname = 'id';")

echo
read -p "Let’s get the hexa value for 27178258"
echo
echo "echo \"ibase=10;obase=16;27178258\" | bc"
echo
echo "ibase=10;obase=16;27178258" | bc
echo

read -p "means we have to search for 12b59e01"
echo
read -p "Now, look for tuples (dead or not) having this value for attribute number 1"
echo
cat ./get_attr.sql
read -p ""
echo
psql -f ./get_attr_fast.sql
echo


read -p "Double check correctness by checking the value from the neighbor"
echo
echo "psql -c \"select id from hack where ctid = '(172145,141)';\""
echo
psql -c "select id from hack where ctid = '(172145,141)';"
echo
echo "psql -c \"select id from hack where ctid = '(172145,143)';\""
echo
psql -c "select id from hack where ctid = '(172145,143)';"
echo
read -p "$(echo $YEL"End demo4"$RESET)"
