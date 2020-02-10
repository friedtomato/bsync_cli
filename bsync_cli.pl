#!/usr/bin/perl -w

#use strict;
use warnings;

#use IO::Socket::INET;
use Sys::Hostname;
#use IO::Socket::UNIX;
#use IO::Select;

use Flog;
use Fsocket;
use Fav;
use Fpin;
use Fpar;
use Fserial;
use Fmpv;
use Header;

my $SRV_IP = '192.168.0.1';
my $SRV_PORT = '7777';
my $BPORT = 9999;

# ----- MPV socket -----------
my $MPV_SOCKET_DIR = "/tmp/mpvsocket";
my $JSON_PAUSE = "{ \"command\": [\"keypress\",\"SPACE\"] }\n";
my $JSON_DURATION = "{\"command\": [\"get_property\", \"duration\"] }\n"; 
my $JSON_POSITION = "{\"command\": [\"get_property\", \"time-pos\"] }\n"; 
my $JSON_RESET = "{\"command\": [\"seek\", \"0\", \"absolute\"] }\n"; 
# ----------------------------

# ----- Volume control -------
my $AMIXER_COMMAND = "amixer -q -M sset PCM";
# ----------------------------


# ---- hostname identification
my $host = hostname();
my ($name,$number) = split '-',$host;
my $CLI_NAME = "client-".$number;
my $HOST = $host;

# ----- LOGGING --------------
#open LOG,">log" or die "Cannot open file log: $!\n";
#my $FL_DNAME="/home/pi/dev/bsync";
my $FL_DNAME=$Header::FL_DNAME;
print $FL_DNAME."\n";
my $FL_FNAME="flog";
# log over the network
# flag to indicate log over network
my $NETLOG_FLAG=1;
my $NETLOG_PORT=8888;
Flog::open_flog("$FL_DNAME/$FL_FNAME",$HOST,$CLI_NAME,$NETLOG_FLAG,$SRV_IP,$NETLOG_PORT);
#LOG->autoflush(1);
# ----------------------------

# ----------------------------
my $END_OF_THE_SESSION = 0;
my $END_OF_THE_LINE = 0;
# how many times to try to listen to bcast before getting back to the loop
my $BCAST_LISTEN_CYCLES = 10;
# timeout for select
my $BCAST_SELECT_TIMEOUT = 0.5;


# arguments - projector type - it is used to decide the power on msg via serial & need for switch off of the heat sensors
my $PR_NAME="undef";
# video name
my $FI_NAME="undef";
if (defined($ARGV[0])){
  $PR_NAME = $ARGV[0];
}
if (defined($ARGV[1])){
  $FI_NAME = $ARGV[1];
}
#print $PR_NAME;

# ---- video load
#my @args = ("/home/pi/bin/mpv_start_paused.sh");
#exec(@args) == 0 or die "system @args failed: $?\n"; 
#sleep 2;
# ---------------


my $identified = 0;

 # auto-flush on socket
 $| = 1;
 
  # create broadcast listen socket
  my $b_socket = Fsocket::bcast_socket("noip",$BPORT,"cli");
  # create a write socket
  my $not_connected = 1;
