#!/bin/bash

echo "Content-type: application/json"
echo "Access-Control-Allow-Origin: *"
echo ""

TMP_FILE=temp.txt

ls -l beacons | grep beacon | sed -E 's/.* beacon-(.+)$/\1/' > $TMP_FILE
echo {\"beacons\":[
while IFS= read -r line
do
    echo {
    while IFS= read -r line2
    do
		echo $line2 | sed -E 's/(.+)=(.*)/\"\1\":\"\2\",/'
	done <"beacons/beacon-$line"
	echo \"id\":\"$line\"},
done <"$TMP_FILE"
echo {\"id\":\"eof\", \"why\":\"Because who developed me sucks\"}]}