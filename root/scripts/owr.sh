#!/bin/bash
export DISPLAY=:0
echo INPUT: rtl_fm Device 1>&2
#Run radio and sending to multimon.ng(demodulation) and vlc via sox for http stream
until rtl_fm -f $freq -M fm -s 22050 -E dc -p $ppm -g $gain | tee >(multimon-ng -t raw -a EAS /dev/stdin) >(sox -traw -r22050 -es -b16 -c1 -V1 - -t flac - | su vlcuser -c "cvlc - --sout '#standard{access=http,mux=ogg,dst=0.0.0.0:8080}'") >/dev/null; do
    echo Restarting... >&2
    sleep 2
done