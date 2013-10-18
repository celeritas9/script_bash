#!/bin/bash

regex="1[0-2]|[0-9]"
read -p "Enter a number " num
if [[ "$num" =~ $regex ]]; then
	echo "Yes. Number matches pattern."
fi

if [ ${num} -ge 8 ] && [ ${num} -le 12 ]; then
	echo "Number is between 8 and 12."
fi