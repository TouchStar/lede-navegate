#!/bin/sh
# see cellular_powercycle.sh
echo 0 > /sys/class/gpio/gpio14/value
sleep 2.3
echo 1 > /sys/class/gpio/gpio14/value
