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
HEATER="OFF"
mosquitto_sub -v -h $ipbroker -t buildings/$Building/Heater | while read line
do
message=$line
        IFS=' '
        read -ra array <<< $message 
        value=${array[1]}
        #echo $value
        if [ $value == "ACTIVATE" ]
        then
            value="ON"
            mosquitto_pub -h $ipbroker -t buildings/$Building/Heater -m $value
            echo HEATER was $HEATER, now is $value
            HEATER=$value
        elif [ $value == "DEACTIVATE" ]
        then
            value="OFF"
            mosquitto_pub -h $ipbroker -t buildings/$Building/Heater -m $value
            echo HEATER was $HEATER, now is $value
            HEATER=$value
        fi
done
