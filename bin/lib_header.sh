#!/bin/bash

# sound output - the video file shall be stored in this folder!!
S_OUTPUT=jack

# video source
V_DNAME=/home/pi/video/$S_OUTPUT
# video files per client
V_FNAME_1=test.mp4
V_FNAME_2=dip_white_02m.mov
V_FNAME_3=dip_white_02m.mov
V_FNAME_4=dip_white_02m.mov
V_FNAME_5=dip_white_02m.mov
V_FNAME_6=dip_white_02m.mov
V_FNAME_7=dip_white_02m.mov
V_FNAME_8=dip_white_02m.mov
V_FNAME_9=dip_white_02m.mov

# projectors connected to the clients
P_CLI_1=test_1
P_CLI_2=optoma
P_CLI_3=optoma
P_CLI_4=sharp_4
P_CLI_5=optoma
P_CLI_6=benq_611c
P_CLI_7=benq_611c
P_CLI_8=benq_611c
P_CLI_9=panasonic

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

