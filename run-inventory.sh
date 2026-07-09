#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to clean up background processes on exit
cleanup() {
    echo -e "\nStopping Inventory Service and UI..."
    # Terminate all child processes of this script's process group or active jobs
    jobs -p | xargs -r kill -9 2>/dev/null
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

echo "Starting Inventory Service (Backend)..."
cd "$SCRIPT_DIR"
npm run start &
SERVICE_PID=$!

# Wait a brief moment to allow backend port binding
sleep 2

echo "Starting Inventory UI (Frontend)..."
cd "$SCRIPT_DIR/inventory-svelte-ui"
npm run dev &
UI_PID=$!

echo "Both services are running in parallel. Press Ctrl+C to stop both."
echo "------------------------------------------------------------------"

# Wait for background jobs to finish
wait
