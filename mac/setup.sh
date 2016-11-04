#!/bin/bash

### _   _            _              _ _    _ _
###| |_| | ____ _   | |_ ___   ___ | | | _(_) |_
###| __| |/ / _` |__| __/ _ \ / _ \| | |/ / | __|
###| |_|   < (_| |__| || (_) | (_) | |   <| | |_
### \__|_|\_\__, |   \__\___/ \___/|_|_|\_\_|\__|
###         |___/
###                                         SETUP

CURPATH=$(dirname "$0")
CONFPATH=$CURPATH/conf
BINPATH=$CURPATH/bin
SCRIPTPATH=$CURPATH/script
KBDFILE=$CURPATH/../common/config/keyboards.json
JQ=$BINPATH/jq

function jq {
	if [[ ! -x "$JQ" ]]
	then
		JQ=$(which jq)
	fi
	cat "$KBDFILE" | "$JQ" "$1"# | sed "s/\"//g"
}

function welcome {
	clear
	cat "$0" | grep -e "^###" | sed "s/^###//g"
	echo ""
}

function print_list {
	local INDEX=0
	while [ $# -gt 0 ]
	do
		INDEX=$(($INDEX+1))
		printf " %2d. %s\n" $INDEX "$1"
		shift
	done
}

function select_from_list {
	if [ "$1" -eq "$1" ] 2>/dev/null
	then
		local DEFAULT=$1
		shift
	fi

	print_list $@
	local COUNT=$#
	echo ""
	while true
	do
		printf "Please enter a number: "
		if [ -n "$DEFAULT" ]
		then
			INPUT=$DEFAULT
			printf "$DEFAULT"
			for b in {1..${#DEFAULT}}
			do
				printf "\b"
			done
		fi

		read INPUT </dev/tty
		[ "$INPUT" == "q" ] && exit
		[ "$INPUT" == "" ] && INPUT=$DEFAULT
		INPUT=$(($INPUT))
		if [ $INPUT -ge 1 -a $INPUT -le $COUNT ]
		then
			return $INPUT
		fi
	done
	return $INPUT
}

function select_keyboard {
	echo ""
	echo "Select your keyboard:"
	echo ""
	IFS=$'\n'; select_from_list $(jq ".[].name")
	return $?
}

function print_keyboard_info {
	echo ""
	INDEX=$1
	KBDNAME=$(jq ".[$INDEX].name")
	KBDFW=$(jq ".[$INDEX].firmware | map(.name) | join(\", \")")
	KBDBL=$(jq ".[$INDEX].bootloader | map(.name) | join(\", \")")
	echo " Name:       $KBDNAME"
	echo " Firmware:   $KBDFW"
	echo " Bootloader: $KBDBL"
	echo ""
}

function select_firmware {
	echo ""
	echo "Select a firmware for your keyboard:"
	echo ""
	IFS=$'\n'; select_from_list 1 $(jq ".[$1].firmware[].name")
	return $?
}

function select_bootloader {
	echo ""
	echo "Select bootloader of your keyboard:"
	echo ""
	IFS=$'\n'; select_from_list 1 $(jq ".[$1].bootloader[].name")
	return $?
}

while true
do
	welcome
	select_keyboard
	KBDINDEX=$(($?-1))

	print_keyboard_info $KBDINDEX
	read -p "Do you want to continue? [Y/n] " INPUT
	[ "$INPUT" == "q" ] && exit
	[ "$INPUT" != "n" ] && break
done

select_firmware $KBDINDEX
FWINDEX=$(($?-1))
KBDMCU=$(jq ".[$KBDINDEX].firmware[$FWINDEX].mcu")
KBDFW=$(jq ".[$KBDINDEX].firmware[$FWINDEX].file")

select_bootloader $KBDINDEX
BLINDEX=$(($?-1))
KBDBL=$(jq ".[$KBDINDEX].bootloader[$BLINDEX].name")

CONFFILE=$CONFPATH/default.ini
mkdir -p "$CONFPATH" 2>/dev/null
echo "Name=\"$KBDNAME\"" > "$CONFFILE"
echo "MCU=$KBDMCU" >> "$CONFFILE"
echo "Firmware=$KBDFW" >> "$CONFFILE"
echo "Bootloader=$KBDBL" >> "$CONFFILE"
echo ""
echo "Your config has been saved"
echo ""

read -rsp "Press any key to continue . . . " -n 1 key
echo ""
exit 0
