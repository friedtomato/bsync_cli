package Header;

#use Cwd;

#$CU_DNAME = cwd();
$CU_DNAME = $ENV{BSYNC_SCR_PATH};
$FL_DNAME = "$CU_DNAME/log";

1;
