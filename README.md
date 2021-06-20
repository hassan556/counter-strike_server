# CS 1.6 Dedicated Server

This is a HLDS setup I made for CS with custom addons and an easy ramp-up. It
also fixes several installation issues most people have when trying to create a
dedicated CS server.

This image is based on `debian:9` and the game server is set up via steamcmd.
It aims to provide a simple method to set up a basic and also customizable Counter-Strike 1.6 server via Docker.

## What's in it?

* Custom maps
* Metamod (1.21.1-am)
* AMX Mod X (1.8.2)

Custom AMX plugins:

* Gore
* CS Nade Drops
* No Nade Through Walls
* AMX Match Deluxe


[![Docker Automated build](https://img.shields.io/docker/automated/febley/counter-strike_server.svg)](https://hub.docker.com/r/febley/counter-strike_server/builds/) [![Docker Build Status](https://img.shields.io/docker/build/febley/counter-strike_server.svg)](https://hub.docker.com/r/febley/counter-strike_server/builds/) [![Download size](https://images.microbadger.com/badges/image/febley/counter-strike_server.svg)](https://microbadger.com/images/febley/counter-strike_server) [![Commit](https://images.microbadger.com/badges/commit/febley/counter-strike_server.svg)](https://microbadger.com/images/febley/counter-strike_server)


## Setup

The fastest way to set this up is to pull the image and start it via `docker run`.

``` bash
docker pull febley/counter-strike_server
```

``` bash
docker run --name counter-strike_server -p 27015:27015/udp -p 27015:27015 febley/counter-strike_server:latest
```

However it's recommend to run the server via `docker-compose`. You can find an example docker-compose.yml below.

## Available environment variables

| Variable   | Value    |
| ---------- | -------- |
| PORT       | 27015    |
| MAP        | de_dust2 |
| MAXPLAYERS | 16       |
| SV_LAN     | 0        |

## Custom config files

You can add you own `server.cfg`, `users.ini`, `banned.cfg`, `listip.cfg` and `mapcycle.txt` by linking them as volumes into the image.

``` bash
-v /path/to/your/server.cfg:/hlds/cstrike/server.cfg
```

The complete command looks like this:

``` bash
docker run --name counter-strike_server -p 27015:27015/udp -p 27015:27015 -v /path/to/your/server.cfg:/hlds/cstrike/server.cfg febley/counter-strike_server:latest
```

Keep in mind the server.cfg file can override the settings from your environment variables:  
`MAP`, `MAXPLAYERS` and `SV_LAN`

Also, configure `AMXModX` as you wish by modifying the files on
`addons/amxmodx`.

There are some settings related to server initialization that are located on
`.env` file. Changes on them will most likely require a restart.

Adding new maps require you to restart the server.

### Example server.cfg

```
// Use this file to configure your DEDICATED server.
// This config file is executed on server start.

// disable autoaim
sv_aim 0

// disable clients' ability to pause the server
pausable 0

// default server name. Change to "Bob's Server", etc.
hostname "Counter-Strike 1.6 Server"

// RCON password
rcon_password "password"

// default map
map de_dust2

// maximum client movement speed
sv_maxspeed 320

// 20 minute timelimit
mp_timelimit 20

// disable cheats
sv_cheats 0

// load ban files
exec listip.cfg
exec banned.cfg
```

## Docker Compose

Create a `docker-compose.yml` file and start the server via `docker-compose up -d`.

### Example docker-compose.yml

``` yml
version: '3'

services:

  hlds:
    container_name: counter-strike-16_server
    image: arknet/counter-strike-16_server:latest
    restart: always
    environment:
      - PORT=27015
      - MAP=de_dust2
      - MAXPLAYERS=16
      - SV_LAN=0
    ports:
      - 27015:27015/udp
      - 27015:27015
    volumes:
      - /path/to/your/banned.cfg:/hlds/cstrike/banned.cfg
      - /path/to/your/listip.cfg:/hlds/cstrike/listip.cfg
      - /path/to/your/server.cfg:/hlds/cstrike/server.cfg
      - /path/to/your/mapcycle.txt:/hlds/cstrike/mapcycle.txt
      - /path/to/your/users.ini:/hlds/cstrike/addons/amxmodx/configs/users.ini
```
