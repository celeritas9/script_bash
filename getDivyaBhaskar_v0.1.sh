#Copyright 2013 Devang Shah (Email:devang221129[at]gmail[dot]com)
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
edition_name=( [0]=AHMEDABAD%20CITY [1]=BCITY [2]=SCI [3]=VALSAD-VAP [4]=NAR )
#City name corresponding to the edition_name.
city_names=( [0]=Ahmedabad [1]=Vadodara [2]=Surat [3]=Vapi-Valsad [4]=Bharuch-Narmada )
ed_len=${#city_names[@]}
echo "Divya Bhaskar editions are"
echo "-------------------------------------------------"
for (( i=0; i<${ed_len}; i++ ));
do
	echo $i ". " ${city_names[i]}
done
echo "-------------------------------------------------"
while true 
do
	read -p "Enter edition you wish to selec[0-4]: " ed
	#echo "Edition is " $ed
	case $ed in
	[01234] )
		echo "Thanks." 
	break;;
		* ) echo "Please select the correct numeric serial."
	;;
	esac
done

total_pages=0
max_spider=100
echo "Checking if pages exists."
for (( j = 1 ;  j <= $max_spider;  j++  )); do
	echo "Searching for Page $j"
	I_FILE="http://digitalimages.bhaskar.com/gujarat/epaperpdf/$date/${yesterdate}${edition_name[ed]}-PG$j-0.PDF"
	echo ">>>>>" $I_FILE
	debug=`wget --spider $I_FILE 2>&1`
	echo $debug
	if [ -z "`echo $debug | grep -i "200 OK"`" ]; then
		echo "Page $j does not exist. Breaking now."
		let j--
		break
	fi
	echo "Page $j exists."
done
total_pages=$j
echo "Finished checking pages."
echo "Total pages are " $total_pages

#If total pages found are 0 then exit the script.
if [ $total_pages -eq 0 ]; then
	echo "Total pages available for the selection are 0. Exiting."
	exit 0;
fi

edition=${city_names[ed]}_${date}

#Download all the pdf pages and store in a temp directory.
temp_dir="$epaper/${edition}_temp"
echo "Starting download of individual pages at " $temp_dir
echo "Downloading may take some time depending on your connection speed and number of pages. Please multitask and utilize your time."
mkdir -p $temp_dir
for (( i = 1; i <= $total_pages; i++ )); do
	page=`printf %02d $(( 10#$i ))`
	I_FILE="http://digitalimages.bhaskar.com/gujarat/epaperpdf/$date/${yesterdate}${edition_name[ed]}-PG${i}-0.PDF"
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

exit
