#!/bin/bash

STARTTIME=$(date)
echo ----------
echo $STARTTIME
echo ----------

docker build .
ENDTIME=$(date)

echo ----------
echo $ENDTIME
echo ----------

# https://unix.stackexchange.com/questions/24626/quickly-calculate-date-differences
datediff() {
    d1=$(date -d "$STARTTIME" +%s)
    d2=$(date -d "$ENDTIME" +%s)
    echo $(( (d2 - d1) )) seconds for the build
}

datediff
