#!/bin/bash

# Start Tailscale
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
    mkdir -p /var/lib/tailscale
    mkdir -p /run/tailscale
    
    # Start tailscaled in background
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock &
    
    # Wait for daemon
    sleep 3
    
    # Authenticate and bring up interface (with --reset to avoid state conflicts)
    tailscale up --reset --authkey="${TAILSCALE_AUTH_KEY}" --hostname="${TS_HOSTNAME:-bastion-homelab}" --ssh
fi

USER_NAME=${SSH_USER:-balrog}
USER_PASS=${SSH_PASSWORD:-password}

# Create user if it doesn't exist
if ! id "$USER_NAME" &>/dev/null; then
    adduser -D -s /bin/bash "$USER_NAME"
    echo "$USER_NAME:$USER_PASS" | chpasswd
    echo "User '$USER_NAME' created."
else
    # Update password if user exists
    echo "$USER_NAME:$USER_PASS" | chpasswd
    echo "Password for user '$USER_NAME' updated."
fi


# Generate host keys if missing (Alpine doesn't do this automatically on boot like standard Ubuntu)
ssh-keygen -A

# Execute the command passed to the container (usually sshd)
exec "$@"
