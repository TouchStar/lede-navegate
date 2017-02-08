#!/bin/sh

# Generic get $1 from uboot environment
ubootenv_get() {
	if [ $# == 0 ]
	then
		return 1
	fi
	result=`fw_printenv $1 2>/dev/null`
	if [ $? == 0 ]
	then
		echo $( echo $result | cut -d = -f 2 | tr -d '"' )
	else
		return 1
	fi
}

# Generic set $1 as $2 in uboot environment
ubootenv_set() {
	if [ $# == 0 ]; then
		return 1
	fi
	local result=`fw_setenv $1 $2 2>/dev/null`
	if [ $? != 0 ];	then
		return 1
	fi	
}

# Get WLAN MACAddress in uppercase stripped for colons
wlanmac_get() {
	wlanmac=$(cat /sys/class/net/wlan0/address)
	if [ -z "$wlanmac" ]; then
		return 1
	else
        	# Strip colon, upper case then extract nic portion.
	        wlanmac=$(echo $wlanmac | tr -d : | tr [a-z] [A-Z])
	fi
	echo $wlanmac
}

# Get WLAN MACAddress nic component (last 6 hex digits)
wlanmac_nic_get() {
	wlanmac=$(wlanmac_get)	
	if [ $? == 0 ]; then
  		echo ${wlanmac:6}
  	else
  		return 1
  	fi
}

# Get Serial Number
serial_get() {
	serial=$(ubootenv_get ts_serial)
	if [ -z "$serial" ]; then
        return 1
	fi
	echo $serial
}

# Get DeviceID
deviceid_get() {
	deviceid=$(ubootenv_get ts_deviceid)
	if [ -z "$deviceid" ]; then
        return 1
	fi
	echo $deviceid
}

# Get GSM APN
apn_get() {
	apn=$(ubootenv_get ts_apn)
	if [ -z "$apn" ]; then
        return 1
	fi
	echo $apn
}

# Index of $2 in $1, 0 if not found, otherwise non-zero offset.
str_indexof() {
     local v1=$1
     local v2=$2
     tmp="${v1%%$v2*}"
     if [ "$tmp" != "$formatted" ]; then
        tmp=${#tmp}
     else
        tmp=0
     fi
     echo $tmp
}

# Populate default ubootvars (from uboot environment) used for format_get() below
populate_ubootvars() {
    nic=$(wlanmac_nic_get)
    serial=$(ubootenv_get ts_serial)
    deviceid=$(ubootenv_get ts_deviceid)
}

# Helper for substitution below
# $1 = formatted value, $2 = variable name to substitute with
# returns 1 if substitution occurred (with an actual value)
format_sub() {
    eval "value=\${$2}"
    result=$(echo $1 | sed -e "s/{$2}/${value}/g")
    if [ $result != $1 ] && [ -n "${value}" ]; then
    	RETV=1
    fi
    echo $result
    return $RETV
}

# Return a formatted string from uboot_env using substitution.
#
# usage {$format_get $1 $2} where
#
#   $1 is name of uboot_environment, $2 is the format string.
#
# Supported substitutions in format - {nic}, {serial}, {deviceid}
#
#   Variables ${substitution} must be present.
#
# For example: MyString-{nic} will replace {nic} with ${nic}
#
# Note: You can include an inner hyphen "-" which is replaced only 
#  if the substitution is present. For example MyString{-nic} will result
#  in "MyString" if ${nic} is empty or "MyString-ABCDEF" if ${nic} is "ABCDEF".
#
format_get() {
    if [ $# == 0 ]; then
        return 1
    fi
    formatted=$(ubootenv_get $1)
    if [ -z "$formatted" ]; then
        formatted=$2
    fi

      # detect location of innerhyphen "{-", then scrub it.
    innerhyphen=$(str_indexof $formatted "{-")
    formatted=$(echo $formatted | sed -e "s/{-/{/g")

      # determine auto from an in order (deviceid, serial, nic)
    if   [ -n "$deviceid" ]; then auto=$deviceid
    elif [ -n "$serial" ];   then auto=$serial
    else                          auto=$nic
    fi

      # format substitutions
    sub_count=0
    formatted=$(format_sub $formatted auto)
    sub_count=$(($sub_count+$?))
    formatted=$(format_sub $formatted nic)
    sub_count=$(($sub_count+$?))
    formatted=$(format_sub $formatted serial)
    sub_count=$(($sub_count+$?))
    formatted=$(format_sub $formatted deviceid)
    sub_count=$(($sub_count+$?))

      # handle innerhyphen, by adding it back to the formatted string (only if we subsituted).
    if [ $innerhyphen != 0 ] && [ "$sub_count" -gt 0 ]; then
 	start=`expr substr $formatted 1 $innerhyphen`
    	end=`expr substr $formatted $(($innerhyphen+1)) 100`
	formatted=$start-$end
    fi
    
    echo $formatted
}
