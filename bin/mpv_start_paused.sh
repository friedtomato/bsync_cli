#!/bin/bash

source $BSYNC_BIN_PATH/lib_header.sh

# select the right video folder name


# select the right video file and projector name
IFS='-'
read -ra ITEMS <<< "$HOSTNAME"
name=${ITEMS[1]}
#echo $name
eval V_FNAME=( \${V_FNAME_$name} );
eval P_NAME=( \${P_CLI_$name} );
# echo $V_FNAME
V_FULL=$V_DNAME/$V_FNAME

#echo $P_NAME
#$SCR_FULL $P_NAME &

# display and perl modules dir
export DISPLAY=:0
export PERL5LIB=$BSYNC_SCR_PATH

# set the sound output
if [ "$S_OUTPUT" == "jack" ]; then
  #echo "jack it is"	
  amixer cset numid=3 1
else
  if [ "$S_OUTPUT" == "hdmi" ]; then
   # echo "hdmi it is"	  
    amixer cset numid=3 2
  fi
fi



if [ "$BSYNC_RUN" == "r" ]; then
  # start status measuring
  echo "running status check: "$STA_FULL
  $STA_FULL &
fi

echo "mod:"$BSYNC_MOD" run:"$BSYNC_RUN
echo "SCR:"$SCR_FULL


# start looop
while true; do
	if [ "$(pidof mpv)" ]; then
    		#echo "MPV is running"
		sleep 0.1
	else
    		#echo "running MPV now"
    		mpv --pause $V_FULL --really-quiet --input-ipc-server=$MPV_SOCKET &
    		sleep 2
   
    		if [ "$BSYNC_MOD" == "a" ] && [ "$BSYNC_RUN" == "r" ]; then
      			bsync_pi=`ps -ef | grep -v grep | grep -v vim | grep $SCR_FNAME | awk '{print $2}'`
      			if [ "$bsync_pi" ]; then
        			#    #echo "client running"
        			sleep 0.1;
      			else
       				if [ "$BSYNC_LOG" == "r" ]; then
         				$SCR_FULL $P_NAME $V_FNAME 2>&1 | tee $LOG_FULL &
       				fi
       				if [ "$BSYNC_LOG" == "n" ]; then
	 				$SCR_FULL $P_NAME $V_NAME &
      				fi
    			fi
  
  		fi
  	fi

  	# if run set to run
  	if [ "$BSYNC_MOD" == "m" ] && [ "$BSYNC_RUN" == "r" ]; then
    		bsync_pi=`ps -ef | grep -v grep | grep -v vim | grep $SCR_FNAME | awk '{print $2}'`
    		if [ "$bsync_pi" ]; then
      			#    #echo "client running"
      			sleep 0.1;
    		else
     			if [ "$BSYNC_LOG" == "r" ]; then
       				$SCR_FULL $P_NAME $V_FNAME 2>&1 | tee $LOG_FULL &
     			fi
     			if [ "$BSYNC_LOG" == "n" ]; then
       				$SCR_FULL $P_NAME $V_NAME &
     			fi
    		fi
  	fi

done  


