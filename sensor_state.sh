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
re='^[0-9]+$'
if [ $# -eq 0 ]
  then
    temperature=$(( $RANDOM % 30 ))
elif ! [[ $1 =~ $re ]]
 then
echo "Temperature value expected is an integer between 0 and 30"
exit 0
elif [ $1 -ge 0 ]&&[ $1 -le 30 ]
 then   
   temperature="$1"
else
  echo "Temperature value expected is an integer between 0 and 30"
  exit 0
fi
        
mosquitto_pub -h $ipbroker -t buildings/$Building/temperature -m $temperature
