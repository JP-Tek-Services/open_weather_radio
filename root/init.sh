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
    export mqtt='--call scripts/mqtt.py --command {event} {MESSAGE} {ORG} {EEE} {PSSCCC} {TTTT} {JJJHHMM} {LLLLLLLL} {LANG}'
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

#define fumctions
mqtt_status () {
    echo "Starting MQTT Status updates"
    ./scripts/mqtt.py status
}

test_alert () {
    delay=10
    echo "Running EAS Test"
    echo "Test alert sending in:"
    for i in $(seq $delay -1 1)
    do
        echo "$i"
        sleep 1
    done
    dsame.py $samecode $same $logenable $dsamelog $mqtt --msg "ZCZC-WXR-RWT-020103-020209-020091-020121-029047-029165-029095-029037+0030-1051700-KEAX/NWS"
}

alert () {
    echo "Running Open Weather Radio"
    dsame.py $samecode $same $logenable $dsamelog $mqtt --source scripts/owr.sh
}

mqtt_status &
mqtt_status_pid=$!
sleep 2

if [ "$test" = true ]
then
    test_alert &
    test_EAS_alert_pid=$!
else
    alert &
    EAS_alert_pid=$!
fi



wait -n
error=$?
mqtt_status_process_error=`ps h $mqtt_status_pid`
test_EAS_alert_process_error=`ps h $test_EAS_alert_pid`
EAS_alert_process_error=`ps h $EAS_alert_pid`

if [ "$error" -gt "0" ];
then
    if [ -z "$mqtt_status_process_error" ];
    then
        echo "`date`:"
        echo "MQTT Status Process closed with error code: $error"
    fi
    if [ -z "$test_EAS_alert_process_error" ];
    then
        echo "`date`:"
        echo "Test EAS Alert Process Failed with error code: $error"
    fi
    if [ -z "$EAS_alert_process_error" ];
    then
        echo "`date`:"
        echo "EAS Alert Process Failed with error code: $error"
    fi
    kill 0
    exit $error
elif [ "$error" -eq "0" ];
then
    echo "Proccesses closed with exit code 0"
    kill 0
    exit 0
fi