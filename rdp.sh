#!/bin/sh

argNumber="$1"
argUser="$2"
argPwd="$3"

if test -z $argNumber
    then #no arg provided
	read -p 'Render node number : ' number
	address=[REDACTED].1${number}
	rdesktop -g 1920x1080 -k "fr-be" -P -z -x l -r sound:off -u [REDACTED]${number} -p [REDACTED] ${address}:3389
    else #at least one arg provided
        if [[ $argNumber =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
            then #first arg is an ip address
                rdesktop -g 1920x1080 -k "fr-be" -P -z -x l -r sound:off $argNumber:3389 -u "$argUser" -p "$argPwd" 
            else #first arg is just node number
                rdesktop -g 1920x1080 -k "fr-be" -P -z -x l -r sound:off -u "$argUser" -p "$argPwd"  [REDACTED].1$argNumber:3389
        fi
fi
