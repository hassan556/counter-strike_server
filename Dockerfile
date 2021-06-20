FROM ubuntu:latest

# labels
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hassan556/counter-strike_server"

# define default env variables
ENV PORT 27015
ENV MAP de_dust2
ENV MAXPLAYERS 16
ENV SV_LAN 0

# install dependencies
RUN dpkg --add-architecture i386
RUN apt-get update && \
    apt-get -qqy install lib32gcc1 curl libsdl2-2.0-0:i386

# create directories
WORKDIR /root
RUN mkdir Steam .steam

# download steamcmd
WORKDIR /root/Steam
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Try to install HLDS. This may take some time.
# Steam has this bug that they are not very interested in fixing. The
# workaround is to re-run this routine multiple times until it downloads 100%
# of the content. More info:
# https://developer.valvesoftware.com/wiki/SteamCMD#Linux
# Workaround: https://danielgibbs.co.uk/2013/11/hlds-steamcmd-workaround-appid-90/
RUN while test "$status" != "Success! App '90' fully installed."; do \
  status=$(./steamcmd.sh +login anonymous \
  +force_install_dir /hlds +app_update 90 validate +quit | \
  tail -1); \
done

# link sdk
WORKDIR /root/.steam
RUN ln -s ../Steam/linux32 sdk32

ADD files/steam_appid.txt /hlds/steam_appid.txt

# Add default config
ADD files/server.cfg /hlds/cstrike/server.cfg

# Fix missing custom.hpk
ADD files/custom.hpk /hlds/cstrike/custom.hpk

# Add maps
ADD maps/* /hlds/cstrike/maps/
ADD files/mapcycle.txt /hlds/cstrike/mapcycle.txt

ADD files/liblist.gam /hlds/cstrike/liblist.gam

# Remove this line if you aren't going to install/use amxmodx and dproto
ADD files/plugins.ini /hlds/cstrike/addons/metamod/plugins.ini

# Install AMX mod X
COPY --chown=steam:steam files/addons /hlds/cstrike/addons

# start server
WORKDIR /hlds
ENTRYPOINT ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +sv_lan $SV_LAN +map $MAP -maxplayers $MAXPLAYERS
