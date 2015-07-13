#!/bin/bash

echo "Content-type: application/json"
echo "Access-Control-Allow-Origin: *"
echo ""

PARAMETER_ARRAY=(${QUERY_STRING//&/ })

for i in "${!PARAMETER_ARRAY[@]}"
do
	PAIR=${PARAMETER_ARRAY[i]}
	PAIR_ARRAY=(${PAIR//=/ })
	KEY=${PAIR_ARRAY[0]}
	VALUE=${PAIR_ARRAY[1]}
	if [ $KEY == "id" ] 
	then
		IDENT=$VALUE
		FILEPATH=beacons/beacon-$IDENT
		touch $FILEPATH
	fi
	if [ $KEY == "posx" ] 
	then
		NEW_POSX=$VALUE
	fi
	if [ $KEY == "posy" ] 
	then
		NEW_POSY=$VALUE
	fi
	if [ $KEY == "area" ] 
	then
		NEW_AREA=$VALUE
	fi
	if [ $KEY == "dist" ] 
	then
		NEW_DIST=$VALUE
	fi
done

if [ $IDENT ] 
then
	while IFS= read -r line
	do
		PAIR_ARRAY=(${line//=/ })
		KEY=${PAIR_ARRAY[0]}
		VALUE=${PAIR_ARRAY[1]}
		if [ $KEY == "posx" ] 
		then
			OLD_POSX=$VALUE
		fi
		if [ $KEY == "posy" ] 
		then
			OLD_POSY=$VALUE
		fi
		if [ $KEY == "area" ] 
		then
			OLD_AREA=$VALUE
		fi
		if [ $KEY == "dist" ] 
		then
			OLD_DIST=$VALUE
		fi
		if [ $KEY == "url" ]
		then
			DEM_URL=$VALUE
		fi
	done<"$FILEPATH"

	if [ -z $NEW_POSX ] 
	then
		NEW_POSX=$OLD_POSX
	fi
	if [ -z $NEW_POSY ] 
	then
		NEW_POSY=$OLD_POSY
	fi
	if [ -z $NEW_AREA ] 
	then
		NEW_AREA=$OLD_AREA
	fi
	if [ -z $NEW_DIST ] 
	then
		NEW_DIST=$OLD_DIST
	fi

	echo posx"="$NEW_POSX > $FILEPATH
	echo posy"="$NEW_POSY >> $FILEPATH
	echo area"="$NEW_AREA >> $FILEPATH
	echo dist"="$NEW_DIST >> $FILEPATH
	echo url"="$DEM_URL >> $FILEPATH
fi

echo ok
