# Open Weather Radio

[![Support JP-Tek-Services on Patreon][patreon-shield]][patreon]

## About

Open Weather Radio is a docker container the leverages [RTL-SDR](https://amzn.to/3au9W0J) to listen for SAME messages sent via [NWR stations](https://www.weather.gov/nwr/station_listing) and send the decoded alerts via STDOUT and/or MQTT(if a broker is provided). An http ogg stream is also provided on http://hostip:8080


## Requirements
* [RTL-SDR](https://amzn.to/3au9W0J)
* Docker

## Optional
* MQTT Broker

## How to use:
Find the NWR station for your location by navigating to you state and county [here](https://www.weather.gov/nwr/station_listing). Use this frequncy for the freq varable below.

### Environment varable:
| Varable | Description | Required | Default | Example |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| freq | Frequency for [NWR stations](https://www.weather.gov/nwr/station_listing) | no | 162.550M | -e freq=162.550M |
| ppm | ppm error | no | 0 | -e ppm=0 |
| gain | Tuner gain | no | 40 | -e gain=40 |
| same | SAME code to use | no | | -e same="029165 029161 02916"|
| dsamelog | Set log level (int 1-10) | no | | -e dsamelog=10 |
| mqttsvr | MQTT Broker server address | no | | -e mqttsvr=192.168.0.x |
| mqttport | MQTT Broker Port | no | 1883 | -e mqttport=1883 |
| mqttusr | MQTT Broker Username | no | | -e mqttusr=username |
| mqttpwd | MQTT Broker Password | no | | -e mqttpwd='password' |
| -p | Port to forward for http ogg stream | yes | 8080:8080 | -p 8080:8080 |



## First run
```
docker pull jptekservices/open-weather-radio
```
### Non-privladged
```
docker run -t -i --device=/dev/the_rtl-sdr_path -p 8080:8080 -e freq=162.550M --name open-weather-radio jptekservices/open-weather-radio
```
### Privlaged
```
docker run -t --privileged -v /dev/bus/usb:/dev/bus/usb -p 8080:8080 -e freq=162.550M --name open-weather-radio jptekservices/open-weather-radio
```
## After first run
```
docker start -i open-weather-radio
```
## To stop
```
docker stop open-weather-radio
```

## License

MIT License

Copyright 2020 JP-Tek-Services

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[maintenance-shield]: https://img.shields.io/maintenance/yes/2020.svg
[patreon-shield]: https://jpeterson37.github.io/patreon/patreon.png
[patreon]: https://www.patreon.com/jptekservices

