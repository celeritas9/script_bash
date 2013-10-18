#Copyright 2013 Devang Shah {Email:devang221129[at]gmail[dot]com}
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/bin/bash

##############################################FUNCTIONS

#The below function copies page numbers from a range or sequence into the array.
#e.g. if pages contains a range, e.g. 2-4 then resulting array will contain values [2,3,4]
#     if pages contains comma separated values, e.g. 2,4,6 then resulting array will contain values [2,4,6].
function copy_values_to_array()		#INPUT pages, pages_to_download[]
{
	#echo "Function copy_values_to_array called."
	if [ ! -z "`echo $pages | grep "-"`" ]; then
		#echo "Pages contain '-'."
		index_array=(${pages//-/ })
		start_page=${index_array[0]}
		end_page=${index_array[1]}
		total_pages=$(( end_page - start_page + 1 ))
		#echo "Total pages to download: " $total_pages " , start_page: " $start_page " ,end_page: " $end_page
		for (( i=start_page,j=0; i<=end_page; i++,j++ ))
		do
			pages_to_download[j]=$i
		#	echo "copied value $i to $j"
		done
	elif [ ! -z "`echo $pages | grep ","`" ]; then
		#echo "Pages contain ','."
		pages_to_download=(${pages//,/ })
	else #Single page is entered. Copy the page to the array.
		pages_to_download[0]=${pages}
	fi
}

#The below function identifies the exact edition name for the select city. Default is Error.
#First it tries to check if ${edition_name[ed]} is valid, if it is then it proceeds with the name for all the pages.
#If the ${edition_name[ed]} is not valid then it tries to look out for alternate ${alternate_edition_name[ed]}.
#For either of the valid edition name it sets the global variable exact_edition_name.
function identify_exact_edition_name()
{
	echo "Identifying the exact edition name for ${city_names[ed]}"
	I_FILE="http://digitalimages.bhaskar.com/${var_language}/epaperpdf/$date/${yesterdate}${edition_name[ed]}-PG1-0.PDF"
	echo ">>>>>" $I_FILE
	debug=`wget --spider $I_FILE 2>&1`
	if [ -z "`echo $debug | grep -i "200 OK"`" ]; then
		echo "Edition name ${edition_name[ed]} is not valid. Trying alternate edition name ${alternate_edition_name[ed]}"
		I_FILE="http://digitalimages.bhaskar.com/${var_language}/epaperpdf/$date/${yesterdate}${alternate_edition_name[ed]}-PG1-0.PDF"
		echo ">>>>>" $I_FILE
		debug=`wget --spider $I_FILE 2>&1`
		if [ -z "`echo $debug | grep -i "200 OK"`" ]; then
			echo "Edition name ${alternate_edition_name[ed]} is also not valid."
		else
			exact_edition_name=${alternate_edition_name[ed]}
		fi
	else
		exact_edition_name=${edition_name[ed]}
	fi
}

#The below function spiders all the pages for edition_name[ed] and get the maximum count of available pages.
function find_total_available_pages()		#INPUT max_spider,date,yesterdate,edition_name,ed
{
	echo "Going to find total available pages."
	for (( j = 1 ;  j <= $max_spider;  j++  ));
	do
		#page_num=${pages_to_download[j]}
		echo "Searching for page $j"
		I_FILE="http://digitalimages.bhaskar.com/${var_language}/epaperpdf/$date/${yesterdate}${exact_edition_name}-PG${j}-0.PDF"
		echo ">>>>>" $I_FILE
		debug=`wget --spider $I_FILE 2>&1`
		#echo $debug
		if [ -z "`echo $debug | grep -i "200 OK"`" ]; then
			echo "Page $page_num does not exist. Breaking now."
			let j--
			break
		fi
		echo "Page $j exists."
	done
	total_available_pages=$j
}

###############################################START OF EXECUTION
read -p "----Enter the day (e.g. dd)		:" dd
read -p "----Enter the month(e.g. mm)		:" mm
read -p "----Enter the year(e.g. yyyy)		:" yyyy

epaper="$HOME/epaper/DivyaBhaskar"
mkdir -p $epaper

#The paper downloaded will have yesterdate, will be used in the link.
yesterdate=`date --date=${mm}/${dd}/${yyyy}'-1 day' +%d`
#Padding for the dd,mm and yyyy
dd=`printf %02d $(( 10#$dd ))`
mm=`printf %02d $(( 10#$mm ))`
yyyy=`printf %04d $(( 10#$yyyy ))`
date=${dd}${mm}${yyyy}

#0- Ahmedabad 1-Baroda 2- Surat 3- Vaapi Valsad 4- Bharuch Narmada
#Edition name contains the name in the link.
edition_name=( [0]=AHMEDABAD%20CITY [1]=BCITY [2]=SCI [3]=VALSAD-VAP [4]=NAR [5]=MUMBAI [6]=SUN [7]=KALASH \
[8]=DMMAIN [9]=DMNMAIN [10]=JALGAONMAIN [11]=ANAGARMAIN [12]=SOLAPUR )

#Alternate possible edition names. For Marathi papers, since 24 April they have changed the names of the edition.
#e.g. DMMAIN has become AURANGABAD CITY
#Page 1 of 23rd April 2013 - http://digitalimages.bhaskar.com/divyamarathi/epaperpdf/23042013/22DMMAIN-PG1-0.PDF
#Page 1 of 24th April 2013 - http://digitalimages.bhaskar.com/divyamarathi/epaperpdf/24042013/23AURANGABAD%20CITY-PG1-0.PDF
#The same difference holds true for following since 24th April.
#Jalgaon (JALGAON%20CITY instead of JALGAONMAIN)
#Ahmednagar (AHMEDNAGAR%20CITY instead of ANAGARMAIN)
alternate_edition_name=( [0]=AHMEDABAD%20CITY [1]=BCITY [2]=SCI [3]=VALSAD-VAP [4]=NAR [5]=MUMBAI [6]=SUN [7]=KALASH \
[8]=AURANGABAD%20CITY [9]=NASHIK%20CITY [10]=JALGAON%20CITY [11]=AHMEDNAGAR%20CITY [12]=SOLAPUR )

#City name corresponding to the edition_name.
city_names=( [0]=Ahmedabad [1]=Vadodara [2]=Surat [3]=Vapi-Valsad [4]=Bharuch-Narmada [5]=Mumbai [6]=Sunday-Bhaskar [7]=Kalash \
[8]=Aurangabad [9]=Nashik [10]=Jalgaon [11]=Ahmednagar [12]=Solapur )
ed_len=${#city_names[@]}

echo "Divya Bhaskar editions are [0-7] Gujarati, [8-11] Marathi "
echo "-------------------------------------------------"
for (( i=0; i<${ed_len}; i++ ));
do
	echo $i ". " ${city_names[i]}
done
echo "-------------------------------------------------"
while true 
do
	read -p "Enter edition you wish to select[0-12]: " ed
	#echo "Edition is " $ed
	case $ed in
	[0-9] | 1[0-2] )
		echo "Thanks." 
	break;;
		* ) echo "Valid choices are from 0 to 12."
	;;
	esac
done

#Determine the language of the paper. Editions 0 to 7 are in Gujarati, 8 to 12 are Marathi papers.
var_language="gujarat"
if [ ${ed} -ge 8 ] && [ ${ed} -le 12 ]; then
	var_language="divyamarathi"
fi

declare -a pages_to_download
max_spider=100
exact_edition_name="Error"
total_available_pages=0

identify_exact_edition_name
echo "###############################Exact edition name is ${exact_edition_name}."
if [ "${exact_edition_name}" == "Error" ]; then
	echo "No valid edition for ${city_names[ed]} found. Terminating."
	exit 100;
fi

find_total_available_pages
echo "###############################Total available pages are ${total_available_pages}."
if [ ${total_available_pages} -eq 0 ]; then
	echo "Total pages available for the select edition are 0. Please verify if the pages for the selection exist. Terminating."
	exit 101;
fi

read -p "Enter the pages' range (e.g. 2-4) or individual pages (e.g. 3,4,8) to download: " pages
copy_values_to_array
total_pages=${#pages_to_download[@]}

echo "Total pages to download are $total_pages. First page is ${pages_to_download[0]}. Out of the pages specified, invalid pages will not be downloaded."

edition=${city_names[ed]}_${date}_"Pages_${pages_to_download[0]}-${pages_to_download[ (( $total_pages-1 )) ]}"

#Download all the pdf pages and store in a temp directory.
temp_dir="$epaper/${edition}_temp"
echo "Starting download of individual pages at " $temp_dir
echo "Downloading may take some time depending on your connection speed and number of pages. Please multitask and utilize your time."
mkdir -p $temp_dir
for (( i = 0; i < $total_pages; i++ )); do
	page=`printf %02d $(( 10#${pages_to_download[i]} ))`
	I_FILE="http://digitalimages.bhaskar.com/${var_language}/epaperpdf/$date/${yesterdate}${exact_edition_name}-PG${pages_to_download[i]}-0.PDF"
	O_FILE="$temp_dir/${city_names[ed]}_${date}_Page${page}.pdf"
	#q-quiet, O-output file name specified
	wget -O $O_FILE $I_FILE
	echo "File $I_FILE stored at $O_FILE"
done
echo "Finished download of individual pages at " $temp_dir

#Combine all the pdf files into one pdf file.
echo "Start combining all the files in " $temp_dir
#output_file_name=${city_names[ed]}_${date}
gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=$epaper/${edition}.pdf -dBATCH $temp_dir/*.pdf
echo "Finished combining all the files in " $temp_dir

echo "File copied to " $epaper
echo "Removing temporary files/folders " $temp_dir
rm -rf $temp_dir

exit 0
