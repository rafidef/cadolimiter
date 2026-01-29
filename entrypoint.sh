#!/bin/bash

APP_NAME="cado-nfs"

# --- DETEKSI CORE OTOMATIS ---
TOTAL_CORES=$(nproc)
echo "[$(date +%T)] Terdeteksi $TOTAL_CORES core di mesin ini."

while true; do
    # GENERATE RANDOM TIMERS AND LIMIT
    RUN_DURATION=$(( ( RANDOM % 121 ) + 240 ))   # 4-6 menit
    PAUSE_DURATION=$(( ( RANDOM % 121 ) + 180 )) # 3-5 menit
    LIMIT_PCT=$(( ( RANDOM % 21 ) + 50 ))        # 50-70%
    
    # Hitung nilai limit berdasarkan total core (misal: 60 * 240 = 14400)
    LIMIT_VAL=$(( LIMIT_PCT * TOTAL_CORES ))

    # --- PHASE 1: RUNNING (WITH LIMIT) ---
    END_RUN=$(( $(date +%s) + RUN_DURATION ))
    echo "[$(date +%T)] PHASE: RUNNING ($((RUN_DURATION / 60))m) | Target: $LIMIT_PCT% ($LIMIT_VAL% CPU)"

    while [ $(date +%s) -lt $END_RUN ]; do
        PIDS=$(pgrep "$APP_NAME")
        if [ -n "$PIDS" ]; then
            for PID in $PIDS; do
                kill -CONT "$PID" 2>/dev/null
                # Cek apakah limiter sudah berjalan dengan nilai yang benar
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
    echo "[$(date +%T)] PHASE: PAUSED ($((PAUSE_DURATION / 60))m) | Melepas semua CPU..."

    while [ $(date +%s) -lt $END_PAUSE ]; do
        PIDS=$(pgrep "$APP_NAME")
        if [ -n "$PIDS" ]; then
            for PID in $PIDS; do
                pkill -f "cpulimit -p $PID"
                kill -STOP "$PID" 2>/dev/null
            done
        fi
        sleep 5
    done
done
