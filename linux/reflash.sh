#!/bin/bash

### _   _            _              _ _    _ _
###| |_| | ____ _   | |_ ___   ___ | | | _(_) |_
###| __| |/ / _` |__| __/ _ \ / _ \| | |/ / | __|
###| |_|   < (_| |__| || (_) | (_) | |   <| | |_
### \__|_|\_\__, |   \__\___/ \___/|_|_|\_\_|\__|
###         |___/
###                                       REFLASH

CURPATH=$(dirname "$0")
CONFPATH=$CURPATH/conf
BINPATH=$CURPATH/bin
SCRIPTPATH=$CURPATH/script
FWPATH=$CURPATH/../common/firmware

function welcome {
	clear
	cat "$0" | grep -e "^###" | sed "s/^###//g"
	echo ""
}

function end {
	echo ""
	read -rsp "Press any key to continue . . . " -n 1 key
	echo ""
	exit
}

function check_config_file {
	if [ ! -f "$1" ]
	then
		echo ""
		echo "Config file does not exist, please run SETUP first"
		echo ""
		end
	fi
}

function load_config_file {
	check_config_file "$1"
	while read line
	do
		eval "$line"
	done < "$1"
}

function show_config {
	echo ""
	echo "Keyboard to reflash:"
	echo ""
	echo " Name:		$KBDNAME"
	echo " MCU:		$KBDMCU"
	echo " Bootloader:	$KBDBL"
	echo " Firmware:	$KBDFW"
	if [ -n "$KBDCOM" ]
	then
		echo " SerialPort:	$KBDCOM"
	fi
}

function select_manipulation {
	echo ""
	echo "Manipulation:"
	echo ""
	ARG="$@"
	if [ -z "$ARG" ]
	then
		EXITCODE=1
		echo " Reflash default firmware: ../common/firmware/$KBDFW"
	elif [ -f "$ARG" ]
	then
		ARG_NAME=$(basename "$ARG")
		ARG_EXT=${ARG_NAME##*.}
		if [ "$ARG_EXT" == "hex" ]
		then
			EXITCODE=2
			echo " Reflash firmware: \"$ARG\""
		elif [ "$ARG_EXT" == "eep" ]
		then
			EXITCODE=3
			echo " Reflash eeprom: \"$ARG\""
		else
			echo " Wrong argument: \"$ARG\""
			end
		fi
	else
		echo " Wrong argument: \"$ARG\""
		end
	fi
	echo ""
	read -p "Do you want to continue? [Y/n] " INPUT
	[ "$INPUT" == "q" -o "$INPUT" == "n" ] && exit
	return $EXITCODE
}

function reflash {
	echo ""
	case "$KBDBL" in
		"atmel_dfu")
			TARGET=$KBDMCU
			if [ -z "$ARG2" ]
			then
				"$SCRIPTPATH/reflash-dfu.sh" "$ARG1"
			else
				"$SCRIPTPATH/reflash-dfu.sh" "$ARG1" "$ARG2"
			fi
			;;
		"lufa_dfu")
			TARGET=$KBDMCU
			"$SCRIPTPATH/reflash-dfu.sh" "$ARG1"
			;;
		"arduino")
			PARTNO=$KBDMCU
			COM=$KBDCOM
			"$SCRIPTPATH/reflash-arduino.sh" "$ARG1"
			;;
		*)
			echo "Unsupported bootloader"
			end
	esac
}

welcome

CONFFILE=$CONFPATH/default.ini
load_config_file "$CONFFILE"
KBDNAME=$Name
KBDMCU=$MCU
KBDBL=$Bootloader
KBDFW=$Firmware
if [ -n "$SerialPort" ]
then
	KBDCOM=$SerialPort
else
	KBDCOM=
fi

show_config

ARG="$@"
select_manipulation "$ARG"
MANIP=$?

ARG1=
ARG2=
case $MANIP in
	1)
		ARG1="$FWPATH/$KBDFW"
		;;
	2)
		ARG1="$ARG"
		;;
	3)
		if [ "$KBDBL" == "atmel_dfu" ]
		then
			ARG1="$FWPATH/$KBDFW"
			ARG2="$ARG"
		else
			ARG1="$ARG"
		fi
		;;
	*)
		exit
		;;
esac

reflash

end
