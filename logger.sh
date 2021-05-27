
#!/bin/bash
filename=config.ini
LOGFILE=logfile.log
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
        
 #subscribe to temp values off all uildings
                        
mosquitto_sub -v -h ipbroker -t buildings/+/#  | while read line
do
message=$line           
#echo `date` $message >> $LOGFILE

file=$LOGFILE
n=$(( $(wc -l < "$file") - 50 ))
[[ $n -gt 0 ]] && sed -i 1,${n}d "$file"


        IFS=' '
        read -ra array <<< $message 
       
        topic=${array[0]}
        value=${array[1]}
                
               
        IFS='/'
        read -ra array <<< $topic
       
        sensor=${array[2]}
        N_building=${array[1]}
        index=${array[1]}-1
                        
         if [ "$sensor" == "temperature" ] 
                    then 
                        
                        if [ $value -le ${temp_building[index]} ] 
                        then 
                                echo `date` Building  $N_building - treshold ${temp_building[index]} Heater should go ON, temperature $va$  
                                
                        elif [ $value -gt ${temp_building[index]} ]
                        then 
                                echo `date` Building  $N_building -  treshold ${temp_building[index]} Heater should go OFF, temperature $$
                        
                        fi
                fi
         if [ "$sensor" == "Heater" ] 
                    then 
                        HEATER=$value
                        if [ $HEATER == "OFF" ] 
                        then 
                                echo `date` Building  $N_building - Heater  set on OFF >> $LOGFILE
                                
                        elif [ $HEATER == "ON" ] 
                        then 
                                 echo `date` Building  $N_building - Heater  set on ON >> $LOGFILE
                               
                        
                        fi
                fi
done