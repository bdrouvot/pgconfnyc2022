YEL="\033[38;5;11m"
RESET="\033[0m"


echo
read -p "$(echo $YEL"Look for checksum for block 172145 in relation hack"$RESET)"
echo
echo "Easy to get with page inspect"
echo
echo "psql -c \"SELECT * FROM page_header(get_raw_page('hack', 172145));\""
echo
psql -c "SELECT * FROM page_header(get_raw_page('hack', 172145));"
echo

read -p "Let's see a page layout"
echo

view ~/postgres/postgres/src/include/storage/bufpage.h


read -p "Now, let's do it with dd"
echo
echo "which file?"
echo
echo "psql -c \"SELECT pg_relation_filepath('hack');\""
echo 
FILE=$(psql -tA -c "SELECT pg_relation_filepath('hack');")
echo $FILE
echo
 
read -p "which segment?"
echo ""

ls -l $PGDATA/${FILE}*
echo
read -p "echo \"172145 / 131072\" | bc"
SEG=$(echo "172145 / 131072" | bc)
echo $SEG
echo
echo "It means we are interested by file $FILE.$SEG"
echo

read -p "which block in the file?"
echo ""
echo "echo \"172145 % 131072\" | bc"
BLK=$(echo "172145 % 131072" | bc)
echo $BLK
echo

read -p "So page number 172145 is in fact the block number $BLK in the file $FILE.$SEG"
echo
read -p "Let's extract the checksum that way"
echo
echo "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j 8 -N 2"
read
checksum=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j 8 -N 2 | sed 's/^ *//' | sed 's/ *$//')
echo $checksum
echo

read -p "$(echo $YEL"How many tuples (dead or not) are stored in this page?"$RESET)"
echo
echo "Easy to get with page inspect"
echo
echo "psql -c \"SELECT count(*) FROM heap_page_items(get_raw_page('hack', 172145));\""
echo
psql -c "SELECT count(*) FROM heap_page_items(get_raw_page('hack', 172145));"
echo

read -p "Let’s get this with dd"
echo
read -p "pd_lower is located in the PageHeaderData and represents the starting offset for the free space"
echo
read -p "To get pd_lower we need to read 2 bytes starting byte 12"
echo

read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j 12 -N 2"
pd_lower=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j 12 -N 2 | sed 's/^ *//' | sed 's/ *$//')
echo $pd_lower
echo
read -p "As we know that the PageHeaderData is 24 bytes long and that each ItemIdData is 4 bytes"

view ~/postgres/postgres/src/include/storage/itemid.h
echo
read -p "then we can compute the number of tuples that are stored in the page that way"
echo
read -p "echo ($pd_lower - 24) / 4 | bc"
nbtuples=$(echo \($pd_lower - 24\) / 4 | bc)
echo $nbtuples
echo
read -p "$(echo $YEL"To extract information for a given tuple we need to know where to start reading from"$RESET)"
echo
read -p "This information is given by lp_off"
echo
read -p "Read a tuple lp_off"
echo
read -p "Say we want to get the lp_off for the tuple 142 in page 172145, it’s easy with pasgeinspect that way"
echo
echo "psql -c \"SELECT lp_off FROM heap_page_items(get_raw_page('hack', 172145)) where lp = 142;\""
echo
psql -c "SELECT lp_off FROM heap_page_items(get_raw_page('hack', 172145)) where lp = 142;"
echo


read -p "Let’s do the same with dd"
echo
read -p "It’s not that easy as lp_off, lp_flags and lp_len are all stored in ItemIdData which is 4 bytes long"
echo
read -p "lp_off is stored into the first 15 bits"

view ~/postgres/postgres/src/include/storage/itemid.h

echo
read -p "We are interested in lp 142, and we know that the PageHeaderData is 24 bytes long and that each ItemIdData is 4 bytes long"
echo
read -p "So that the lp 142 ItemIdData starts at byte: (4 * 142) - 4 + 24 = 588"
ItemIdData=`expr 4 \\* 142`
ItemIdData=`expr $ItemIdData + 20`
echo
read -p "To get lp_off, we have to read 2 bytes from byte 588 and extract the firsts 15 bits"
echo
read -p "echo \$((0x\`dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t x2 -j $ItemIdData -N 2 | xargs echo\` & ~\$((1<<15))))"
lp_off=$(echo $((0x`dd if=/Users/bdrouvot/postgres/pg_installed//pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t x2 -j $ItemIdData -N 2 | xargs echo` & ~$((1<<15)))))
echo $lp_off
echo
read -p "$(echo $YEL"Read the tuple xmin, xmax, infomask2, infomask, t_field3"$RESET)"
echo
read -p "This can be easily done with pagesinpect that way"
echo "psql -c \"SELECT t_xmin,t_xmax,t_infomask2,t_infomask,t_field3 FROM heap_page_items(get_raw_page('hack', 172145)) where lp = 142;\""
echo
psql -c "SELECT  t_xmin,t_xmax,t_infomask2,t_infomask,t_field3 FROM heap_page_items(get_raw_page('hack', 172145)) where lp = 142;"
echo

