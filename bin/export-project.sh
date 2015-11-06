#!/bin/bash
SCRIPT=./applescript-export-project
OUTPUTDIR="/Users/iain/Pictures/Published"
YEAR=`date "+%Y"`
MONTH=`date "+%m"`
SIZE="JPEG - Thumbnail"
WATERMARK=false
EVERYTHING=true
PROJECT=`basename $1`
THEREST=`dirname $1`
if [ THEREST ]
then
    MONTH=`basename $THEREST`
    THEREST=`dirname $THEREST`
fi
if [ THEREST ]
then
    YEAR=`basename $THEREST`
fi
echo $PATH
$SCRIPT $YEAR $MONTH $PROJECT /tmp/testexport \"$SIZE\" $WATERMARK $EVERYTHING
