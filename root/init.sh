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
export test=$test



#Check Requirements
if [ -z "$feq" ] && [ -z "$test" ]
then
    echo "Required envirment variable missing. Please define feq with the radio frequency you wish to use. Refrence https://www.weather.gov/nwr/station_listing for your weather station frequency. example feq=162.550M"
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
    unset mqtt
else
    if [ -z "$mqttport" ]
    then
        export mqttport=1883
    fi
    echo "Starting MQTT Status updates"
    ./scripts/mqtt.py status &
    mqttclientprocess=$!
    trap 'kill -9 $mqttclientprocess' EXIT
    mqtt='--call scripts/mqtt.py --command {event} {MESSAGE} {ORG} {EEE} {PSSCCC} {TTTT} {JJJHHMM} {LLLLLLLL} {LANG}'
fi

if [ -z "$dsamelog" ]
then
    unset logenable
else
    logenable='--loglevel'
fi
if [ -z "$vlclogs" ]
then
    export vlclogs='--quiet'
fi
if [ -z "$same" ]
then
    unset same
    unset samecode
else
    export samecode='--same'
fi

if [ "$test" = true ]
then
    echo $samecode $same $logenable $dsamelog $mqtt
    sleep 10
    dsame.py $samecode $same $logenable $dsamelog $mqtt --msg "ZCZC-WXR-RWT-020103-020209-020091-020121-029047-029165-029095-029037+0030-1051700-KEAX/NWS"
    exit 0
else
    #Run
    dsame.py $samecode $same $logenable $dsamelog $mqtt --source scripts/owr.sh
fi