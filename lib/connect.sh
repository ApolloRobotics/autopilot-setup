source ./logger.sh

test_connection() {
  wget -q --spider http://google.com
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

wait_for_connection() {
    # Set the connection string to try a command to initate the connection
    connection_string=""
    eval "$connection_string"

    timeout=0
    until test_connection; do
        debug "Waiting for internet connection..."
        sleep 5
        timeout=$((timeout+1))
        eval "$connection_string"
        if [ "$timeout" -gt 60 ]; then
            #Time out here
            error "Waiting for connection timed out"
            exit 1
        fi
    done
    echo "Connected"
}