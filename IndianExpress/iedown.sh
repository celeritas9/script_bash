#!/bin/bash
# ishan dot karve at gmail dot com
#Script to download epaper from indian express
#As always /// Its free to use...
clear
curl -s http://epaper.indianexpress.com > /tmp/editions
temp1=$(sed -nr 's/(.*)max-height:none;" src="?([^ ">]*).*/\2\n\1/; T; P; D;' /tmp/editions) 
temp2=$(sed -n -e 's/.*<span class="caption">\(.*\)<\/span>.*/\1/p' /tmp/editions)
temp3=$(sed -n -e 's/.*top"><a href="\(.*\)".*/\1/p' /tmp/editions)
editions=($(echo $temp2 | tr " " "\n"))
editions_link=($(echo $temp1 | tr " " "\n"))
#get direct webpage hyperlink
web_link=($(echo $temp3 | tr " " "\n"))
echo "Following ${#editions[*]} Editions available for download"
count=0
for i in "${editions[@]}"
do
 echo $count.  $i
 count=$((count+1))
done
while true; do
    read -p "Enter edition you wish to select[0-9]: " ed
    case $ed in
       [0123456789]) 
echo "Processing...Estimating no of pages" 
#download that webpage to extract pageno
curl -s -L ${web_link[ed]} > /tmp/ie_dump
#get pagecount
temp4=$(sed -n -e 's/.numPages*\(.*\),.*/\1/p' /tmp/ie_dump)
#delete 3 characters from left
temp4=($(echo $temp4 | cut -c4-))
#temp4=$(sed -n -e 's/.*of \(.*\)<\/span>.*/\1/p' /tmp/ie_dump)
#clean whitespace
end_pgno=`echo $temp4 | sed s/\s+//`
echo "There are $temp4 pages in selected download." 
break;;
        * ) echo "Please select the correct numeric serial.";;
    esac
done

if [ "$ed" -ge "${#editions[*]}" ]
then
echo "Please select proper edition. Please try again. Bye."
exit 0
fi

links=${editions_link[$ed]}
#grab edition id
edition_id=($(echo $links | cut -d "/" -f4))
#Get user to input starting page
read -p "Please enter the starting page you wish to download from?" strt_pg
#Get user to input ending page
read -p "Please enter the ending page you wish to download?[$end_pgno pages are available]" end_pg
while true; do
    read -p "Do you wish download pages $strt_pg to $end_pg? [Y/N]" yn
    case $yn in
        [Yy]* ) 
	ty_dir="$HOME/Desktop/ie_${editions[ed]}_`date +%d`-`date +%b`-`date +%Y`"
	mkdir $ty_dir

 for ((  i = $strt_pg ;  i <= end_pg;  i++  ))
 do
#prepend zero to single digits
      pageno=`printf "%02d" $i`  
      echo "Downloading Page $pageno"
      O_FILE="$ty_dir/$pageno.pdf"
      I_FILE="http://epaper.indianexpress.com/pdf/get/$edition_id/$i"
   wget -O $O_FILE $I_FILE 
 done
  break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#combine multiple pdf files
gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=ie_${editions[ed]}_`date +%d`-`date +%b`-`date +%Y`.pdf -dBATCH $ty_dir/*.pdf
#empty directory
#rm $ty_dir/*.*
#remove directory
#rmdir $ty_dir

