#!/bin/bash

############################################################################################
# Developer: ANDRIY GRONAU
#1. THIS SCRIPT CREATES A QNS REPORT FROM THE CHECKINS ON ALL REPEATERS
#2. identifies which repeater is primary and subtracts satellite checks from that count
#3. builds out qns static information and footer information
#4. compiles out counts for qns report
#5. saves qns report to a new file for easy printing. 
#
############################################################################################
#An input file is required for processing. 
# This input file is tab delimited with frequency listings coupled with station checkins,
# messages they have declared, and messages they passed. Station decorators are also
# allowed. Format is below.
#
# Ensure PRIMARY CONFIGURATION section variables are populated below.
#
# NCS="KD2KUB" -- you, the NCS callsign goes here
# PRIMARY="145.170" -- frequency that is the primary repeater. 
# MSGALLOC=("5515/JOHN K2VTT" "5516/DOUG AK2Z")
# -- Entering only one format callsign invokes a single
# -- Entering 2 or more invokes a book. 
# OCTENSESSDATE="JAN 16" -- OCTEN Session date
# MINUTESOFSESS="39" -- Minutes net ran for.
# SIGNATURE="ANDRIY KD2KUB" -- Your signature
# ORIGINLOC="CAMILLUS NY" -- Your Operating location
#
#
#
# To run this script simply bash qns.sh <InputFile.txt>
#
# for this script to operate, it is important to have 7 character frequencies (with .) 
# wrapping all checkins on that repeater.  
#
# from there, stations callsigns can be listed followed by a (tab) char and any declarator.
# If a station has declared traffic, another tab is inserted on that line and a number 
# is then inserted.
# If a station has passed that traffic another tab is inserted after the previous number to
# note that traffic has been passed. 
#
# Ensure not to leave any stray line breaks or tabs where they should not be.  This file
# below does work.  
#
#	145.170
#kd2kub	/n/d	4	4
#k2vtt	/d
#ke2aub
#kd2wnw
#w4bny
#k2jaf
#kb2ccd
#ak2z		1	1
#ke2ext
#	145.170
#	147.240	
#k1dcc
#	147.240
#	145.110
#kb2wii
#ke2bjw
#ke2euq
#	145.110
#	147.000
#ve3lb
#kc2eot
#kd2kgj
#kd2tir
#kv2w
#Kd2pqp	/6
#k9chp
#	147.000
#	147.210
#	
#	147.210
#	146.685
#ke2hlo
#kd2sha		1	1
#ke2glh
#kd2err
#wz2i
#kd2ett
#w2rme
#kd2scw
#	146.685
#	146.850
#k2jgy
#kd2fpm
#kb2jed
#	146.850
#
#
#
#
#
#
#
#
#

# 
#
#
#Change Log:
# 1.1 -01/17/2026 - First iteration
# 1.2 -  "    "   - fixed issue where double digits would mess up counts
# 1.3 - "    "    - FIXED Bug where stations with no traffic would not show a 0
#		  - Fixed bug where no traffic passed would show OPNOTE
#
#
##############################################################################################
# PRELIMINARY CONFIGURATION
#############################################################################################
NCS="KD2KUB"
PRIMARY="145.170"
MSGALLOC=("5515/JOHN K2VTT" "5516/DOUG AK2Z")
OCTENSESSDATE="JAN 17"
MINUTESOFSESS="17"
SIGNATURE="ANDRIY KD2KUB"
ORIGINLOC="CAMILLUS NY"

############################################################################################
#  DO NOT MESS WITH ANYTHING BELOW THIS LINE
############################################################################################
TAB=$'\t'

#get todays date and time for file name
NOW=$( date '+%F%Y%m%d-%H%M%S' )
QNSTODAY=$( date '+%b %d' )

echo "Today's date is $NOW"
echo "QNS DATE Listed is $QNSTODAY"

#create two files, one for final qns and one for sorted stations'
echo "Creating working directory ./working-$NOW"
mkdir ./working-$NOW

echo "Creating Sorted Stations file ./working-$NOW/qns-all-sorted-stations-$NOW.txt"
touch ./working-$NOW/qns-all-sorted-stations-$NOW.txt

echo -e "Creating final QNS Report File ./working-$NOW/qns-final-$NOW.txt\n\n"
touch ./working-$NOW/qns-final-$NOW.txt

echo "Building out sorted stations list into ./working-$NOW/qns-all-sorted-stations-$NOW.txt"
#append netcheckins context to sorted text file
cat $1 >> ./working-$NOW/qns-all-sorted-stations-$NOW.txt

#remove all frequency decorators and traffic numbers from sorted stations
sed -i "s/^${TAB}.......//gm" ./working-$NOW/qns-all-sorted-stations-$NOW.txt
sed -i "s/${TAB}[[:digit:]]*${TAB}[[:digit:]]*//gm" ./working-$NOW/qns-all-sorted-stations-$NOW.txt

#upper case all characters
sed -i "s/.*/\U&/g" ./working-$NOW/qns-all-sorted-stations-$NOW.txt

#remove all empty lines
sed -i "/^$/d" ./working-$NOW/qns-all-sorted-stations-$NOW.txt

#remove last of tabs at top line
sed -i "/^${TAB}/d" ./working-$NOW/qns-all-sorted-stations-$NOW.txt

#Sort entire file
sort ./working-$NOW/qns-all-sorted-stations-$NOW.txt --output=./working-$NOW/qns-all-sorted-stations-$NOW.txt

