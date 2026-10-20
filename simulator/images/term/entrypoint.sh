#!/bin/bash
# Block internet egress (the real exam terminal only reaches the exam cluster). Allow loopback, docker DNS and the kind subnet.
if [ "${EXAM_ALLOW_INTERNET:-0}" != 1 ] && command -v iptables >/dev/null; then
  SUBNET=$(ip -4 route | awk '/dev eth0 proto kernel/{print $1; exit}')
  if [ -n "$SUBNET" ]; then
    iptables -F OUTPUT 2>/dev/null
    iptables -A OUTPUT -o lo -j ACCEPT
    iptables -A OUTPUT -d 127.0.0.11 -j ACCEPT
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -d "$SUBNET" -j ACCEPT
    iptables -A OUTPUT -j REJECT
  fi
fi
exec "$@"
