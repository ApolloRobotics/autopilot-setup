connection_string=""

eval "$connection_string"

test_connection() {
  wget -q --spider http://google.com
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

timeout=0
until test_connection; do
    echo -e "\033[42m[TARGET/CONNECT.SH] Waiting for internet connection...\033[0m"
    sleep 5
    timeout=$((timeout+1))
    eval "$connection_string"
    if [ "$timeout" -gt 60 ]; then
        #Time out here
        echo "install.sh connection timed out"
        exit 1
    fi
done
echo "Connected"
