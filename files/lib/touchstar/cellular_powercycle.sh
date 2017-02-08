#!/bin/sh
BASEDIR=$(dirname "$0")

# Cinterion PHP8 - power control - assumes "AT^SCFG=MEShutdown/OnIgnition,ON"
# Here we assume the modem was powered for at least 5s.

sleep 1.0
$BASEDIR/cellular_poweroff.sh
sleep 5.0
$BASEDIR/cellular_poweron.sh
