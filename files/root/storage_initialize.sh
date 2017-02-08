#!/bin/sh
disk="/dev/sda"
#######################################
dd if=$disk of=/dev/null count=0 2> /dev/null
if [ $? -ne 0 ]; then
	echo "Please insert storage card in $disk"
	exit 1
fi
########################################
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! This is a destructive operation !!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo "Storage [$disk] will be permanently erased"
echo
read -p "Are you sure? (y/N) " -n 1 -r
echo
if ! echo "$REPLY" | grep -iq "^y"; then 
    exit 1
fi
########################################
block umount
echo "d
n
p
1


w
"|fdisk $disk > storage_initialize.log 2>&1
block umount
mkfs.ext4 -F "$disk"1 >> storage_initialize.log 2>&1
echo "DONE!"
