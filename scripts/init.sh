#!/bin/sh

x11vnc -storepasswd $VNC_PASS /etc/vncsecret
chmod 444 /etc/vncsecret

if [ -f "/data/download" ]; then
    echo "Creating download directory..."
    mkdir -p /data/download
fi

if [ -f "/data/tmp" ]; then
    echo "Creating tmp directory..."
    mkdir -p /data/tmp
fi

if [ $UID != "0" ]; then
    echo "Fixing permissions..."
    useradd --shell /bin/bash -u ${UID} -U -d /app -s /bin/false emule && \
    usermod -G users emule
    chown -R ${UID}:${GID} /data
    chown -R ${UID}:${GID} /app
fi

echo "Applying configuration..."
/app/launcher

echo "Running virtual desktop..."
/usr/bin/supervisord -n &
sleep 2
#winetricks vd=$RESOLUTION
winetricks vd=off
#winetricks orm=backbuffer
#winetricks ao=enabled
winetricks windowmanagerdecorated=y
winetricks windowmanagermanaged=y
#/usr/bin/wine explorer /desktop=shell,$RESOLUTION /app/emule.exe
/usr/bin/wine /app/emule.exe
