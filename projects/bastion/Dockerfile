FROM alpine:latest

# Install SSH, bash, vim, and Tailscale deps
RUN apk add --no-cache openssh bash vim tailscale iptables ca-certificates

# Configure SSH
RUN mkdir /var/run/sshd
# Allow password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start SSH Server
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
