#!/bin/sh
scp -i ~/.ssh/id_rsa device@machine20.touchstar.com.au:/tftpboot/firmware$1.bin /tmp/firmware.bin
sysupgrade $2 /tmp/firmware.bin
