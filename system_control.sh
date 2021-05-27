#!/bin/bash
filename=config.ini
if [ ! -f $filename ]
then
    touch $filename
        echo "temp_building1=11" >> $filename
        echo "temp_building2=14" >> $filename
        echo "temp_building3=18" >> $filename
        echo "ipbroker=172.18.0.2" >> $filename
fi
#read each line of the config file 
temp_building[0]=$(awk -F "=" '/temp_building1/ {print $2}' $filename)
temp_building[1]=$(awk -F "=" '/temp_building2/ {print $2}' $filename)
temp_building[2]=$(awk -F "=" '/temp_building3/ {print $2}' $filename)
ipbroker=$(awk -F "=" '/ipbroker/ {print $2}' $filename)

#subscribe to temp values off all buildings
mosquitto_sub -v -h $ipbroker -t buildings/+/#  | while read line
do
message=$line
        
 #check topic 
        IFS=' '
        read -ra array <<< $message 
        #echo ${array[0]}
        topic=${array[0]}
        value=${array[1]}
               
        IFS='/'
        read -ra array <<< $topic
		 
        sensor=${array[2]}
        N_building=${array[1]}
        index=${array[1]}-1

         if [ "$sensor" == "temperature" ] 
                    then 
                        #echo ${array[2]}
                        if [ $value -le ${temp_building[index]} ] 
                        then 
                                mosquitto_pub -h $ipbroker -t buildings/$N_building/Heater -m ACTIVATE
                                echo Building $N_building -  Heater ON treshold ${temp_building[index]} , temperature $value
								
                        elif [ $value -gt ${temp_building[index]} ] 
                        then 
                                mosquitto_pub -h $ipbroker -t buildings/$N_building/Heater -m DEACTIVATE
                                echo Building $N_building - Heater OFF treshold ${temp_building[index]} , temperature $value
                                                      
                        fi
                fi
done

