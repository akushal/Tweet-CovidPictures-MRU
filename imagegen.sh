#!/bin/bash
##################################
# Script to Download a picture   #
# get stats about covid          #
# write it on the image          #
##################################


temppath=/var/www/html/flight/temp.png
temppath_convert=/var/www/html/flight/tempconvert.png
confinementstartdate='200320' #Mauritius
finalimagepath=/var/www/html/flight/covid.png
backup=/var/www/html/flight/backup.png

#Backup and remove file
if [ -f $finalimagepath ]; then

	mv  $finalimagepath "$backup"
fi


imageURL=$(curl -s 'https://apiimages.kushal.net/api/v1.0/gp/public/random' | \
	python2 -c "import sys, json; print json.load(sys.stdin)['url']")

wget --quiet $imageURL -O $temppath_convert >/dev/null

if [ ! $? -eq 0 ]; then
	echo "[KO] WGET"
      	exit 1
fi	
convert  $temppath_convert -resize 1024x768 $temppath

COVIDDS=$(curl -s 'https://coronavirus-tracker-api.herokuapp.com/v2/locations?country_code=MU')

confirmed=`echo $COVIDDS |jq .latest.confirmed`
recovered=`echo $COVIDDS | jq .latest.recovered`
deaths=`echo $COVIDDS | jq .latest.deaths`

numconfinementdays=$(( ($(date --date="now" +%s) - $(date --date="$confinementstartdate" +%s) )/(60*60*24) ))

#echo "$numconfinementdays"

#message='"Confirmed cases: '"$confirmed"', Recovered cases: '"$recovered"', Deaths:'"$deaths"', Confinement#'"$numconfinementdays"'"'
#echo "$message"
confinementmsg='"#MAURITIUS Confinement#'"$numconfinementdays"'"'
confirmedmsg='"Confirmed:'"$confirmed"'"'
recoveredmsg='"Recovered:'"$recovered"'"'
deathmsg='"Deaths:'"$deaths"'"'



convert  -font helvetica -fill "#fc4103" -pointsize 40 -gravity north \
	-draw "text 0,200 $confinementmsg" \
	-gravity center -draw "text 0,0 $confirmedmsg" \
	-draw "text 0,50 $recoveredmsg" \
	-draw "text 0,100 $deathmsg" \
	-gravity south -draw "text 0,100 '#StaySafe #StayHome'" $temppath $finalimagepath 

if [ $? -eq 0 ];then
	echo "[OK]"
	exit 0
else
	echo "KO"
	exit 1
fi
#convert -font helvetica -fill white -pointsize 40 -gravity center -draw "  $message" $temppath $finalimagepath
#echo "$message"  | convert -font helvetica -fill white -pointsize 60 -gravity center caption:@- $temppath 

