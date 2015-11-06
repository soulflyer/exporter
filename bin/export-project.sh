#!/bin/bash
SCRIPT="/usr/bin/osascript /Users/iain/Library/Scripts/TestScript.scpt"
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
# Big problem. Called like this, aperture returns an error "Can't get file
# naming policy" The exact same command run from the shell works ok.
$SCRIPT $YEAR $MONTH $PROJECT /tmp/testexport \"$SIZE\" $WATERMARK $EVERYTHING
