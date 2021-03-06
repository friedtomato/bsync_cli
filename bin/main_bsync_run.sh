#!/bin/bash


if [ "$BSYNC_PREFIX" == "usb" ]; then
    export BSYNC_RUN_PATH=$BSYNC_USB_PATH
fi
if [ "$BSYNC_PREFIX" == "mmc" ]; then
    export BSYNC_RUN_PATH=$BSYNC_MMC_PATH
fi


# client configuration
export BSYNC_SCR_PATH=$BSYNC_RUN_PATH"/dev/bsync_cli"
export BSYNC_BIN_PATH=$BSYNC_RUN_PATH"/dev/bsync_cli/bin"
export BSYNC_BIN_RUN="mpv_start_paused.sh"
logger -i -t BSYNC "PREFIX: "$BSYNC_PREFIX" MOD:"$BSYNC_RUN$BSYNC_MOD$BSYNC_LOG

if [ "$BSYNC_LOG" == "r" ]; then
    $BSYNC_BIN_PATH/$BSYNC_BIN_RUN 2>&1 | tee $BSYNC_BIN_PATH/output_main.log
fi
if [ "$BSYNC_LOG" == "n" ]; then
    $BSYNC_BIN_PATH/$BSYNC_BIN_RUN
fi
