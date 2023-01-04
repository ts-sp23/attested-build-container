#!/bin/sh

# Initialization script responsible for setting up port forwarding to the Envoy proxy
# and implementing a firewall to prevent bypassing the proxy.

dump() {
  iptables-save
}

trap dump EXIT

IFS=,

OUTBOUND_CAPTURE_PORT=8080
INBOUND_CAPTURE_PORT=15006
PROXY_UID=1000
PROXY_GID=${PROXY_UID}
PROXY_HEALTH_PORT=15021

INBOUND_PORTS_EXCLUDE="${PROXY_HEALTH_PORT}"

# Clear the iptables setup.
iptables -t nat -F
iptables -t nat -X
iptables -t filter -F
iptables -t filter -X

if [ "${1:-}" = "clean" ]; then
  echo "Only cleaning, no new rules added"
  exit 0
fi

# Dump out variables for debugging purposes.
echo "Variables:"
echo "----------"
echo "INBOUND_CAPTURE_PORT=${INBOUND_CAPTURE_PORT}"
echo "OUTBOUND_CAPTURE_PORT=${OUTBOUND_CAPTURE_PORT}"
echo "PROXY_UID=${PROXY_UID}"
echo "PROXY_GID=${PROXY_GID}"
echo "PROXY_HEALTH_PORT=${PROXY_HEALTH_PORT}"
echo "INBOUND_PORTS_EXCLUDE=${INBOUND_PORTS_EXCLUDE}"
echo

set -o errexit
set -o nounset
set -o pipefail
set -x # echo on

# New chain to redirect TCP connections originating from the sandboxed business logic
# container to the Envoy proxy listening on OUTBOUND_CAPTURE_PORT.
iptables -t nat -N PROXY_OUT_REDIRECT
iptables -t nat -A PROXY_OUT_REDIRECT -p tcp -j REDIRECT --to-port ${OUTBOUND_CAPTURE_PORT}

# New chain to redirect TCP connections to the sandboxed business logic container
# to the Envoy proxy listening on INBOUND_CAPTURE_PORT.
iptables -t nat -N PROXY_IN_REDIRECT
iptables -t nat -A PROXY_IN_REDIRECT -p tcp -j REDIRECT --to-port ${INBOUND_CAPTURE_PORT}

# New chain to handle incoming TCP connections.
iptables -t nat -N PROXY_INBOUND
iptables -t nat -A PREROUTING -p tcp -j PROXY_INBOUND

# Connections to these ports need not be redirected to the Envoy proxy.
# These ports are used to run health checks on the Envoy and OPA containers
# and we don't need to proxy them because they are trusted endpoints.
if [ -n "${INBOUND_PORTS_EXCLUDE}" ]; then
  for port in ${INBOUND_PORTS_EXCLUDE}; do
    iptables -t nat -A PROXY_INBOUND -p tcp --dport ${port} -j RETURN
  done
fi

# Redirect all other TCP traffic to the Envoy prxoy.
iptables -t nat -A PROXY_INBOUND -p tcp -j PROXY_IN_REDIRECT

# New chain to redirect traffic connection originating from the sandboxed
# business logic container to the Envoy proxy port.
iptables -t nat -N PROXY_OUTPUT
# All output TCP traffic is handled by the PROXY_OUTPUT chain.
iptables -t nat -A OUTPUT -p tcp -j PROXY_OUTPUT

# Handle traffic created by the Envoy user.
iptables -t nat -A PROXY_OUTPUT -m owner --uid-owner ${PROXY_UID} -m owner --gid-owner ${PROXY_GID} -j RETURN

# Don't redirect traffic that has localhost as a destination.
iptables -t nat -A PROXY_OUTPUT -d 127.0.0.1/32 -j RETURN

# Redirect all remaining traffic to Envoy.
iptables -t nat -A PROXY_OUTPUT -j PROXY_OUT_REDIRECT
