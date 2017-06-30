#!/bin/sh
#
# Finnish Meteorological Institute / Mikko Rauhala (2015-2017)
#
# SmartMet Data Ingestion Module for GOES Satellite Observations
#

URL=http://satepsanone.nesdis.noaa.gov/pub/GIS

if [ -d /smartmet ]; then
    BASE=/smartmet
else
    BASE=$HOME
fi

EDITOR=$BASE/editor/sat
TMP=$BASE/tmp/data/goes

mkdir -p $TMP

for CHANNEL in 1V 04I2 04I3 04I4
do
    echo "Fetching file list for channel $CHANNEL..."
    FILES=$(wget -nv -O - $URL/GOESeast/ | grep -oP "href=\"\KGoesEast${CHANNEL}[0-9]{7}.tif(?=\")")
    echo "done";

    for file in $FILES
    do
	yearstr=$(date +%Y)
	julianstr=$(echo ${file/GoesEast${CHANNEL}/}|cut -c1-3)
	timestr=$(echo ${file/GoesEast${CHANNEL}/}|cut -c4-7)
	datestr=$(date -d "$yearstr-01-01 +$(( ${julianstr} - 1 ))days" +%Y%m%d)
	TIMESTAMP=$datestr$timestr
	TIFFILE=$TMP/${TIMESTAMP}_satellite_goeseast_${CHANNEL}.tif
	JPGFILE=$TMP/${TIMESTAMP}_satellite_goeseast_${CHANNEL}.jpg

	if [ ! -s $EDITOR/${TIMESTAMP}_satellite_goeseast_${CHANNEL}.jpg ]; then
	    echo "Downloading: $URL/GOESeast/$file"
	    wget -nv -O $TIFFILE $URL/GOESeast/$file 
	    gdalwarp -t_srs 'EPSG:4326' $TIFFILE ${TIFFILE}.tmp
	    mv -f $TIFFILE.tmp $TIFFILE

	    if [ ${CHANNEL} = "1V" ]; then
		convert -geometry 50% $TIFFILE $JPGFILE
	    elif [ ${CHANNEL} = "04I3" ]; then
		convert -normalize $TIFFILE $JPGFILE
	    else
		convert $TIFFILE $JPGFILE
	    fi

	    if [ -s $JPGFILE ]; then
		mv -f $JPGFILE $EDITOR
	    fi
	    rm -f $TIFFILE
	else
	    echo "Cached: $JPGFILE"
	fi
    done
done

