#!/bin/bash

# sound output - the video file shall be stored in this folder!!
S_OUTPUT=jack

# video source
V_DNAME=/home/pi/video/$S_OUTPUT
# video files per client
V_FNAME_1=test.mp4
V_FNAME_2=videoplayback.mp4
V_FNAME_3=videoplayback.mp4
V_FNAME_4=videoplayback.mp4
V_FNAME_5=videoplayback.mp4
V_FNAME_6=videoplayback.mp4
V_FNAME_7=videoplayback.mp4

# projectors connected to the clients
P_CLI_1=test_1
P_CLI_2=benq_741
P_CLI_3=empty
P_CLI_4=optoma
P_CLI_5=empty
P_CLI_6=empty
P_CLI_7=sharp_4

# script source
SCR_DNAME=$BSYNC_SCR_PATH
SCR_FNAME=bsync_cli.pl
LOG_FNAME=output.log
STA_FNAME=status_aut.sh
SCR_FULL=$SCR_DNAME/$SCR_FNAME
LOG_FULL=$SCR_DNAME/$LOG_FNAME
STA_FULL=$SCR_DNAME/$STA_FNAME
# mpv socket
MPV_SOCKET=/tmp/mpvsocket

echo $STA_FULL

