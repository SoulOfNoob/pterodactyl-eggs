#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server
# Image to install with is 'ubuntu:18.04'
apt -y update
apt -y --no-install-recommends --no-install-suggests install curl lib32gcc-s1 ca-certificates

## download and install steamcmd
cd /tmp || exit
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd

mkdir -p /mnt/server/Engine/Binaries/ThirdParty/SteamCMD/Linux
tar -xzvf steamcmd.tar.gz -C /mnt/server/Engine/Binaries/ThirdParty/SteamCMD/Linux
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd || exit

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +force_install_dir /mnt/server +login anonymous +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} +quit ## other flags may be needed depending on install. looking at you cs 1.6

# Set up 32 and 64 bit libraries
mkdir -p /mnt/server/.steam/sdk{32,64}
cp -v linux32/steamclient.so /mnt/server/.steam/sdk32/steamclient.so
cp -v linux64/steamclient.so /mnt/server/.steam/sdk64/steamclient.so

## create a symbolic link for loading mods
cd /mnt/server/Engine/Binaries/ThirdParty/SteamCMD/Linux || exit
ln -sf /mnt/server/Steam/steamapps steamapps
cd /mnt/server || exit

# Check for successful installation
cd /mnt/server/ShooterGame/Binaries/Linux || exit
if [[ -f ShooterGameServer ]]; then
    echo -e "\nSatisfactory Dedicated Server successfully installed!\n"
else
    echo -e "\n\nSteamCMD failed to install the Ark Survival Evolved Dedicated Server!"
    echo -e "\tTry reinstalling the server again.\n"
    exit 1
fi
