#!/bin/bash

#I_FILE="http://digitalimages.bhaskar.com/gujarat/epaperpdf/07042013/6AHMEDABAD%20CITY-PG14-0.PDF"
#O_FILE="temp.pdf"
#wget -q -O $O_FILE $I_FILE

#dd=01
#dd=$(( dd ))
#echo dd $dd
#(( minusdd=dd - 1 ))
#echo minusdd $minusdd
#last_date=`date -d "1 day ago" +%d`
#echo last_date $last_date
#yesterdate=$(( ( dd == 1 ) ? last_date : minusdd ))
#echo yesterdate $yesterdate

#Following is an example of functions in shell.
function copy_values_to_array()
{
	echo "Function copy_values_to_array called."
	if [ ! -z "`echo $pages | grep "-"`" ]; then
		echo "Pages contain '-'."
		#index_array=$(echo $pages | tr "-" "\n")
		index_array=(${pages//-/ })
		start_page=${index_array[0]}
		end_page=${index_array[1]}
		total_pages=$(( end_page - start_page + 1 ))
		echo "Total pages to download: " $total_pages " , start_page: " $start_page " ,end_page: " $end_page
		for (( i=start_page,j=0; i<=end_page; i++,j++ ))
		do
			page_numbers[j]=$i
			echo "copied value $i to $j"
		done
	fi
	
	if [ ! -z "`echo $pages | grep ","`" ]; then
		echo "Pages contain ','."
		#temp_arr=$(echo $pages | tr "," "\n")
		#i=0
		#for x in $temp_arr
		#do
		#	page_numbers[i]=$x
		#	echo "copied value $x to $i"
		#	let i++
		#done
		page_numbers=(${pages//,/ })
	fi
}
read -p "Enter range or individual pages to download: " pages
declare -a page_numbers
copy_values_to_array
echo "Printing the page_numbers with size ${#page_numbers[@]}"

for (( i=0; i< ${#page_numbers[@]}; i++ ))
do
	echo ${page_numbers[i]}
done