echo "Sorted callsigns file created."
echo "Determine if this will be a book or single"
#Create QNS header book
if [[ ${#MSGALLOC[@]} -gt 1 ]]; then
	echo "---A book will be sent."
	echo -e "BOOK OF ${#MSGALLOC[@]} \n\n" >> ./working-$NOW/qns-final-$NOW.txt
	echo -e "R HXA ${NCS} QNS ${ORIGINLOC} ${QNSTODAY} \nBT" >> ./working-$NOW/qns-final-$NOW.txt

else
	#Create a single when there is only one array entry. 
	RECNAME="${MSGALLOC[@]/[0-9]*\//}"
	MSGNUM="${MSGALLOC[@]/\/[A-Z]*/}"
	echo "---A single will be sent." 
	echo -e "SINGLE FOR ${RECNAME}\n\n" >> ./working-$NOW/qns-final-$NOW.txt
        echo -e "${MSGNUM} R HXA ${NCS} QNS ${ORIGINLOC} ${QNSTODAY} \nBT " >> ./working-$NOW/qns-final-$NOW.txt
	echo -e "$RECNAME"  >> ./working-$NOW/qns-final-$NOW.txt
fi

echo "Creating OCTEN QNS Report line"
#BUILD OUT OCTEN LINE
#OCTEN JAN 16 31 3 39 22
#OCTEN JAN 09 (total number of checkins) (total number of messages passed) (minutes) (number of checkins on sats) 

echo "Getting total number of checkins"
# get total number of checked in stations
TOTALCHECKIN=$(cat ./working-$NOW/qns-all-sorted-stations-$NOW.txt | sed '/^\s*$/d' | wc -l)

echo "Getting total number of messages passed"
# get total number of messages passed
TOTMSGPASSED=$(awk '
	match($0, /[0-9]\t[0-9]/){
  		#increment by 1 to forgive first digit, we dont need it
  		#I.E (tabchar)3
  		d=substr($0,RSTART+1,RLENGTH)
  		#print d	
		#hip toss everything except for that number
		gsub(/[^0-9]+/,"",d)
  		tot+=d
  }
  END{
	printf "%d", tot
  }
  ' $1)

echo "Getting all stations that were on primary repeater"
#find all primary stations checked in and get a count
REGEXPRIM="$PRIMARY"

PRIMCHECKINS=$(awk -F "${TAB}" -v p=$REGEXPRIM '{
	if($2 == p){
		getline
		while($2 != p){
			printf "%s",toupper($1)"|"
			checkins++
			getline
		}
	}
}
END{
	#printf "%s", r
}
' $1)

#trim off last character  "|" B/C Awk is too f***ing complicated.
PRIMCHECKINSS=$(echo $PRIMCHECKINS | sed 's/.$//i')

echo "exclusionary criteria: remove primary station checkin count from satellite station"
echo "count to get all stations on satellite repeater count"
#return a list of stations that are not in primary
SATCHECKINS=$(awk -F "${TAB}" -v e="$PRIMCHECKINSS" '$0 !~ e {
	counter++
}
END{
	print counter
}
' ./working-$NOW/qns-all-sorted-stations-$NOW.txt)

echo "Inserting OCTEN QNS Line into ./working-$NOW/qns-final-$NOW.txt"
#place QNS REPORT LINE INTO FILE
echo -e "OCTEN ${OCTENSESSDATE} ${TOTALCHECKIN} ${TOTMSGPASSED} ${MINUTESOFSESS} ${NUMOFSATCHINS}${SATCHECKINS}" >> ./working-$NOW/qns-final-$NOW.txt

echo -e "Display OCTEN Report Line: OCTEN ${OCTENSESSDATE} ${TOTALCHECKIN} ${TOTMSGPASSED} ${MINUTESOFSESS} ${NUMOFSATCHINS}${SATCHECKINS}"

echo "insert sorted file into final qns file"
#Append content of the sorted file to the final.
cat ./working-$NOW/qns-all-sorted-stations-$NOW.txt >> ./working-$NOW/qns-final-$NOW.txt

#add in a BT
echo -e "BT" >> ./working-$NOW/qns-final-$NOW.txt

#add in signature 
echo -e $SIGNATURE >> ./working-$NOW/qns-final-$NOW.txt

#get all stations that sent traffic
OPNOTETRAFFIC=$(awk -F "${TAB}" '{

	if($4 > 0){
		print toupper($1"/"$4)
	}

}
END{
        #printf "%s", r
}
' $1)

#add stations that passed traffic if any
if [[ $TOTMSGPASSED -gt 0 ]]; then
	echo "Inserting OP NOTE TRAFFIC Line"
	#add on OP NOTE TRAFFIC LINE
	echo -e "OP NOTE TRAFFIC" >> ./working-$NOW/qns-final-$NOW.txt
	echo $OPNOTETRAFFIC >> ./working-$NOW/qns-final-$NOW.txt
else
	echo "OP Note not inserted... No traffic passed"
fi

#determine if a book is used to insert message lines
if [[ ${#MSGALLOC[@]} -gt 1 ]]; then
	
	echo "BT" >> ./working-$NOW/qns-final-$NOW.txt	
	for value in "${MSGALLOC[@]}"
	do
		echo "$value" >> ./working-$NOW/qns-final-$NOW.txt
	done	

else
       #Create a single when there is only one array entry.
       #and an AR for digi traffic
       echo "AR" >> ./working-$NOW/qns-final-$NOW.txt	
fi

echo -e "\n\nPROCESS COMPLETE\n\n"
