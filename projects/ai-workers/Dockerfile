FROM node:22-bullseye

# Install system dependencies and Python 3
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    openssh-server \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd
# Create a user 'agent' with a default password (will be overridden or used with env var strategy if needed)
RUN useradd -m -s /bin/bash agent && \
    echo 'agent:password' | chpasswd

# Allow password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Install Global NPM Packages (AI Tools)
RUN npm install -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli

# Set up directories
RUN mkdir -p /context
RUN chown agent:agent /context

# Set up working directory
WORKDIR /workspace
RUN chown agent:agent /workspace

# Expose SSH port
EXPOSE 22

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start SSH Server
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
