file=$1
while IFS= read -r line
do
        # display $line or do somthing with $line
	echo "$line"
done <"$file"