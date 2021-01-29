#!/bin/bash
# Copyright (c) 2021 Konstantellos Panagiotis, Zorbas Achileas. All rights reserved.
# Licensed under the GNU General Public License v3.0 or later. See LICENSE.md in the project root for license information.

set -e

# Check that the script is running as root. If not, then prompt for the sudo
# password and re-execute this script with sudo.
if [ "$(id -nu)" != "root" ]; then
    sudo -k
    pass=$(whiptail --backtitle "Graduino Installer" --title "Authentication required" --passwordbox "Installing Graduino requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $USER:" 12 50 3>&2 2>&1 1>&3-)
    exec sudo -S -p '' "$0" "$@" <<< "$pass"
    exit 1
fi

# Sets the current working directory
cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)/..

dotnet restore -v q
dotnet build -v q -c Release
npm install --prefix ./DigitalForge.Webapp.Meteo/
gulp --gulpfile ./DigitalForge.Webapp.Meteo/gulpfile.js
dotnet publish DigitalForge.Webapp.Meteo/DigitalForge.Webapp.Meteo.csproj -c Release --no-restore --no-build -o ./out/

service_exists() {
    local n=$1
    if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | cut -f1 -d' ') == $n.service ]]; then
        return 0
    else
        return 1
    fi
}

if service_exists dotnet-meteo; then
    systemctl stop dotnet-meteo
fi

rm -rf /opt/dotnet-meteo
cp -rf ./out /opt/dotnet-meteo
cp -rf Scripts/dotnet-meteo.service /etc/systemd/system/dotnet-meteo.service

systemctl daemon-reload
systemctl start dotnet-meteo

rm -rf ./out