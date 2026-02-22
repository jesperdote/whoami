#!/bin/sh

# 1. Create a background loop to update uptime.txt
# We use 'while true' to run this indefinitely.
# We write to the Nginx html directory.
(
    while true; do
        # Run uptime command and save to file
        uptime > /usr/share/nginx/html/.uptime.txt
        
        # Wait 5 seconds before updating again
        sleep 5
    done
) &

# 2. Start Nginx in the foreground
# 'exec' ensures Nginx takes over PID 1, which is best practice for signal handling
exec nginx -g "daemon off;"
