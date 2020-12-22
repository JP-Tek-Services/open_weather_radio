ARG BUILD_FROM
FROM $BUILD_FROM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

#Install Prereqs
RUN apt-get update && apt-get install -y cmake wget pulseaudio
RUN apt-get install --no-install-recommends --yes \ 
    curl \
    tzdata  \
    git  \
    python3  \
    python3-pip \
    rtl-sdr  \
    vlc \
    sox

RUN python3 -m pip install paho-mqtt
#Install Open Weather Radio dependicies
#Install multimon-ng
RUN wget https://github.com/EliasOenal/multimon-ng/archive/1.1.9.tar.gz && tar -xvf 1.1.9.tar.gz
RUN cd multimon-ng-1.1.9 && \
    mkdir build && cd build && \
    cmake .. && \
    make && \
    make install
#Install dsame
RUN git clone https://github.com/Jpeterson37/dsame.git && \
    cp dsame/dsame.py /usr/local/bin/ && cp dsame/defs.py /usr/local/bin/ && \
    chmod +x /usr/local/bin/dsame.py && chmod +x /usr/local/bin/defs.py

#VLC user for ogg http stream
RUN useradd -m vlcuser

# Main UI port
EXPOSE 8080

ENV feq=162.550M
ENV gain=40
ENV ppm=0
ENV mqttsvr=
ENV mqttport=
ENV mqttusr=
ENV mqttpwd=

COPY root /
CMD [ "/init.sh" ]