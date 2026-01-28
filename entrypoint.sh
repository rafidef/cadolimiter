#!/bin/bash

APP_NAME="cado-nfs"
TOTAL_CORES=112

while true; do
    # 1. GENERATE RANDOM TIMERS AND LIMIT
    RUN_DURATION=$(( ( RANDOM % 121 ) + 240 ))   # 4-6 minutes
    PAUSE_DURATION=$(( ( RANDOM % 121 ) + 180 )) # 3-5 minutes
    LIMIT_PCT=$(( ( RANDOM % 21 ) + 50 ))        # 50-70%
    LIMIT_VAL=$(( LIMIT_PCT * TOTAL_CORES ))

    # --- PHASE 1: RUNNING (WITH LIMIT) ---
    END_RUN=$(( $(date +%s) + RUN_DURATION ))
    echo "[$(date +%T)] STARTING RUN PHASE: $((RUN_DURATION / 60))m at $LIMIT_PCT%..."

    while [ $(date +%s) -lt $END_RUN ]; do
        PIDS=$(pgrep "$APP_NAME")
        if [ -n "$PIDS" ]; then
            for PID in $PIDS; do
                # Ensure it's unpaused and limited
                kill -CONT "$PID" 2>/dev/null
                if ! pgrep -f "cpulimit -p $PID -l $LIMIT_VAL" > /dev/null; then
                    pkill -f "cpulimit -p $PID"
                    nohup cpulimit -p "$PID" -l "$LIMIT_VAL" -z > /dev/null 2>&1 &
                fi
            done
        fi
        sleep 5
    done

    # --- PHASE 2: PAUSING ---
    END_PAUSE=$(( $(date +%s) + PAUSE_DURATION ))
    echo "[$(date +%T)] STARTING PAUSE PHASE: $((PAUSE_DURATION / 60))m..."

    while [ $(date +%s) -lt $END_PAUSE ]; do
        PIDS=$(pgrep "$APP_NAME")
        if [ -n "$PIDS" ]; then
            for PID in $PIDS; do
                # If we find the app, stop it and kill any active limiter
                pkill -f "cpulimit -p $PID"
                kill -STOP "$PID" 2>/dev/null
            done
        fi
        sleep 5
    done
done