#  my $w_socket;
#  while($not_iconnected){
#    print "connecting to server\n";
#    $w_socket = Fsocket::write_socket($SRV_IP,$SRV_PORT);
#    if($w_socket){
#      $not_connected = 0;
#    }
#  }
  # indicator of the projection
  my $projection_on = 0;
  my $line_loop_count = 0;
  my $line_pos_report = 5;
  my $session_pos_report = 2;
  my $last_command = "empty";
  my $command = "empty";
  my $film_pos = "un";
  my $film_dur = "un";
  my $volume="un";
  my $vol_read = "un";
  my $pin_status = "un";
  my $prj_return = "un";
  my $prj_status = "off";
  my $session_loop_count;
 print "client start (projector=$PR_NAME)\n";
  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
  print "client start (MPVsocket done)\n";
  $mpv_socket->send($JSON_DURATION);
  my $json_str = "";
  $mpv_socket->recv($json_str,64);
  shutdown($mpv_socket,1);
  $mpv_socket->close();
  $film_dur = Fmpv::parse_duration($json_str);

  $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
  $mpv_socket->send($JSON_POSITION);
  $json_str = "";
  $mpv_socket->recv($json_str,64);
  shutdown($mpv_socket,1);
  $mpv_socket->close();
  $film_pos = Fmpv::parse_position($json_str);

  # counting the commands executions
  my $run_com_hist;
  $run_com_hist->{'checkin'} = 0;
  $run_com_hist->{'empty'} = 0;
  my $ncom;
  print "enterin loop\n";
  while(!$END_OF_THE_LINE){
	  $line_loop_count++;
          my $w_socket;
          $w_socket = Fsocket::write_socket($SRV_IP,$SRV_PORT);
	  print "got w socket\n";
	  $ncom = $run_com_hist->{"$command"};
	  Flog::item_flog("L=$line_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:loop start, connected");
	  
	  #$mpv_socket->send($JSON_DURATION);
	  #my $resp = "";
	  #$mpv_socket->recv($resp,1024);
	  #Flog::item_flog("[L=$line_loop_count] local MPV socket: received $resp");
	  #Flog::item_flog("[L=$line_loop_count] trying identification (checkin)");

	  # send client identification, get confirmation 
	  my $size = $w_socket->send($CLI_NAME);
	  my $response = "";
	  print "L";
	  $w_socket->recv($response,32);
	  print "L";
	  $command = "checkin";
	  $run_com_hist->{'checkin'}++;
	  $ncom = $run_com_hist->{'checkin'};  
	  Flog::item_flog("L=$line_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:client identification ($CLI_NAME) $response");
  	  $last_command = $command;
	  $command = "empty";
	  $run_com_hist->{'empty'}++;
	
	  if ($response ne "ok"){
		  $END_OF_THE_SESSION = 1;
	  	  Flog::item_flog("L=$line_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:finishin the loo, invalid response ($response)");
	  }

    #wait for the go 
  	  my $not_go = 1;
	  my $bcast;
	  my $go_string;
	  my $log_print_loop = 3;
	  $session_loop_count = 0;
	  $ncom = $run_com_hist->{"$command"};
	  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:session start");
	  
  	  while(!$END_OF_THE_SESSION){
		  $ncom = $run_com_hist->{"$command"};
		  if ($session_loop_count % $log_print_loop == 0){
			  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:listening for bcast");
		  }
			print "e";
		  $bcast = Fsocket::get_comm($b_socket,$BCAST_LISTEN_CYCLES,$BCAST_SELECT_TIMEOUT);
			print "e";
	  	  if (defined($bcast)){
			  $ncom = $run_com_hist->{"$command"};
			  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:received $bcast");
			  ($go_string,$vol_read,$command) = split ':',$bcast;
			  print "$command\n";
			  my $run_here = Fpar::parse_par_hostname($go_string,$CLI_NAME);
			  if($run_here > 0){
				$volume = $vol_read;
			  	Fav::set_volume($AMIXER_COMMAND,$volume);
				#Flog::item_flog("S=$session_loop_count|LC=$last_command|C=$command|V=$volume|FI=$FI_NAME|PR=$PR_NAME:volume set $volume");
				if(!defined($run_com_hist->{"$command"})){
					$run_com_hist->{"$command"} = 1;
				}
				else{
					$run_com_hist->{"$command"}++;
				}
			  }
			  else{
				$command = "empty";
			  }
			  # run MPV socket and quit the session and line cycles
			  $ncom = $run_com_hist->{"$command"};
			  if (($command eq "runmpv!") and ($run_here)){
  				  # connect to MPV
				  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - sent $JSON_PAUSE");
				  $mpv_socket->send($JSON_PAUSE);
				  my $resp = "";
				  $mpv_socket->recv($resp,64);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - received $resp");
				  $END_OF_THE_SESSION = 1;
				  $END_OF_THE_LINE = 1;
				  shutdown($mpv_socket,1);
				  $mpv_socket->close();
				  $last_command = $command;
			  }
			  # run MPV socket and stay in the inner session loop
			  elsif (($command eq "runmpv") and ($run_here)){
  				  # connect to MPV
				  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - sent $JSON_PAUSE");
				  my $ret = $mpv_socket->send($JSON_PAUSE);
				  my $resp = "";
				  $mpv_socket->recv($resp,64);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - received $resp");
				  shutdown($mpv_socket,1);
				  $mpv_socket->close();
				  $projection_on = 1;
				  $last_command = $command;
			  }
			  # pause the video and stay in the inner session loop
			  elsif (($command eq "pausempv") and ($run_here)){
  				  # connect to MPV
				  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - sent $JSON_PAUSE");
				  $mpv_socket->send($JSON_PAUSE);
				  my $resp = "";
				  $mpv_socket->recv($resp,64);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - received $resp");
				  shutdown($mpv_socket,1);
				  $mpv_socket->close();
				  $last_command = $command;
			  }
			  # reset mpv - move to the begginning of the film
			  elsif (($command eq "resetmpv") and ($run_here)){
  				  # connect to MPV
				  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - sent $JSON_RESET");
				  $mpv_socket->send($JSON_RESET);
				  my $resp = "";
				  $mpv_socket->recv($resp,64);
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:local MPV socket - received $resp");
				  shutdown($mpv_socket,1);
				  $mpv_socket->close();
				  $last_command = $command;
			  }
			  elsif ((($command eq "incvol") or ($command eq "decvol")) and ($run_here)){
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:incvol / decvol received (V=$volume)");
				  $last_command = $command;
			  }
			  # turn prj on
			  elsif (($command eq "prjon") and ($run_here)){
				  if($PR_NAME ne "empty"){
					  my $ret = Fserial::set_prj_on($PR_NAME,5000);
					  $prj_status = "on";
					  $prj_return = $ret;
				  }
				  else{
					  $prj_status = "v.on";
					  $prj_return = "v.ret";
				  } 
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$command($prj_return)");
				  $last_command = $command;
		  	  }
			  # turn prj off
			  elsif (($command eq "prjoff") and ($run_here)){
				  if($PR_NAME ne "empty"){
				 	  my $ret = Fserial::set_prj_off($PR_NAME,5000);
					  $prj_status = "off";
				  	  $prj_return = $ret;
			  	  }	
				  else{
					  $prj_status = "v.off";
					  $prj_return = "v.ret";
				  }
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$command($prj_return)");
				  $last_command = $command;
			  }
			  elsif (($command eq "prjstatus") and ($run_here)){
				  if($PR_NAME ne "empty"){
					  my ($ret) = Fserial::get_prj_status($PR_NAME,5000);
					  $prj_return = $ret;
				  }
				  else{
					  $prj_return = "v.ret";
				  }

				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$command($prj_return)");
				  $last_command = $command;
			  }
			  # pin up (heat sensor)
			  elsif (($command eq "pinuphs") and ($run_here)){
				  Fpin::init_hs_pin(0);
				  my $ret = Fpin::up_hs_pin();
				  $pin_status = $ret;
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$command($ret)");
				  Fpin::del_hs_pin();
				  $last_command = $command;
			  }
			  # pin down (heat sensor)
			  elsif (($command eq "pindownhs") and ($run_here)){
				  Fpin::init_hs_pin(0);
				  my $ret = Fpin::down_hs_pin();
				  $pin_status = $ret;
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$command($ret)");
				  Fpin::del_hs_pin();
				  $last_command = $command;
			  }
			  # quit the session cycle
			  elsif (($command eq "quitsession") and ($run_here)){
				  $END_OF_THE_SESSION = 1;
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:quit session (inner cycle)");
				  $last_command = $command;
				  sleep 1;

		  	  }
		  	  # quit the sesssion and line cycle
			  elsif (($command eq "quitssln") and ($run_here)){
				  $END_OF_THE_SESSION = 1;
				  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:quit client");
				  $END_OF_THE_LINE = 1;
				  $last_command = $command;
			  } 
		  	  else{

		  	  }	
			  $command = "empty";


	 	  }	
	  	  else{
			  #print "nothing \n";
  
	  	  }
		  $session_loop_count++;

		  if($session_loop_count % $session_pos_report == 0){
		  	  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
		  	  $mpv_socket->send($JSON_POSITION);
		          my $json_str = "";
		  	  $mpv_socket->recv($json_str,64);
		  	  print $json_str;
		  	  shutdown($mpv_socket,1);
		  	  $mpv_socket->close();
		  	  $film_pos = Fmpv::parse_position($json_str);
		  	  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$film_pos");
			
		  }
   	  }
	  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|CHI=$ncom|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:session end");
	  $END_OF_THE_SESSION = 0;
          shutdown($w_socket, 1);
          $w_socket->close();
	  #if($line_loop_count % $line_pos_report == 0){
	  #	  my $mpv_socket = Fsocket::mpv_socket($MPV_SOCKET_DIR);
	  # 	  $mpv_socket->send($JSON_POSITION);
	  #       my $json_str = "";
	  #	  $mpv_socket->recv($json_str,64);
	  #	  print $json_str;
	  #	  shutdown($mpv_socket,1);
	  #	  $mpv_socket->close();
	  #	  $film_pos = Fmpv::parse_position($json_str);
	  #	  #Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=$command|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:$position");
	  #}
  }

  # if($command eq "quit"){
  #  shutdown($w_socket, 1);
  #  $w_socket->close();
  #  Flog::close_flog;
  #  exit;
  #}


  
  # set the volume
  #Flog::item_flog("setting volume $volume");
  #my @args = ("$AMIXER_COMMAND $volume");
  #exec(@args) == 0 or die "system @args failed: $?\n"; 
  Flog::item_flog("S=$session_loop_count|LCO=$last_command|COM=exit|CHI=1|VOL=$volume|FLM=$FI_NAME|FPO=$film_pos/$film_dur|PIN=$pin_status|PST=$prj_status|PRE=$prj_return|PNA=$PR_NAME:exiting");
#  shutdown($w_socket, 1);
#  $w_socket->close();
  Flog::close_flog;
  print "client end\n";
