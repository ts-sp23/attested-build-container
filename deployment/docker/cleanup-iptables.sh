# Enable exit on non 0
set -e

# Handle traffic created by the Envoy user.
sudo iptables -t nat -D OUTPUT -m owner --uid-owner 1000 -m owner --gid-owner 1000 -j RETURN

# Don't redirect traffic that has localhost as a destination.
sudo iptables -t nat -D OUTPUT -d 127.0.0.1/32 -j RETURN

# Redirect rest of the traffic to envoy
sudo iptables -t nat -D OUTPUT -p tcp -j REDIRECT --to-port 8080
