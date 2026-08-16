#!/bin/sh
set -e

# Start Unbound in background
unbound &

# Wait briefly for socket initialization
sleep 2

# Exec unbound_exporter as primary PID 1 process
exec unbound_exporter -unbound.ca "" -unbound.cert "" -unbound.host "unix:///run/unbound.ctl"
