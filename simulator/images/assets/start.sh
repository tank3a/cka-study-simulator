#!/bin/sh
registry serve /etc/registry.yml &
exec nginx -g 'daemon off;'
