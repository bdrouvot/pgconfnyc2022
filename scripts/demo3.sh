YEL="\033[38;5;11m"
RESET="\033[0m"

echo
read -p "$(echo $YEL"Get the xact status directly from the filesystem files with a shell script"$RESET)"
echo
read -p "Get the current snapshot" 
echo
echo "psql -c \"select txid_current_snapshot();\""
echo
psql -c "select txid_current_snapshot();"


txid=$(psql -tA -c "select txid_current_snapshot();")
txid_extract=$(echo $txid | cut -f2 -d":")

read -p "Get the xact status for $txid_extract"
echo

ls -l /Users/bdrouvot/postgres/pg_installed/pg16/data/pg_xact/*
echo
read -p ""

read -p "Using the script: ./get_xact_status.sh"

view ./get_xact_status.sh

view ~/postgres/postgres/./src/backend/access/transam/clog.c
echo
view ~/postgres/postgres/./src/include/access/clog.h
echo
echo
read -p "That way: ./get_xact_status.sh -x $txid_extract -d \$PGDATA"
./get_xact_status.sh -x $txid_extract -d $PGDATA

echo
read -p "let's insert a row and check the xact status of $txid_extract"
echo
echo "psql -c \"insert into hack values (1,'xact');\""
psql -c "insert into hack values (1,'xact');"
psql -c "checkpoint;"

echo
read -p "Let's run: ./get_xact_status.sh -x $txid_extract -d \$PGDATA"
./get_xact_status.sh -x $txid_extract -d $PGDATA

echo
read -p "Now, let's rollback a transaction"
echo
cat ./rollback.sql
echo
psql -f ./rollback.sql

nexttxid=`expr $txid_extract + 1`
echo

read -p "Let's run: ./get_xact_status.sh -x $nexttxid -d \$PGDATA"
./get_xact_status.sh -x $nexttxid -d $PGDATA
echo

echo 
read -p "$(echo $YEL"Get the multixid members directly from the filesystem files with a shell script"$RESET)"
echo

ls -l /Users/bdrouvot/postgres/pg_installed/pg16/data/pg_multixact/offsets/*
echo
read -p ""
ls -l /Users/bdrouvot/postgres/pg_installed/pg16/data/pg_multixact/members/*
read -p ""

echo
read -p "Let's check what is the next mxid"
echo

echo "psql -c \"select next_multixact_id from pg_control_checkpoint();\""
echo
nextmxid=$(psql -tA -c "select next_multixact_id from pg_control_checkpoint();")
echo $nextmxid

echo
read -p "Let's generate mxid"
echo

cat ./mxid.sql
echo
psql -f ./mxid.sql

echo
read -p "Get the mxid members for mxid $nextmxid"
echo
read -p "Using the script: ./get_multixid_members.sh"

view ./get_multixid_members.sh
view /Users/bdrouvot/postgres/postgres//src/backend/access/transam/multixact.c

echo
read -p "That way: ./get_multixid_members.sh -m $nextmxid -d \$PGDATA"
./get_multixid_members.sh -m $nextmxid -d $PGDATA
echo

read -p "let's compare with the pg_get_multixact_members() output"
echo
echo "psql -c \"SELECT * FROM pg_get_multixact_members('$nextmxid');\""
psql -c "SELECT * FROM pg_get_multixact_members('$nextmxid');"
echo
read -p "$(echo $YEL"End demo3"$RESET)"
