        if [ -n "$VSERVER_LOG_FILE" ]; then
            if sudo grep -q "Server started" "$VSERVER_LOG_FILE"; then
                log_found=true
                break
            else
                echo "Log file is found: $VSERVER_LOG_FILE, but 'Server started' message is not present."
                echo "--- Log file contents: $VSERVER_LOG_FILE ---"
                sudo cat "$VSERVER_LOG_FILE"
                echo "-------------------------------------------"
            fi
        else
            echo "Log file not found. Retrying in 5 seconds..."
        fi
        sleep 5
        attempt=$((attempt + 1))
