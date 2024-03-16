#!/bin/bash

# If -b is supplied, backup the current executables (./firmware-upgrade.sh -b)
# If -r is supplied, restart all FSW using monit (./firmware-upgrade.sh -r)
# If -u is supplied, upgrade the firmware (./firmware-upgrade.sh -u)

if [ -z "$1" ] && [ $1 == "-b"]; then
    cp /usr/bin/dora/* /usr/bin/dora/backups/ # copy current executables into backup files, don't upgrade anything
    exit 0
elif [ -z "$1" ] && [ $1 == "-r"]; then
    monit restart all
elif [ -z "$1" ] && [ $1 == "-u"]; then
    # If no argument is supplied, upgrade the firmware - copy all executables from /home/dora/programs-upgrade/ to /usr/bin/dora/
    monit stop all
    cp /usr/bin/dora/* /usr/bin/dora/backups/ # copy current executables into backup files
    sleep 10 # Wait 10 seconds to let monit stop the program
    rm /usr/bin/dora/*
    mv /home/dora/programs-upgrade/* /usr/bin/dora/
    monit start all
fi
