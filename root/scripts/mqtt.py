#!/usr/bin/env python3

import argparse
import json
import sys
import paho.mqtt.client as mqttClient
import time
import os
import sched, time
import datetime;

timesec = 60
sleep = 1
s = sched.scheduler(time.time, time.sleep)
global Connected
Connected = False

#Unervisal Alert
def build_alert(
    TYPE="online",
    MSG="",
    ORG="",
    EEE="",
    PSSCCC="",
    TTTT="",
    JJJHHMM="",
    LLLLLLLL="",
    LANG="" 
    ):
    #Build alert array
    alert = {
    "alert": TYPE,
    "attr": {
        "message": ' '.join(MSG.split()),
        "org": ORG,
        "event_code": EEE,
        "location_codes": PSSCCC,
        "purge_time": TTTT,
        "utc_purge_time": JJJHHMM,
        "station_callsign": LLLLLLLL,
        "language": LANG,
        "last_push": datetime.datetime.now().isoformat()
        }
    }
    return alert

#Setup MQTT Client
def mqtt_connect(): 
        
    #MQTT Server config
    broker_address = os.getenv('mqttsvr')
    port = int(os.getenv('mqttport'))
    user = os.getenv('mqttusr')
    password = os.getenv('mqttpwd')

    client = mqttClient.Client("open_weather_radio")               #create new instance
    client.username_pw_set(user, password=password)    #set username and password
    client.on_connect = on_connect                      #attach function to callback
    client.connect(broker_address, port=port)          #connect to broker
    client.loop_start()        #start the loop
    
 
    while Connected != True:    #Wait for connection
       time.sleep(0.1)
    
    return client

def on_connect(client, userdata, flags, rc):
 
    if rc == 0:
 
        print(datetime.datetime.now(),"- MQTT broker Connected")
        global Connected
        Connected = True                #Signal connection 
        
 
    else:
 
        print(datetime.datetime.now(),"- MQTT broker Connection failed")

#MQTT Client Disconnect
def mqtt_disconnect(client):
    client.disconnect(print(datetime.datetime.now(),"- MQTT Client disconnected"))
    client.loop_stop()
    global Connected
    Connected = False

#MQTT status topic
def owr_status(s):
    client = mqtt_connect()
    print(datetime.datetime.now(),"- Sending MQTT online")
    client.publish("open_weather_radio/status","online")
    client.publish("open_weather_radio/alerts",json.dumps(build_alert()))
    mqtt_disconnect(client)
    s.enter(60, 5, owr_status, (s,))
    s.run()

#Send SAME message when triggered
def owr_send_alert():
    #Alert values
    TYPE = sys.argv[1]
    MSG = sys.argv[2]
    ORG = sys.argv[3]
    EEE = sys.argv[4]
    PSSCCC = sys.argv[5]
    TTTT = sys.argv[6]
    JJJHHMM = sys.argv[7]
    LLLLLLLL = sys.argv[8]
    LANG = sys.argv[9]
    print(TYPE, MSG, ORG, EEE, PSSCCC, TTTT, JJJHHMM, LLLLLLLL, LANG)
    #Send via mqtt
    client = mqtt_connect()
    print(datetime.datetime.now(),"- Sending EASE Alert via MQTT")
    client.publish("open_weather_radio/status","online")
    client.publish("open_weather_radio/alerts",json.dumps(build_alert(TYPE, MSG, ORG, EEE, PSSCCC, TTTT, JJJHHMM, LLLLLLLL, LANG)))
    mqtt_disconnect(client)

    
#main 
if sys.argv[1] == 'status':
    owr_status(s)
else:
   owr_send_alert()