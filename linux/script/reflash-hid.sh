#!/bin/bash
SCRIPT=$(basename "$0")
CURPATH=$(dirname "$0")
BINPATH=$CURPATH/../bin
SCRIPTPATH=$CURPATH/../script
EXEC=$BINPATH/hid_bootloader_cli
[ -z "$TARGET" ] && TARGET=atmega32u4

function usage {
    echo "Usage: $SCRIPT [eep_file|hex_file]"
    echo "Only atmegaXXuY and at90usbXXXY devices supported for hid."
    exit 1
}

[ -z "$1" ] && usage
[ ! -f "$1" ] && usage
ARG1=$1
NAME=$(basename "$ARG1")
EXT=${NAME##*.}
[ $EXT == "eep" ] || [ $EXT == "hex" ] || usage

TARGET_REG="(^atmega[0-9]{2}u[0-9]$)|(^at90usb[0-9]{4}$)"
[[ $TARGET =~ $TARGET_REG ]] || usage

echo "Reflashing $EXT file..."
"$EXEC" -w -v -mmcu=$TARGET "$ARG1"
$EXITCODE=$?
if [ $EXITCODE -eq 0 ]
then
    echo "Success!"
else
    echo "Flashing failed!"
fi
exit $EXITCODE