read -p "Let’s do it with dd"

view +152 ~/postgres/postgres/src/include/access/htup_details.h

echo
read -p "So, our lp_off is $lp_off, xmin is exactly at that offset"
echo
read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $lp_off -N 4"
xmin=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $lp_off -N 4 | sed 's/^ *//' | sed 's/ *$//')
echo $xmin
echo
read -p "xmax is at $lp_off + 4"
echo
toread=`expr $lp_off + 4`

read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 4"
xmax=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 4 | sed 's/^ *//' | sed 's/ *$//')
echo $xmax
echo

read -p "t_field3 is at $lp_off + 8"
echo
toread=`expr $lp_off + 8`
read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 4"
t_field3=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 4 | sed 's/^ *//' | sed 's/ *$//')
echo $t_field3
echo

read -p "infomask2 is at $lp_off + 18"
echo
toread=`expr $lp_off + 18`
read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 2"
infomask2=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 2 | sed 's/^ *//' | sed 's/ *$//')
echo $infomask2
echo

read -p "infomask is at $lp_off + 20"
echo
toread=`expr $lp_off + 20`
read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 2"
infomask=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t d -j $toread -N 2 | sed 's/^ *//' | sed 's/ *$//')
echo $infomask
echo

read -p "$(echo $YEL"Get the tuple user data"$RESET)"
echo
read -p "Say we want the tuple user data for tuple 142 in page 172145, with pageinspect we’ll get it (t_data) that way"
echo "psql -c \"SELECT SELECT lp_off,t_xmin,t_xmax,t_data FROM heap_page_items(get_raw_page('hack', 172145)) where lp = 142;\""
echo
psql -c "SELECT lp_off,t_xmin,t_xmax,t_data FROM heap_page_items(get_raw_page('hack', 172145)) where lp = 142;"
echo

read -p "Let’s retrieve it with dd"
echo
read -p "Let's get lp_len (those are the last 15 bits in ItemIdData), so let’s read 2 bytes after ItemIdData (byte $ItemIdData) and extract the last 15 bits"

view ~/postgres/postgres/src/include/storage/itemid.h

toread=`expr $ItemIdData + 2`
echo
read -p "echo \$((0x\`dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t x2 -j $toread -N 2 | xargs echo\` >> 1))"
lp_len=$(echo $((0x`dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t x2 -j $toread -N 2 | xargs echo` >> 1)))
echo $lp_len
echo

read -p "Let’s get t_hoff, simply read from lp_off ($lp_off) + 22"
toread=`expr $lp_off + 22`
echo
read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t u1 -j $toread -N 1"
t_hoff=$(dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A n -t u1 -j $toread -N 1 | sed 's/^ *//' | sed 's/ *$//')
echo $t_hoff
echo

read -p "Now that we get lp_off ($lp_off), lp_len ($lp_len) and t_hoff ($t_hoff) we can read the tuple's user data that way"
toread=`expr $lp_off + $t_hoff`
echo

read -p "We read from lp_off ($lp_off) + t_hoff ($t_hoff) means $toread, that's where the user data starts"
toreadN=`expr $lp_len - $t_hoff`
echo
read -p "From there we read lp_len ($lp_len) - t_hoff ($t_hoff) (means $toreadN) bytes, that's the user data length"
echo

read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A d -t x1 -j $toread -N $toreadN"
dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A d -t x1 -j $toread -N $toreadN
echo
read -p "As you can see those are the same bytes as the ones we got with pageinspect"
echo


read -p "$(echo $YEL"Get the whole tuple data (including HeapTupleHeaderData and user data)"$RESET)"
echo
read -p "Say we want those data for tuple 142 in page 172145"
echo
read -p "So that to get the whole tuple we need to read lp_len ($lp_len) bytes from byte lp_off ($lp_off), that way"
echo
read -p "dd if=$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A d -t x1 -j $lp_off -N $lp_len"
dd if=/Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG skip=$BLK bs=8192 count=1 status=none | od -A d -t x1 -j $lp_off -N $lp_len

echo
read -p "Remark"
echo
read -p "The same result could be obtained with pg_filedump, that way"
echo
read -p "pg_filedump -R $BLK -fi $FILE.$SEG | grep \"Item 142\" -A 7"
/Users/bdrouvot/pg_filedump/pg_filedump -R $BLK -fi /Users/bdrouvot/postgres/pg_installed/pg16/data/$FILE.$SEG | grep "Item 142" -A 7
echo
read -p "$(echo $YEL"End demo1"$RESET)"
