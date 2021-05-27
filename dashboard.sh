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

temp1=NA
temp2=NA
temp3=NA
heater1=NA
heater2=NA
heater3=NA

show_values() {
  date
  echo -e "DASHBOARD \n"
  echo "Building 1 Temperature is: $temp1"
  echo -e "Building 1 HEATER is: $heater1 \n"  
  echo "Building 2 Temperature is: $temp2"
  echo -e "Building 2 HEATER is: $heater2 \n"  
  echo "Building 3 Temperature is: $temp3"
  echo "Building 3 HEATER is: $heater3"
}
printf '%s\n' "$(clear; show_values)" 
#subscribe to temp values of all buildings
mosquitto_sub -v -h $ipbroker -t buildings/+/#  | while read line
do
message=$line
#echo $line 
 #check topic 
        IFS=' '
        read -ra array <<< $message 
       
        topic=${array[0]}
        value=${array[1]}               
        IFS='/'
        read -ra array <<< $topic
        #echo ${array[2]}
        sensor=${array[2]}
        N_building=${array[1]}  
     if [ "$sensor" == "temperature" ] 
                    then 
                        if [ $N_building == 1 ]
                        then    
                         temp1="$value"
                             
                                
                        elif [ $N_building == 2 ] 
						
                        then 
                              temp2="$value"   
                                                elif [ $N_building == 3 ] 
                        then 
                              temp3="$value"
                        fi
                fi
                                if [ "$sensor" == "Heater" ] 
                    then 
                       
                         if [ $N_building == 1 ]
                        then 
                                                heater1="$value"
                             
                                
                        elif [ $N_building == 2 ] 
                        then 
                              heater2="$value"   
                                                elif [ $N_building == 3 ] 
                        then 
                              heater3="$value"
                        fi
                fi
        printf '%s\n' "$(clear; show_values)"
done