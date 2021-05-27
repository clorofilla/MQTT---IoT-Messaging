#!/bin/bash
filename=config.ini
if [ ! -f $filename ]
then
        touch $filename
        echo "ipbroker=172.18.0.2" >> $filename
        echo "Building=1" >> $filename
fi
#read each line of the config file 
ipbroker=$(awk -F "=" '/ipbroker/ {print $2}' $filename)
Building=$(awk -F "=" '/Building/ {print $2}' $filename)
if [ $# -eq 0 ]
  then
    echo "Specify a value ON or OFF"
    exit 0
fi
if [ $1 == "OFF" ] || [ $1 == "ON" ]
then
HEATER="$1"
mosquitto_pub -h $ipbroker -t buildings/$Building/Heater -m $HEATER
else
echo "Specify a value ON or OFF"
exit 0
fi