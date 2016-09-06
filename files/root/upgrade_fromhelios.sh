#!/bin/sh
scp -i ~/.ssh/id_rsa device@machine20.touchstar.com.au:/tftpboot/firmware$1.bin /tmp/firmware.bin
if [ $? -ne 0 ]; then
    echo "Unable to download firmware$1.bin from helios"
    exit 1
fi

#################################################
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! This is a destructive operation !!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo "The operating system will be upgraded with [firmware$1.bin]"
echo
read -p "Are you sure? (y/N) " -n 1 -r
echo
if ! echo "$REPLY" | grep -iq "^y"; then
    rm /tmp/firmware.bin
    exit 1
fi
sysupgrade $2 /tmp/firmware.bin
