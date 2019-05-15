#!/bin/bash

# Saves the serial number of the tegra to a file in the user home directory.
echo "[TARGET/SERIALNUMBER-SETUP.SH] Adding serialnumber to home folder and bashrc"
set -- $(cat /proc/cmdline)
for x in "$@"; do
    case "$x" in
        androidboot.serialno=*)
        serialnumber="${x#androidboot.serialno=}"
        echo $serialnumber > $HOME/.serialnumber
        echo "export SERIAL_NUMBER=\"$serialnumber\"" >> $HOME/.bashrc
        ;;
    esac
done