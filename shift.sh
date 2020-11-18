#! /bin/bash

export nSample=256
export PATH=$PATH:$HOME/anaconda3/envs/arosics/bin
export INIMG=20170703.tif
#export REFIMG_RED=../1612110337391612129023/data1.l3a.vnir2.tif 
#export REFIMG_NIR=../1612110337391612129023/data1.l3a.vnir3n.tif
export OUTPUT=20170703_shifted.tif
export WORKDIR=$(mktemp -dp /dev/shm)
#mkdir -p $WORKDIR
export WARPOPTS="-overwrite -co compress=deflate -of GTiff"
export ASTCLOUD=15
export ASTNSCENE=1

export EPSG=`gdalinfo $INIMG | grep EPSG | tail -n 1 | sed 's/.*\["EPSG","\([0-9]*\)"\]\]/\1/g'`
LL=(`gdalinfo $INIMG | grep "Lower Left" | sed 's/.*(\(.*\)).*(.*)/\1/g; s/ //g; s/,/ /g'`)
UR=(`gdalinfo $INIMG | grep "Upper Right" | sed 's/.*(\(.*\)).*(.*)/\1/g; s/ //g; s/,/ /g'`)
LLMIN=($(echo ${LL[0]} ${LL[1]} | invproj -f %.8lf +proj=utm +zone=$(echo $EPSG | sed 's/...\(..\)/\1/') +datum=WGS84 +units=m))
LLMAX=($(echo ${UR[0]} ${UR[1]} | invproj -f %.8lf +proj=utm +zone=$(echo $EPSG | sed 's/...\(..\)/\1/') +datum=WGS84 +units=m))
LONCEN=$(echo "scale=8; (${LLMIN[0]} + ${LLMAX[0]}) / 2" | bc)
LATCEN=$(echo "scale=8; (${LLMIN[1]} + ${LLMAX[1]}) / 2" | bc)

OBSY=$(echo $INIMG | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).tif/\1/')
OBSM=$(echo $INIMG | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).tif/\2/')
OBSD=$(echo $INIMG | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\).tif/\3/')

i=1
#rm -f $WORKDIR/aseter.xml && touch $WORKDIR/aster.xml
ASTID=""
#while [ "$(echo $ASTIDS | wc -l)" -lt $ASTNSCENE ]; do
while [ "$ASTID" = "" ]; do
#for aaa in $(seq 1 5); do
    START=$(date -d "${OBSY}-${OBSM}-${OBSD} - $(expr $i \* 15) days" +%F)
    END=$(date -d "${OBSY}-${OBSM}-${OBSD} + $(expr $i \* 15) days" +%F)

#    wget -O $WORKDIR/aster.xml "https://gbank.gsj.jp/madas/cgi-bin/php/SearchCSW.php?max_record=${ASTNSCENE}&page=1&base0=0&base1=0&sort=DESC&satellite=ASTER&satellite_aster=TRUE&satelilte_jers1ops=&satelilte_jers1sar=&start=${START}+00%3A00%3A00&end=${END}+00%3A00%3A00&maxy=${LLMAX[1]}&minx=${LLMIN[0]}&maxx=${LLMAX[0]}&miny=${LLMIN[1]}&gid=&aster_op_mode=Full&ASTER5=TRUE&ASTER6=TRUE&ASTER7=&ASTER8=&aster_cloud=${ASTCLOUD}&ASTER10=&ASTER11=&OPS1=&OPS2=&OPS3=&OPS4=&OPS5=&OPS6=&jers1ops_cloud=&SAR1=&SAR2="
    wget -O $WORKDIR/aster.xml "https://gbank.gsj.jp/madas/cgi-bin/php/SearchCSW.php?max_record=${ASTNSCENE}&page=1&base0=0&base1=0&sort=DESC&satellite=ASTER&satellite_aster=TRUE&satelilte_jers1ops=&satelilte_jers1sar=&start=${START}+00%3A00%3A00&end=${END}+00%3A00%3A00&maxy=${LATCEN}&minx=${LONCEN}&maxx=${LONCEN}&miny=${LATCEN}&gid=&aster_op_mode=Full&ASTER5=TRUE&ASTER6=TRUE&ASTER7=&ASTER8=&aster_cloud=${ASTCLOUD}&ASTER10=&ASTER11=&OPS1=&OPS2=&OPS3=&OPS4=&OPS5=&OPS6=&jers1ops_cloud=&SAR1=&SAR2="
    export ASTID=$(grep "<id>AST" $WORKDIR/aster.xml | sed 's/.*<id>\(.*\)<\/id>.*/\1/g')
    i=$(expr $i + 1)
done

#for ASTID in $ASTIDS; do
#    export ASTID
#    make ../AST_L3A/$(ASTID).tar.bz2
#done


make -R $OUTPUT
echo $ASTID > $INIMG.refast

#$WORKDIR/hodo.b4__shifted_to__aster.vnir3n.$EPSG.bsq $WORKDIR/hodo.b123__shifted_to__aster.vnir2.$EPSG.bsq

#$WORKDIR/aster.vnir3n.$EPSG.tif $WORKDIR/hodo.b4.tif $WORKDIR/aster.vnir3n.$EPSG.tif $WORKDIR/hodo.b123.tif

#merging back


exit 0
