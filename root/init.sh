#!/bin/bash


export ppm=$ppm
export freq=$freq
export gain=$gain
export same=$same
export dsamelog=$dsamelog
export mqttsvr=$mqttsvr
export mqttusr=$mqttusr
export mqttpwd=$mqttpwd
export vlclogs=$vlclogs



#Check Requirements
if [ -z "$feq" ]
then
    echo "Required envirment variable missing. Please define feq with teh radio frequency you wish to use. Refrence https://www.weather.gov/nwr/station_listing for your weather station frequency. example feq=162.550M"
    exit 1
else
    if [ -z "$gain" ]
    then
        export gain=40
    fi
    if [ -z "$ppm" ]
    then
        export ppm=0
    fi
fi
#set defaults
if [ -z "$mqttsvr" ]; 
then
    mqtt=''
else
    if [ -z "$mqttport" ]
    then
        export mqttport=1883
    fi
    echo "Starting MQTT Status updates"
    ./scripts/mqtt.py status &
    mqtt='--call scripts/mqtt.py --command "{event}" "{MESSAGE}" "{ORG}" "{EEE}" "{PSSCCC}" "{TTTT}" "{JJJHHMM}" "{LLLLLLLL}" "{LANG}"'
fi

if [ -z "$dsamelog" ]
then
    logenable=''
else
    logenable='--loglevel'
fi
if [ -z "$vlclogs" ]
then
    export vlclogs='--quiet'
fi
if [ -z "$same" ]
then
    export same=''
else
    export samecode='--same'
fi

#Run
dsame.py $samecode $same $logenable $dsamelog $mqtt --source scripts/owr.sh