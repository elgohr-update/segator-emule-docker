FROM golang:1.13-stretch AS launcher-builder

WORKDIR /root
COPY launcher /root
RUN go build -o launcher

FROM ubuntu:18.04
MAINTAINER Aitor González

ENV UID 0
ENV GUI 0
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /root

RUN dpkg --add-architecture i386
RUN apt-get update && \
    apt-get -y install nano unzip wget tar curl gnupg software-properties-common xvfb xdotool supervisor net-tools fluxbox

ENV WINEDLLOVERRIDES=mscoree=d;mshtml=d

RUN  apt update -y && apt install  wget gnupg2 software-properties-common -y && \
     dpkg --add-architecture i386 && \
     wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
     apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' && \
     add-apt-repository ppa:cybermax-dexter/sdl2-backport && \
     apt update && apt install --install-recommends winehq-stable winetricks -y




# Add a web UI for debug purposes
RUN apt-get update && apt-get -y install x11vnc
WORKDIR /root/
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.1.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html && \
    wget -O - https://github.com/novnc/websockify/archive/v0.8.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.8.0 /root/novnc/utils/websockify

WORKDIR /app

RUN curl https://www.emule-project.net/files/emule/eMule0.51d.zip --output /tmp/emule.zip && \
    unzip /tmp/emule.zip -d /tmp && mv /tmp/eMule0.51d/* /app && rm /tmp/emule.zip

ENV RESOLUTION=1600x900
ENV WINEPREFIX /app/.wine
ENV WINEARCH win32
ENV DISPLAY :0
ENV WEB_PASS=19A2854144B63A8F7617A6F225019B12
ENV VNC_PASS=admin
COPY config/fluxbox-init /root/.fluxbox/init
COPY config/fluxbox-apps /root/.fluxbox/apps
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts /app
COPY --from=launcher-builder /root/launcher /app
COPY config/emule /app/config

EXPOSE 4711/tcp 23732/tcp 23733/udp
VOLUME /app/config /data

ENTRYPOINT ["/app/init.sh"]
