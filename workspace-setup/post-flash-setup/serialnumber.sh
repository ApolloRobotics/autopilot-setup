#!/bin/bash

get_serial_number(){
    set -- $(cat /proc/cmdline)
    for x in "$@"; do
        case "$x" in
            androidboot.serialno=*)
            serialnumber="${x#androidboot.serialno=}"
            echo $serialnumber
            ;;
        esac
    done
}

# Saves the serial number of the tegra to a file in the user home directory.
set_serial_number(){
    echo -e "\033[42m[TARGET/SERIALNUMBER-SETUP.SH] Adding serialnumber to home folder and bashrc\033[0m"
    SERIALNO=$(get_serial_number)
    echo $SERIALNO > $HOME/.serialnumber
    echo "export SERIAL_NUMBER=\"$SERIALNO\"" >> $HOME/.bashrc
}