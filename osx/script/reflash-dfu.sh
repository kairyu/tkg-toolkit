#!/bin/bash
SCRIPT=$(basename "$0")
CURPATH=$(dirname "$0")
BINPATH=$CURPATH/../bin
SCRIPTPATH=$CURPATH/../script
EXEC=dfu-programmer
[ -z "$TARGET" ] && TARGET=atmega32u4
VER=
HEX=
HEX_ORIG=
EEP=

function usage {
	echo "Usage: $SCRIPT (eep | hex [hex | eep])"
	exit 1
}

function get_version {
	VERINFO=$("$EXEC" --version 2>&1)
	if [ $(echo $VERINFO | grep -c "0.6") -gt 0 ]
	then
		VER=0.6
	elif [ $(echo $VERINFO | grep -c "0.7") -gt 0 ]
	then
		VER=0.7
	else
		echo "dfu-programmer >= 0.6 not installed, please install first."
		exit 1
	fi
}

function wait_bootloader {
	echo "Waiting for Bootloader..."
	STARTTIME=$(date +"%s")
	REMIND=0
	while true
	do
		"$EXEC" $TARGET get > /dev/null 2>&1
		[ $? -eq 0 ] && break
		ENDTIME=$(date +"%s")
		DURATION=$(($ENDTIME-$STARTTIME))
		if [ $REMIND -eq 0 -a $DURATION -gt 30 ]
		then 
			echo "Did you forget to press the reset button?"
			REMIND=1
		fi
	done
}

[ -z "$1" ] && usage
[ ! -f "$1" ] && usage
ARG1=$1
ARG1_NAME=$(basename "$ARG1")
ARG1_EXT=${ARG1_NAME##*.}
case "$ARG1_EXT" in
	"hex")
		if [ "$#" -gt 1 ]
		then
			[ ! -f "$2" ] && usage
			ARG2=$2
			ARG2_NAME=$(basename "$ARG2")
			ARG2_EXT=${ARG2_NAME##*.}
			case "$ARG2_EXT" in
				"hex")
					HEX_ORIG=$ARG1
					HEX=$ARG2
					;;
				"eep")
					HEX=$ARG1
					EEP=$ARG2
					;;
			esac
		else
			HEX=$ARG1
		fi
		;;
	"eep")
		EEP=$ARG1
		;;
	*)
		usage
		;;
esac

get_version
wait_bootloader

if [ -n "$HEX" ]
then 
	echo "Erasing..."
	if [ "$VER" == "0.7" ]
	then 
		"$EXEC" $TARGET erase --force
	else	
		"$EXEC" $TARGET erase
	fi
	echo Reflashing HEX file...
	"$EXEC" $TARGET flash "$HEX"
fi 

if [ -n "$EEP" ]
then 
	echo "Reflashing EEP file..."
	if [ "$VER" == "0.7" ]
	then 
		"$EXEC" $TARGET flash-eeprom --force "$EEP"
	else	
		"$EXEC" $TARGET flash-eeprom "$EEP"
	fi

fi

EXITCODE=$?
if [ $EXITCODE -eq 0 ]
then
	echo "Success!"
else
	echo "Fail!"
fi

"$EXEC" $TARGET reset

exit $EXITCODE
