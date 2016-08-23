#!/bin/sh

for F in /etc/init.d/* ; do $F enabled && echo $F on || echo $F **disabled**; done
