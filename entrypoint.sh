#!/bin/bash

APP_NAME="cado-nfs"
TOTAL_CORES=240

while true; do
    PIDS=$(pgrep "$APP_NAME")

    if [ -n "$PIDS" ]; then
        # Calculate random % between 50 and 70 of TOTAL system capacity
        # Range is 12000 to 16800 for 240 cores
        RAND_PERCENT=$(( ( RANDOM % 21 ) + 50 ))
        LIMIT=$(( RAND_PERCENT * TOTAL_CORES ))
        
        echo "[$(date +%T)] $APP_NAME detected. Total System Goal: $RAND_PERCENT% (Limit: $LIMIT%)"

        for PID in $PIDS; do
            # Refresh cpulimit with the new random value
            pkill -f "cpulimit -p $PID"
            nohup cpulimit -p "$PID" -l "$LIMIT" -z > /dev/null 2>&1 &
        done
        
        # Random sleep between 2 and 5 minutes
        SLEEP_TIME=$(( ( RANDOM % 181 ) + 120 ))
        echo "Holding this limit for $((SLEEP_TIME / 60))m $((SLEEP_TIME % 60))s..."
        sleep $SLEEP_TIME
    else
        echo "[$(date +%T)] $APP_NAME not running. Checking again in 10s..."
        sleep 10
    fi
done
