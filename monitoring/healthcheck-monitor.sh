#!/bin/bash

# Configuration
URL="https://infdxeta.info/whoami/health.txt"
CONTAINER_NAME="devops-profile-container"
CHECK_INTERVAL=60 # seconds

echo "Monitoring health for $CONTAINER_NAME at $URL"

while true; do
    # Fetch HTTP status code and body content
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL")
    BODY=$(curl -s --max-time 10 "$URL" | tr -d '[:space:]')

    if [ "$HTTP_STATUS" -ne 200 ] || [ "$BODY" != "UP" ]; then
        echo "[$(date)] HEALTHCHECK FAILED: Status=$HTTP_STATUS, Body='$BODY'"
        echo "[$(date)] Restarting $CONTAINER_NAME..."
        docker restart "$CONTAINER_NAME"
        # Wait a bit longer after restart to allow container to come up
        sleep 30
    fi

    sleep "$CHECK_INTERVAL"
done
