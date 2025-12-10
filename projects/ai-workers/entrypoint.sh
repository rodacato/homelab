#!/bin/bash

# Set password for 'agent' user if SSH_PASSWORD is provided
if [ -n "$SSH_PASSWORD" ]; then
    echo "agent:$SSH_PASSWORD" | chpasswd
    echo "Password for user 'agent' updated."
fi

# Execute the command passed to the container (usually sshd)
exec "$@"
