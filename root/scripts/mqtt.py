#!/usr/bin/env python3

import argparse
import json
import sys
import paho.mqtt.client as mqttClient
import time
import os
import sched, time

s = sched.scheduler(time.time, time.sleep)


def on_connect(client, userdata, flags, rc):
 
    if rc == 0:
 
        print("Connected to broker")
 
        global Connected                #Use global variable
        Connected = True                #Signal connection 
 
    else:
 
        print("Connection failed")
 
Connected = False   #global variable for the state of the connection

broker_address = os.getenv('mqttsvr')
port = int(os.getenv('mqttport'))
user = os.getenv('mqttusr')
password = os.getenv('mqttpwd')

client = mqttClient.Client("open_weather_radio")               #create new instance
client.username_pw_set(user, password=password)    #set username and password
client.on_connect= on_connect                      #attach function to callback
client.connect(broker_address, port=port)          #connect to broker
client.loop_start()        #start the loop
 
while Connected != True:    #Wait for connection
    time.sleep(0.1)



#MQTT status topic
def owr_status(sc):
    print("Sending MQTT Online update")
    client.publish("open_weather_radio/status","online")
    client.disconnect()
    client.loop_stop()
    s.enter(60, 1, owr_status, (sc,))
    return

#Send SAME message when triggered
def owr_send_alert():

    TYPE = sys.argv[1]
    MSG = sys.argv[2]
    ORG = sys.argv[3]
    EEE = sys.argv[4]
    PSSCCC = sys.argv[5]
    TTTT = sys.argv[6]
    JJJHHMM = sys.argv[7]
    LLLLLLLL = sys.argv[8]
    LANG = sys.argv[9]
    
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
          "language": LANG
      }
    }
    #Send via mqtt
    print("Sending MQTT Message")
    client.publish("open_weather_radio/status","online")
    client.publish("open_weather_radio/alerts",json.dumps(alert))
    print("Closing connection to broker")
    client.disconnect()
    client.loop_stop()
    return

if sys.argv[1] == 'status':
    s.enter(60, 1, owr_status, (s,))
    s.run()
else:
   owr_send_alert()