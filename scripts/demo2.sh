YEL="\033[38;5;11m"
RESET="\033[0m"

echo
read -p "$(echo $YEL"Read the page header"$RESET)"
echo

read -p "Using the following script: ./page_header_info.sh"

view ./page_header_info.sh

echo
read -p "that way: sh ./page_header_info.sh -b 172145 -p base/5/16384 -t hack -i both"
echo
sh ./page_header_info.sh -b 172145 -p /Users/bdrouvot/postgres/pg_installed/pg16/data/base/5/16384 -t hack -i both
echo

read -p "$(echo $YEL"Read the heap page items"$RESET)"
echo
read -p "Using the following script: ./heap_page_items_info.sh"

view ./heap_page_items_info.sh
echo

read -p "that way: sh ./heap_page_items_info.sh -b 172145 -p base/5/16384 -t hack -i disk"
echo
sh ./heap_page_items_info.sh -b 172145 -p /Users/bdrouvot/postgres/pg_installed/pg16/data/base/5/16384 -t hack -i disk
echo

read -p "$(echo $YEL"Read the btree meta infos"$RESET)"
echo

view +103 ~/postgres/postgres/src/include/access/nbtree.h

read -p "Using the following script: ./bt_metap_info.sh"
view ./bt_metap_info.sh
echo

read -p "that way: sh ./bt_metap_info.sh -p base/5/16436 -bt hackidx1 -i both"
echo
sh ./bt_metap_info.sh -p /Users/bdrouvot/postgres/pg_installed/pg16/data/base/5/16436 -bt hackidx1 -i both
echo

read -p "$(echo $YEL"Read the btree page items"$RESET)"
echo

view +35 ~/postgres/postgres/src/include/access/itup.h

read -p "Using the following script: ./bt_page_items_info.sh"
view ./bt_page_items_info.sh
echo
read -p "that way: sh ./bt_page_items_info.sh -b 1721  -p base/5/16436 -bt hackidx1 -i disk"
echo
sh ./bt_page_items_info.sh -b 1721  -p /Users/bdrouvot/postgres/pg_installed/pg16/data/base/5/16436 -bt hackidx1 -i disk

echo
read -p "$(echo $YEL"Read the btree page stats"$RESET)"
echo
read -p "Using the following script: ./bt_page_stats_info.sh"

view ./bt_page_stats_info.sh
echo
read -p "that way: sh ./bt_page_stats_info.sh -b 1721 -p base/5/16436 -bt hackidx1 -i both"
echo
sh ./bt_page_stats_info.sh -b 1721 -p /Users/bdrouvot/postgres/pg_installed/pg16/data/base/5/16436 -bt hackidx1 -i both
echo
read -p "$(echo $YEL"End demo2"$RESET)"
