# .bash_aliases - sourced by ~/.bashrc
# 

echo "sourcing '.bash_aliases'"

# some ansi colorizatioin escape sequences
D2E="\e[K"              # to delete the rest of the chars on a line
BLD="\e[1m"             # bold
RED="\e[31m"            # red color
GRN="\e[32m"            # green color
YLW="\e[33m"            # yellow color
BLU="\e[34m"            # blue color
CYN="\e[36m"            # cyan color
NRM="\e[m"              # to make text normal

# turn on `vi` command line editing - oh yeah!
set -o vi

# set xterm defaults
XTERM='xterm -fg white -bg black -fs 10 -cn -rw -sb -si -sk -sl 5000'

# some bind settings
bind Space:magic-space

# update change the title bar of the terminal
echo -ne "\033]0;`whoami`@`hostname`\007"

#CHEF_REPO=/opt/repo
CHEF_REPO=$HOME/repos
REPO_DIR=$HOME/repos

# set value of OTHERVM for .bash_aliases syncing
[ `hostname` == "racos" ] && export OTHERVM=racovm || export OTHERVM=racos

# User specific aliases and functions

function atf () {	# TOOL # DEPRECATED with `hg` or `git`
# Archive This File
   if [ $# -eq 1 ]; then
      file=$1
      moddate=`stat -c %y $file | awk '{print $1}'`
      ext=`date --date "$moddate" +'%m%d%y'`
      ls $file.* > /dev/null 2>&1
      if [ $? -eq 0 ]; then
         [ -d archive ] || mkdir archive
         mv -i $file.* archive
      fi
      [ -s $file ] && cp -ip $file $file.$ext
   else
      echo "you didn't specify a file to archive"
   fi
}

function bon () {	# TOOL
# Bootstrap OpenStack Node
   if knife_env_set; then
      update_spiceweasel_repo
      sgp=$1
      nip=$2
      nn=$3
      if [ -n "$sgp" -a -n "$nip" ]; then
         orig_cmd=`spiceweasel $SW_YAML_FILE | \grep -w $sgp | sort -u`
         case $KNIFTLA in
            dtu|pew|pms|pue|puw|pte|ptu|rou)
               #kbc=`echo "$orig_cmd" | awk '{for (i=1;i<=NF;i++) {if ($i =="-r") {role=$(i+1)}; if ($i =="-N") {iname=$(i+1)}}; {print "knife bootstrap '"$nip"' -r "role" -c $KNIFERB -i ~/.ssh/Red5China.pem -x ubuntu -N "iname"'"$nn"' --sudo"}}'`
               kbc=`echo "$orig_cmd" | awk '{for (i=1;i<=NF;i++) {if ($i =="-r") {role=$(i+1)}; if ($i =="-N") {iname=$(i+1)}}; {print "knife bootstrap '"$nip"' -r "role" -c $KNIFERB -x praco -N "iname"'"$nn"' --sudo"}}'`
               ##kbc="${kbc} --bootstrap-url http://115.182.10.10:8080/chef/install.sh"
               ;;
            ccd|dts|pek|w11|w12|w13)
               if [ -n "$nn" ]; then
                  kbc=`echo "$orig_cmd" | awk '{for (i=1;i<=NF;i++) {if ($i =="-r") {role=$(i+1)}; if ($i =="-N") {iname=$(i+1)}}; {print "knife bootstrap '"$nip"' -r "role" -c $KNIFERB -i ~/.ssh/Red5China.pem -x ubuntu -N "iname"'"$nn"' --sudo"}}'`
                  kbc="${kbc} --bootstrap-url http://221.228.92.21:8080/chef/install.sh"
               else
                  echo -e "\t-----------------------------------------------------------------------"
                  echo "need to specify a <spiceweasel grep pattern>, <IP> and <node number>"
                  return 2
               fi
               ;;
            dts|sna)
               kbc=`echo "$orig_cmd" | awk '{for (i=1;i<=NF;i++) {if ($i =="-r") {role=$(i+1)}; if ($i =="-N") {iname=$(i+1)}}; {print "knife bootstrap '"$nip"' -r "role" -c $KNIFERB -i ~/.ssh/Red5China.pem -x ubuntu -N "iname"'"$nn"' --sudo"}}'`
               kbc="${kbc} --bootstrap-url http://115.182.10.10:8080/chef/install.sh"
               ;;
            *)
               echo "error: not sure how I got here"; return 2;;
         esac
         compare_lines "$orig_cmd" "$kbc"
         echo -e "\t-----------------------------------------------------------------------"
         read -p "is this correct - do you want to run it (y/n)? " ans
         if [ "$ans" = "y" ]; then
            echo "ok, running the command"
            eval "$kbc"
         else
            echo "ok, NOT running the command"
         fi
      else
         echo "need to specify a <spiceweasel grep pattern> and <IP>"
      fi
   fi
}

function ccc () {
# Synchronize tmux windows
   for I in $@; do
      tmux splitw "ssh $I"
      tmux select-layout tiled
   done
   tmux set-window-option synchronize-panes on
   exit
}

function chksums () {	# TOOL
# Generate 4 kinds of different checksums for a file
   if [ $# -eq 1 ]; then
      file=$1
      echo "File: $file"
      echo "-------------"
      echo -n "cksum : "
      cksum $file | awk '{print $1}'
      echo -n "md5sum: "
      md5sum $file | awk '{print $1}'
      echo -n "shasum: "
      shasum $file | awk '{print $1}'
      echo -n "sum   : "
      sum $file
   else
      echo "you didn't specify a file to calculate the checksums for"
   fi
}

function cktj () {	# TOOL
# convert a key file so that it can be used in a json entry (i.e. change \n -> "\n")
   if [ -n "$1" ]; then
      cat $1 | tr '\n' '_' | sed 's/_/\\n/g'
      echo
   else
      echo "error: you did not specify a key file to convert"
   fi
}

function compare_lines () {
# compare two lines and colorize the diffs
   local line1="$1 "
   local line2="$2 "
   local line1diffs
   local line2diffs
   local newword
   local word
   for word in $line1; do
      echo "$line2" | \fgrep -q -- "$word "
      if [ $? -eq 1 ]; then
         newword="${RED}$word${NRM}"
      else
         newword=$word
      fi
      line1diffs="$line1diffs $newword"
   done
   line1diffs=`echo "$line1diffs" | sed 's/^ //'`
   for word in $line2; do
      echo "$line1" | \fgrep -q -- "$word "
      if [ $? -eq 1 ]; then
         newword="${GRN}$word${NRM}"
      else
         newword=$word
      fi
      line2diffs="$line2diffs $newword"
   done
   line2diffs=`echo "$line2diffs" | sed 's/^ //'`
   #echo -e "\t--------------------- here's the original command ---------------------"
   echo -e "\t--------------------- missing in red ---------------------"
   echo -e "$line1diffs"
   #echo -e "\t--------------------- here's the modified command ---------------------"
   echo -e "\t--------------------- added in green ---------------------"
   echo -e "$line2diffs"
}

function kcn () {
# knife Create Node - using spiceweasel
   sgp=$1
   shift
   arg=$1
   while [ -n "$arg" ]; do
      shift
      case $arg in
         '-b') build=$1 ;;
         '-n') nn=$1 ;;
         '-z') zone=$1 ;;
      esac
      shift
      arg=$1
   done
   if knife_env_set; then
      update_spiceweasel_repo
      if [ -n "$sgp" ]; then
         orig_cmd=`spiceweasel $SW_YAML_FILE | \grep -w $sgp | sort -u`
         case $KNIFTLA in
            dtu|pte|ptu|rou)
               kscc=`echo "$orig_cmd" | sed "s:-c .chef/knife.rb:-c "'$KNIFERB'":"`
               #kscc="${kscc} --bootstrap-url http://115.182.10.10:8080/chef/install.sh"
               echo $sgp | grep -q "game"
               if [ $? -eq 0 ]; then
                  if [ -n "$build" ]; then
                     kscc=`echo "$kscc" | sed "s:XXXX:$build:g;s:$sgp-$nn$build-:$sgp-$build-$nn:"`
                  else
                     echo -e "\t-----------------------------------------------------------------------"
                     echo "need to specify a <spiceweasel grep pattern> and <build number>"
                     return 2
                  fi
               fi
               ;;
            pew|pms|pue|puw)
               kscc=`echo "$orig_cmd" | sed "s:-c .chef/knife.rb:-c "'$KNIFERB'":"`
               #kscc="${kscc} --bootstrap-version 10.34.6"
               echo $sgp | grep -q "game"
               if [ $? -eq 0 ]; then
                  if [ -n "$build" ]; then
                     kscc=`echo "$kscc" | sed "s:XXXX:$build:g;s:$sgp-$nn$build-:$sgp-$build-$nn:"`
                  else
                     echo -e "\t-----------------------------------------------------------------------"
                     echo "need to specify a <spiceweasel grep pattern> and <build number>"
                     return 2
                  fi
               fi
               ;;
            ccd|dts|pek|sna|w11|w12|w13)
               if [ -n "$nn" -a -n "$zone" ]; then
                  kscc=`echo "$orig_cmd" | sed "s:-c .chef/knife.rb:-c "'$KNIFERB'":;s:$sgp-:$sgp-$nn:;s: -T Group=Internal::;s: -g: -G:;s:vNN-ZONE-X:$zone:"`
                  #kscc="${kscc} --bootstrap-url http://115.182.10.10:8080/chef/install.sh"
               else
                  echo $sgp | grep -q "matchdirector"
                  if [ $? -eq 0 -a -n "$zone" ]; then
                     kscc=`echo "$orig_cmd" | sed "s:-c .chef/knife.rb:-c "'$KNIFERB'":;s: -T Group=Internal::;s: -g: -G:;s:vNN-ZONE-X:$zone:"`
                  else
                     echo -e "\t-----------------------------------------------------------------------"
                     echo "need to specify a <spiceweasel grep pattern>, <node number> and <zone-id>"
                     return 2
                  fi
               fi
               echo $sgp | grep -q "game"
               if [ $? -eq 0 ]; then
                  if [ -n "$build" ]; then
                     kscc=`echo "$kscc" | sed "s:XXXX:$build:g;s:$sgp-$nn$build-:$sgp-$build-$nn:"`
                  else
                     echo -e "\t-----------------------------------------------------------------------"
                     echo "need to specify a <spiceweasel grep pattern>, <node number>, <zone-id> and <build number>"
                     return 2
                  fi
               fi
               ;;
            *)
               echo "error: not sure how I got here"; return 2;;
         esac
         compare_lines "$orig_cmd" "$kscc"
         echo -e "\t-----------------------------------------------------------------------"
         read -p "is this correct - do you want to run it (y/n/x)? " ans
         if [ "$ans" = "y" ]; then
            echo "ok, running the command"
            eval "$kscc"
         elif [ "$ans" = "x" ]; then
            echo "ok, running the command in a xterm window"
            #xterm -e "echo $kscc;eval $kscc;echo $kscc;bash" &
            $XTERM -e 'echo '"$kscc"';eval '"$kscc"';echo '"$kscc"';bash' &
         else
            echo "ok, NOT running the command"
         fi
      else
         echo "need to specify a <spiceweasel grep pattern>"
      fi
   fi
}

##function dbgrep () {	# TOOL
### search/grep informix DB for patterns in tables/column names
### OPTIONS
### -w search for whole words only
### -t search table  names for a pattern:
###     display "matching table names"
### -c search column names for a pattern:
###     display "matching column names"
### -i search table  names for a pattern and get info:
###     display "table name: column1, column2, etc."
### -a search for tables containing patterns in column name:
###     display "table name1, table name2, etc."
## NOT_VALID_HOSTS="jump1 jump2 stcgxyjmp01"
## USAGE="dbgrep [-w] -t|c|i|a PATTERN"
##
##   echo "$NOT_VALID_HOSTS" | grep -w $HOSTNAME >/dev/null 2>&1
##   if [ $? -eq 0 ]; then
##      echo "can't run this on any of these hosts: '$NOT_VALID_HOSTS'"
##      return
##   fi
##   grepopt="-i"
##   searchtype="containing"
##   if [ $# -eq 3 ]; then
##      if [ $1 = "-w" ]; then
##         grepopt="-iw"
##         searchtype="matching"
##         shift
##      else
##         echo "usage: $USAGE"
##         return
##      fi
##   fi
##   if [ $# -eq 2 ]; then
##      option=$1
##      pattern=$2
##      case $option in
##         -t)
##            echo "table name(s) $searchtype '$pattern':"
##            for table in `echo "info tables"|dbaccess dev 2>/dev/null|grep $grepopt "$pattern"`; do
##               echo $table | grep $grepopt "$pattern"
##            done
##            echo "======"
##            if [ "$searchtype" = "matching" ]; then
##               echo "select tabname from systables where tabname='$pattern'"|dbaccess dev
##            else
##               echo "select tabname from systables where tabname like '%$pattern%'"|dbaccess dev
##            fi
##            ;;
##         -c)
##            echo "column name(s) $searchtype '$pattern' (be patient):"
##            for table in `echo "info tables"|dbaccess dev 2>/dev/null`; do
##               echo "info columns for $table"|dbaccess dev 2>/dev/null|awk '{print $1}'|grep $grepopt "$pattern"
##            done|sort -u
##            ;;
##         -i)
##            echo "info about table name(s) $searchtype '$pattern':"
##            for table in `echo "info tables"|dbaccess dev 2>/dev/null|grep $grepopt "$pattern"`; do
##               echo $table | grep $grepopt "$pattern" >/dev/null 2>&1
##               if [ $? -eq 0 ]; then
##                  echo "table: $table"
##                  echo "info columns for $table"|dbaccess dev 2>/dev/null
##                  echo "	-------"
##               fi
##            done
##            ;;
##         -a)
##            echo "table name(s) with column(s) $searchtype '$pattern':"
##            for table in `echo "info tables"|dbaccess dev 2>/dev/null`; do
##               columns=`echo "info columns for $table"|dbaccess dev 2>/dev/null|awk '{print $1}'|grep $grepopt "$pattern"`
##               if [ $? = 0 ]; then
##                  for column in $columns; do
##                     printf "%-20s: %s\n" $table $column
##                  done
##               fi
##            done
##            ;;
##         * )
##            echo "usage: $USAGE"
##            ;;
##      esac
##   else
##      echo "usage: $USAGE"
##   fi
##}

function decimal_to_base32() {
# convert a decimal number to base 32
 BASE32=($(echo {0..9} {a..v}))
   arg1=$@
   for i in $(bc <<< "obase=32; $arg1"); do
      echo -n ${BASE32[$(( 10#$i ))]}
   done && echo
}

function decimal_to_base36() {
# convert a decimal number to base 36
 BASE36=($(echo {0..9} {a..z}))
   arg1=$@
   for i in $(bc <<< "obase=36; $arg1"); do
      echo -n ${BASE36[$(( 10#$i ))]}
   done && echo
}

function decimal_to_baseN() {
# convert a decimal number to any base
 DIGITS=($(echo {0..9} {a..z}))
   if [ $# -eq 2 ]; then
      base=$1
      if [ $base -lt 2 -o $base -gt 36 ]; then
         echo "base must be between 2 and 36"
         return 2
      fi
      shift
      decimal=$@
      if [ $base -le 16 ]; then
         echo "obase=$base; $decimal" | bc | tr '[:upper:]' '[:lower:]'
      else
         for i in $(bc <<< "obase=$base; $decimal"); do
            echo -n ${DIGITS[$(( 10#$i ))]}
         done && echo
      fi
      else
      echo "usage: decimal_to_base BASE_DESIRED DECIAML_NUMBER"
   fi
   return 0
}

function frlic () {
# find roles that I've changed
   cd $CHEF_REPO/cookbooks
   for cookbook_dir in `/bin/ls`; do
      echo " ------- $cookbook_dir	-------"
      (cd $cookbook_dir; hg stat; hg shelve -l)
   done
   cd -
}

function fsic () {
# find stuff that I've changed in the sub dirs of the cwd
   for sub_dir in `/bin/ls`; do
      if [ -d $sub_dir ]; then
         echo " ------- $sub_dir	-------"
         (cd $sub_dir; hg stat; hg shelve -l)
      fi
   done
}

function fsip () {
# find stuff that I've pushed in the sub dirs of the cwd
   for sub_dir in `/bin/ls`; do
      if [ -d $sub_dir ]; then
         echo " ------- $sub_dir	-------"
         (cd $sub_dir; hg slog | grep Raco)
      fi
   done
}

##function getramsz () {	# TOOL
### get the amount of RAM on a server
## JUMP_SERVERS="jump1 jump2 stcgxyjmp01"
## USAGE="usage: getramsz [server] [server2] [server3]..."
##   echo "$JUMP_SERVERS" | grep -w $HOSTNAME >/dev/null 2>&1
##   if [ $? -eq 0 -a $# -gt 0 ]; then
##      servers="$*"
##      remote=true
##   elif [ $# -eq 0 ]; then
##      servers=$HOSTNAME
##      remote=false
##   else
##      echo "$USAGE"
##      return
##   fi
##   for server in $servers; do
##      host $server > /dev/null
##      if [ $? -eq 0 ]; then
##         total_mem=0
##         echo -n "$server: RAM installed: 'hpasmcli' calculating... "
##         if [ "$remote" = "true" ]; then
##            #for dimm_size in `ssh ecisupp@$server 'hpasmcli -s "show dimm" | grep Size' 2>/dev/null | awk '{print $2}'`; do
##            for dimm_size in `ssh -q ecisupp@$server 'hpasmcli -s "show dimm" | grep Size' 2>/dev/null | awk '{print $2}'`; do
##               total_mem=`expr $total_mem + $dimm_size`
##            done
##         else
##            for dimm_size in `hpasmcli -s "show dimm" | grep Size 2>/dev/null | awk '{print $2}'`; do
##               total_mem=`expr $total_mem + $dimm_size`
##            done
##         fi
##         if [ $total_mem -eq 0 ]; then
##            hpasmcli_val="( ERROR )"
##         else
##            total_mem_gb=`expr $total_mem / 1024`
##            hpasmcli_val=`printf "[ %2d GB ]" $total_mem_gb`
##         fi
##         echo -ne "\r$server: RAM installed: 'hpasmcli' $hpasmcli_val... 'free' calculating... "
##         if [ "$remote" = "true" ]; then
##            #free_size=`ssh ecisupp@$server 'free | grep Mem' 2>/dev/null | awk '{print $2}'`
##            free_size=`ssh -q ecisupp@$server 'free | grep Mem' 2>/dev/null | awk '{print $2}'`
##         else
##            free_size=`free | grep Mem 2>/dev/null | awk '{print $2}'`
##         fi
##         [ -z "$free_size" ] && free_size=0
##         if [ $free_size -eq 0 ]; then
##            free_val="( ERROR )"
##         else
##            free_mem_gb=`expr $free_size / 1024 / 1024 + 1`
##            free_val=`printf "[ %2d GB ]" $free_mem_gb`
##         fi
##         echo -e "\r$server: RAM installed: 'hpasmcli' $hpasmcli_val... 'free' $free_val\e[K"
##      else
##         echo -n "$server: unknown host"
##      fi
##   done
##}

##function gftf () {	# TOOL # DEPRECATED with SCCS
### grandfather a file
##   [ -s $1.save ] && mv -i $1.save $1.bak
##   [ -s $1.old ] && mv -i $1.old $1.save
##   [ -s $1.orig ] && mv -i $1.orig $1.old
##   [ -s $1 ] && cp -ip $1 $1.orig
##}

function hgd () {
   local rev=$1
   echo "hg diff -r $((--rev)) -r $((++rev))"
   hg diff -r $((--rev)) -r $((++rev))
}

function kcl () {
# preform a knife node list (and optionally grep for a pattern)
   if knife_env_set; then
      if [ -n "$1" ]; then
         chef_clients=`/usr/bin/knife client list -c $KNIFERB | grep $*`
         if [ -n "$chef_clients" ]; then
            echo "$chef_clients"
         else
            echo "did not find any nodes matching '$1' in the client list"
         fi
      else
         chef_clients_nc=`/usr/bin/knife client list -c $KNIFERB`
         if [ -n "$chef_clients_nc" ]; then
            echo "$chef_clients_nc"
         else
            echo "could not find any clients to list"
         fi
      fi
   fi
}

function kcssh () {
# cssh to servers matching PATTERN provided by user via `knife ssh` and internal FQDN's
   if knife_env_set; then
      source_ssh_env 
      servers=$1
      #for server in `knife node list -c $KNIFERB | \grep $servers`; do
      #   svr_ifqdn=`knife node show $server -a internal_fqdn -c $KNIFERB`
      #   ssh-keygen -f "/home/praco/.ssh/known_hosts" -R $svr_ifqdn
      #done
      #eval knife ssh "name:*${servers}*" -a ipaddress cssh -c $KNIFERB
      eval knife ssh "name:*${servers}*" -a internal_fqdn cssh -c $KNIFERB
   fi
}

function kcssha () {
# cssh to servers matching multiple PATTERNs provided via `knife node list` and `cssh`
 local fqdn_srvr_list
   if knife_env_set; then
      knife_node_list=`mktemp /tmp/knl.XXXX`
      /usr/bin/knife node list -c $KNIFERB > $knife_node_list
      for server_pattern in $*; do
         #echo "server_pattern=$server_pattern"
         echo "looking for servers matching '$server_pattern'"
         #for actual_server in `/usr/bin/knife node list -c $KNIFERB | \grep $server_pattern`; do
         for actual_server in `\grep $server_pattern $knife_node_list`; do
            actual_server_ifqdn=`knife node show -a internal_fqdn -c $KNIFERB $actual_server | \grep fqdn | awk '{print $2}'`
            #echo "actual_server=$actual_server ($actual_server_ifqdn)"
            echo "found: $actual_server ($actual_server_ifqdn)"
            fqdn_srvr_list="$fqdn_srvr_list $actual_server_ifqdn"
         done
      done
      if [ -n "$fqdn_srvr_list" ]; then
         # get rid of dups
         fqdn_srvr_list=`for fqdns in $fqdn_srvr_list;do echo $fqdns;done|sort -u`
         cssh $fqdn_srvr_list &
      else
         echo "no servers found"
      fi
      rm -f $knife_node_list
   fi
}

function kcsshau () {
# cssh to servers matching multiple PATTERNs provided via `knife node list` and `cssh`
 local fqdn_srvr_list
   if knife_env_set; then
      knife_node_list=`mktemp /tmp/knl.XXXX`
      /usr/bin/knife node list -c $KNIFERB > $knife_node_list
      for server_pattern in $*; do
         echo "looking for servers matching '$server_pattern'"
         for actual_server in `\grep $server_pattern $knife_node_list`; do
            actual_server_ifqdn=`knife node show -a internal_fqdn -c $KNIFERB $actual_server | \grep fqdn | awk '{print $2}'`
            echo "found: $actual_server ($actual_server_ifqdn)"
            fqdn_srvr_list="$fqdn_srvr_list $actual_server_ifqdn"
         done
      done
      case $KNIFTLA in
         ccd|pek|w11|w12|w13) ssh_identy_file=~/.ssh/Red5China.pem     ;;
                           *) ssh_identy_file=~/.ssh/Red5Community.pem ;;
      esac
      if [ -n "$fqdn_srvr_list" ]; then
         fqdn_srvr_list=`for fqdns in $fqdn_srvr_list;do echo $fqdns;done|sort -u`
         #cssh $fqdn_srvr_list -l ubuntu -o "-i $ssh_identy_file" &
         cssh -l ubuntu -o "-i $ssh_identy_file" $fqdn_srvr_list &
      else
         echo "no servers found"
      fi
      rm -f $knife_node_list
   fi
}

function kcsshi () {
# cssh to servers matching PATTERN provided by user via `knife ssh` and IP addresses
   if knife_env_set; then
      source_ssh_env 
      servers=$1
      #for server in `knife node list -c $KNIFERB | \grep $servers`; do
      #   svr_ifqdn=`knife node show $server -a internal_fqdn -c $KNIFERB`
      #   ssh-keygen -f "/home/praco/.ssh/known_hosts" -R $svr_ifqdn
      #done
      eval knife ssh "name:*${servers}*" -a ipaddress cssh -c $KNIFERB
      #eval knife ssh "name:*${servers}*" -a internal_fqdn cssh -c $KNIFERB
   fi
}

function kcsshu () {
# cssh to servers matching PATTERN provided by user via `knife ssh` and as ubuntu
   if knife_env_set; then
      source_ssh_env 
      servers=$1
      #eval knife ssh "name:*${servers}*" -u ubuntu -i ~/.ssh/Red5Community.pem -a internal_fqdn cssh -c $KNIFERB &
      #eval knife ssh "name:*${servers}*" -u ubuntu -i ~/.ssh/Red5China.pem -a internal_fqdn cssh -c $KNIFERB
      case $KNIFTLA in
         ccd|pek|w11|w12|w13) ssh_identy_file=~/.ssh/Red5China.pem     ;;
                         sna) ssh_identy_file=~/.ssh/Red5Community.pem ;;
                         dts) ssh_identy_file=~/.ssh/Red5DevTest.pem   ;;
                           *) ssh_identy_file=~/.ssh/Red5Community.pem ;;
      esac
      #eval knife ssh "name:*${servers}*" -u ubuntu -i ~/.ssh/Red5China.pem -a ipaddress cssh -c $KNIFERB
      eval knife ssh "name:*${servers}*" -u ubuntu -i $ssh_identy_file -a ipaddress cssh -c $KNIFERB
   fi
}

function kcurla () {
# curl to servers matching multiple PATTERNs provided via `knife node list` to check their health/build status
# usage: kcurla PATTERN
 local fqdn_srvr_list
   if knife_env_set; then
      knife_node_list=`mktemp /tmp/knl.XXXX`
      /usr/bin/knife node list -c $KNIFERB > $knife_node_list
      for server_pattern in $*; do
         #echo "looking for servers matching '$server_pattern'"
         for actual_server in `\grep $server_pattern $knife_node_list`; do
            actual_server_ifqdn=`knife node show -a internal_fqdn -c $KNIFERB $actual_server | \grep fqdn | awk '{print $2}'`
            #echo "found: $actual_server ($actual_server_ifqdn)"
            fqdn_srvr_list="$fqdn_srvr_list $actual_server_ifqdn"
         done
      done
      if [ -n "$fqdn_srvr_list" ]; then
         fqdn_srvr_list=`for fqdns in $fqdn_srvr_list;do echo $fqdns;done|sort -u`
         for srvr in $fqdn_srvr_list; do
            echo -n "$srvr: "
            eval curl -qs $fqdn_srvr_list/health | sed 's/<.*>//'
            echo -n ": "
            eval curl -qs $fqdn_srvr_list/build_info | sed 's/<.*>//'; echo
         done
      else
         echo "no servers found"
      fi
      rm -f $knife_node_list
   fi
}

function kesd () {
# knife ec2 server delete
   if knife_env_set; then
      ans="n"
      if [ -n "$1" ]; then
         if [ "$1" == "-y" ]; then
            ans="y"
            shift
            if [ -n "$1" ]; then
               server=$1
            else
               echo "you need to specify a server to delete"
               return 1
            fi
         else
            server=$1
         fi
         inst_id=`knife node show $server -a ec2.instance_id -c $KNIFERB | \fgrep "instance_id:" | awk '{print $2}'`
         if [ -z "$inst_id" ]; then
            inst=`echo $server | cut -d- -f3`
            inst_id="i-$inst"
         fi
         echo "here's the command:"
         echo "	knife ec2 server delete -y -R --purge --node $server $inst_id -c \$KNIFERB"
         [ "$ans" == "n" ] && read -p "is this correct? " ans
         if [ "$ans" = "y" ]; then
            echo "ok, running the command"
            knife ec2 server delete -y -R --purge --node $server $inst_id -c $KNIFERB
         else
            echo "ok, NOT running the command"
         fi
      else
         echo "you need to specify a server to delete"
      fi
   fi
}

function kf () {
# `knife` command wrapper to use my dynamically set knife.rb file
   if [ -z "$KNIFERB" ]; then
      echo "chef/knife environment NOT set - use 'ske'"
   else
      eval knife '$*' -c $KNIFERB
   fi
}

function knife_env_set () {
# check if knife environment set (specifically the knife.rb file)
   if [ -z "$KNIFERB" ]; then
      echo "chef/knife environment NOT set - use 'ske'"
      return 1
   else
      #if [ "$QUIET" != "true" ]; then
      #   echo "$KNIFENV (KNIFERB='$KNIFERB')"
      #fi
      return 0
   fi
}

function knl () {
# preform a knife node list (and optionally grep for a pattern)
   if knife_env_set; then
      if [ -n "$1" ]; then
         chef_nodes=`/usr/bin/knife node list -c $KNIFERB | grep $*`
         if [ -n "$chef_nodes" ]; then
            echo "$chef_nodes"
         else
            echo "did not find any nodes matching '$1' in the node list"
         fi
      else
         chef_nodes_nc=`/usr/bin/knife node list -c $KNIFERB`
         if [ -n "$chef_nodes_nc" ]; then
            echo "$chef_nodes_nc"
         else
            echo "could not find any nodes to list"
         fi
      fi
   fi
}

function kns () {
# perform knife node show for one or more node and optional specify an attribute
# you can give -a option to show only one attribute
   if knife_env_set; then
      local _chef_node_nc
      local _chef_node
      local attrib
      local l_opt
      if [ "$1" = "-a" ]; then
         case $2 in
             az) attrib=firefall.availability_zone ;;
             bn) attrib=r5_build_number ;;
             fq) attrib=fqdn ;;
            ifq) attrib=internal_fqdn ;;
             ip) attrib=ipaddress ;;
              *) attrib=$2 ;;
         esac
         shift 2
      elif [ "$1" = "-l" ]; then
         l_opt="$1"
         shift
      fi
      if [ -n "$1" ]; then
         chef_nodes_nc=`/usr/bin/knife node list -c $KNIFERB | \grep $*`
      else
         chef_nodes_nc=`/usr/bin/knife node list -c $KNIFERB`
      fi
      if [ -n "$chef_nodes_nc" ]; then
         for _chef_node_nc in $chef_nodes_nc; do
            [ -n "$*" ] && _chef_node=`echo "$_chef_node_nc" | grep $*`
            echo -e "\t\t\t-----  $_chef_node  -----"
            #/usr/bin/knife node show -c $KNIFERB $_chef_node_nc | grep -v ^"Node Name"
            if [ -n "$attrib" ]; then
               /usr/bin/knife node show -c $KNIFERB $_chef_node_nc -a $attrib
            else
               /usr/bin/knife node show -c $KNIFERB $_chef_node_nc $l_opt
            fi
         done
      else
         if [ -n "$1" ]; then
            echo "did not find any nodes matching '$1' to show"
         else
            echo "could not find any nodes to show"
         fi
      fi
   fi
}

function knsc () {
# find the creator of one or more nodes
   if knife_env_set; then
      for srvr in `knife node list -c $KNIFERB | \grep $1`; do
         echo -n "$srvr:	"
         /usr/bin/knife node show $srvr -c $KNIFERB -a Creator
      done
   fi
}

function kosd () {
# knife openstack server delete
   if knife_env_set; then
      if [ -n "$1" ]; then
         server=$1
         #echo "here's the command:"
         echo -n "run this?: 'knife openstack server delete $server -y --purge -c \$KNIFERB' [y/n]: "
         #read -p "is this correct? " ans
         read ans
         if [ "$ans" = "y" ]; then
            echo "ok, running the command"
            knife openstack server delete $server -y --purge -c $KNIFERB
         else
            echo "ok, NOT running the command"
         fi
      else
         echo "you need to specify a server to delete"
      fi
   fi
}

function kscp () {
# perform `scp` using knife to get IP's of hosts given via a pattern
   declare -A from_servers_ips
   declare -A to_servers_ips
   local multiple_froms=false
   local multiple_tos=false
   if knife_env_set; then
      echo "$*" | \grep -q :
      if [ $? -eq 0 ]; then
         knife_node_list=`mktemp /tmp/knl.XXXX`
         /usr/bin/knife node list -c $KNIFERB > $knife_node_list
      fi
      if [ -n "$1" -a -n "$2" ]; then
         echo "$1" | \grep -q :
         if [ $? -eq 0 ]; then
            fromserver=`echo $1 | cut -d: -f1`
            from_server_nc=`\grep $fromserver $knife_node_list | awk '{print $1}'`
            nos=`echo "$from_server_nc" | wc -w`
            if [ $nos -gt 1 ]; then
               multiple_froms=true
               for _fs in $from_server_nc; do
                  from_servers_ips[$_fs]=`/usr/bin/knife node show -a ipaddress $_fs -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
               done
            else
               multiple_froms=false
               from_server=$from_server_nc
               from_server_ip=`/usr/bin/knife node show -a ipaddress $from_server -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
            fi
            from_file=`echo $1 | cut -d: -f2`
            ffc=":"
         else
            from_server=""
            from_server_ip=""
            from_file="$1"
            ffc=""
         fi
         echo "$2" | grep -q :
         if [ $? -eq 0 ]; then
            toserver=`echo $2 | cut -d: -f1`
            to_server_nc=`\grep $toserver $knife_node_list | awk '{print $1}'`
            nos=`echo "$to_server_nc" | wc -l`
            if [ $nos -gt 1 ]; then
               multiple_tos=true
               for _ts in $to_server_nc; do
                  to_servers_ips[$_ts]=`/usr/bin/knife node show -a ipaddress $_ts -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
               done
            else
               multiple_tos=false
               to_server=$to_server_nc
               to_server_ip=`/usr/bin/knife node show -a ipaddress $to_server -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
            fi
            to_file=`echo $2 | cut -d: -f2`
            tfc=":"
         else
            to_server=""
            to_server_ip=""
            to_file="$2"
            tfc=""
         fi
         if [ "$multiple_froms" = "true" -a "$multiple_tos" = "true" ]; then
            for _fs in $from_server_nc; do
               for _ts in $to_server_nc; do
                  echo "scp $_fs(${from_servers_ips[$_fs]}):$from_file $_ts(${to_servers_ips[$_ts]}):$to_file.$_fs" | egrep "$fromserver|$toserver"
                  /usr/bin/scp ${from_servers_ips[$_fs]}:$from_file ${to_servers_ips[$_ts]}:$to_file.$_fs
               done
            done
         elif [ "$multiple_froms" = "true" ]; then
            for _fs in $from_server_nc; do
               if [ -n "$to_server" ]; then
                  echo "scp $_fs(${from_servers_ips[$_fs]}):$from_file $to_server($to_server_ip):$to_file.$_fs" | egrep "$fromserver|$toserver"
                  /usr/bin/scp ${from_servers_ips[$_fs]}:$from_file $to_server_ip:$to_file.$_fs
               else
                  echo "scp $_fs(${from_servers_ips[$_fs]}):$from_file $to_file.$_fs" | grep $fromserver
                  /usr/bin/scp ${from_servers_ips[$_fs]}:$from_file $to_file.$_fs
               fi
            done
         elif [ "$multiple_tos" = "true" ]; then
            for _ts in $to_server_nc; do
               if [ -n "$from_server" ]; then
                  echo "scp $from_server($from_server_ip):$from_file $_ts(${to_servers_ips[$_ts]}):$to_file" | egrep "$toserver|$toserver"
                  /usr/bin/scp $from_server_ip:$from_file ${to_servers_ips[$_ts]}:$to_file
               else
                  echo "scp $from_file $_ts(${to_servers_ips[$_ts]}):$to_file" | grep $toserver
                  /usr/bin/scp $from_file ${to_servers_ips[$_ts]}:$to_file
               fi
            done
         else
            if [ -n "$from_server" -a -n "$to_server" ]; then
               echo "scp $from_server($from_server_ip):$from_file $to_server($to_server_ip):$to_file" | egrep "$fromserver|$toserver"
            elif [ -n "$from_server" ]; then
               echo "scp $from_server($from_server_ip):$from_file $to_file" | grep $fromserver
            elif [ -n "$to_server" ]; then
               echo "scp $from_file $to_server($to_server_ip):$to_file" | grep $toserver
            else
               echo "scp $from_file $to_file"
            fi
            /usr/bin/scp $from_server_ip$ffc$from_file $to_server_ip$tfc$to_file 
         fi
         rm -f $knife_node_list
      else
         echo "error: you have to specify a SOURCE and DEST"
      fi
  fi
}

function kssh () {
# ssh into a server matching a pattern or run a command on it if given
   if knife_env_set; then
      serverpattern=$1
      shift
      cmd="$*"
      source_ssh_env 
      server=`/usr/bin/knife node list -c $KNIFERB | \grep $serverpattern`
      if [ $? -eq 1 ]; then
         echo "server not found (via 'knife node list')"
         return 2
      fi
      nos=`echo "$server" | wc -l`
      if [ $nos -gt 1 ]; then
         sai=0
         echo "which server?"
         for srvr in $server; do
            ((sai++))
            echo "	$sai: $srvr"
            server_array[$sai]=$srvr
         done
         #echo "	a: all of the above; n-m: servers n-m; a,b,c,etc: servers a,b,c,etc."
         echo "	a: all | n-m: range | x,y: select"
         read -p "enter choice (1-$sai|a|n-m|x,y): " choice
         if [ -n "$choice" ]; then
            if [ $choice = a ]; then
               kssha -l "$server" "$cmd"
               return 0
            elif [[ $choice =~ ^[0-9]+-[0-9]+$ ]]; then
               s_n=${choice%-*}
               s_m=${choice#*-}
               tsl=""		# the server list
               for i in `seq $s_n $s_m`; do
                  [ -z "$tsl" ] && tsl="${server_array[$i]}" || tsl="$tsl ${server_array[$i]}"
               done
               #echo "debug: 'kssha -l \"$tsl\" \"\$cmd\"'"
               kssha -l "$tsl" "$cmd"
               ## couldn't get this to work
               ##choice=":`echo $choice | tr '-' ':'`"
               ##echo "debug: 'kssha -l \"${server_array[@]choice}\" \"$cmd\"'"
               ##kssha -l "${server_array[@]:choice}" "$cmd"
               return 0
            elif [[ $choice =~ ^[0-9]+(,[0-9]+)+ ]]; then
               tsl=""		# the server list
               for i in `echo $choice | tr ',' ' '`; do
                  [ -z "$tsl" ] && tsl="${server_array[$i]}" || tsl="$tsl ${server_array[$i]}"
               done
               #echo "debug: 'kssha -l \"$tsl\" \"\$cmd\"'"
               kssha -l "$tsl" "$cmd"
               return 0
            elif [ `echo $choice | grep [b-zA-Z]` ]; then
               echo "seriously?"
               return 3
            elif [ $choice -gt 0 -a $choice -le $sai ]; then
               server=${server_array[$choice]}
            else
               echo "seriously?"
               return 3
            fi
         else
            echo "later..."
            return 5
         fi
      fi
      server=`echo $server`	# get rid of leading whitespace and color
      #echo "debug: server='$server'"
      server_ifqdn=`/usr/bin/knife node show $server -a internal_fqdn -c $KNIFERB | grep internal_fqdn | awk '{print $NF}'`
      #echo "debug: server_ifqdn='$server_ifqdn'"
      server_ip=`/usr/bin/host $server_ifqdn 2>/dev/null| awk '{print $NF}'`
      #echo "debug: server_ip='$server_ip'"
      echo $server_ip | egrep -q '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
      if [ $? -ne 0 ]; then
         echo "debug: couldn't get IP with 'host' (DNS) for < $server > - using 'knife'"
         server_ip=`/usr/bin/knife node show $server -a ipaddress -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
      fi
      echo $server_ip | egrep -q '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
      if [ $? -eq 0 ]; then
         # don't do this for now - maybe later or with a smaller version of .bash_aliases
         ##if [ -z "$cmd" ]; then
         ##   scp -q ~/.{vim,bash}{rc,_aliases,_profile} $server_ip:/home/praco 2> /dev/null
         ##fi
         #[ -z "$cmd" ] && echo -e "	${CYN}< $server > [ $server_ip ]${NRM}" || echo -e "	${CYN}< $server > [ $server_ip ] ( $cmd )${NRM}"
         #[ -z "$cmd" ] && echo -e "	${CYN}$server ($server_ip)${NRM}" || echo -e "	${CYN}< $server > ( $server_ip ) [ $cmd ]${NRM}"
         if [ -z "$cmd" -o "$cmd" == "." ]; then
            echo -e "	${CYN}$server ($server_ip)${NRM}"
            if [ "$cmd" == "." ]; then
               /usr/bin/ssh -q $server_ip
            else
               $XTERM -e 'eval /usr/bin/ssh -q '"$server_ip"'' &
            fi
         else
            echo -e "	${CYN}< $server > ( $server_ip ) [ $cmd ]${NRM}"
            eval /usr/bin/ssh -q $server_ip "$cmd"
         fi
         echo -ne "\033]0;`whoami`@`hostname`\007"
      else
         echo "error: cannot get IP for server: < $server >"
      fi
   fi
}

function kssha () {
# run a command on multiple servers matching a given pattern
# options
#	-a	run on all servers
#	-l	run on this list of servers
#	-q	run quietly - less verbose - output on single lines
   if [ "$1" == "-q" ]; then
      QUIET=true
      shift
   else
      QUIET=false
   fi
   if [ "$1" == "-a" ]; then
      local _ALL=true
      shift
   else
      local _ALL=false
   fi
   if [ "$1" == "-l" ]; then
      shift
      server_list=$1
      shift
   else
      server_list=""
   fi
   if knife_env_set; then
      source_ssh_env 
      if [ -z "$server_list" ]; then
         if [ "$_ALL" = "true" ]; then
            server_list=`/usr/bin/knife node list -c $KNIFERB`
         else
            serverpattern="$1"
            shift
            server_list=`/usr/bin/knife node list -c $KNIFERB | \grep $serverpattern`
         fi
      fi
      cmd="$*"
      #echo "debug(kssha): server_list='$server_list'"
      #echo "debug(kssha): cmd='$cmd'"
      if [ -n "$cmd" ]; then
         #for server in `/usr/bin/knife node list -c $KNIFERB | \grep $serverpattern`; do
         for server in $server_list; do
            server=`echo $server`	# get rid of leading whitespace and color
            server_ifqdn=`/usr/bin/knife node show $server -a internal_fqdn -c $KNIFERB | grep internal_fqdn | awk '{print $NF}'`
            server_ip=`/usr/bin/host $server_ifqdn 2>/dev/null | awk '{print $NF}'`
            echo $server_ip | egrep -q '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
            if [ $? -ne 0 ]; then
               echo "debug: couldn't get IP with 'host' (DNS) for < $server > - using 'knife'"
               server_ip=`/usr/bin/knife node show $server -a ipaddress -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
            fi
            echo $server_ip | egrep -q '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
            if [ $? -eq 0 ]; then
               if [ $QUIET == "true" ]; then
                  #echo -n "$server ($server_ip) [$cmd]: "
                  echo -ne "${CYN}$server ($server_ip)${NRM}: "
               else
                  echo -e "	${CYN}< $server > ( $server_ip ) [ $cmd ]${NRM}"
               fi
               ##/usr/bin/ssh $server_ip "$cmd"
               #eval /usr/bin/ssh $server_ip "$cmd" 2> /dev/null
               eval /usr/bin/ssh -q $server_ip "$cmd"
               [ $? -ne 0 ] && echo
            else
               echo "error: cannot get IP for server: < $server >"
            fi
         done
      else
         #kcssh $serverpattern
         kcssha $server_list
         return 0
      fi
   fi
}

function ksshu () {
# ssh as ubuntu into a server using knife to get the IP
   if knife_env_set; then
      source_ssh_env
      server=`/usr/bin/knife node list -c $KNIFERB | \grep $1`
      nos=`echo "$server" | wc -l`
      if [ $nos -gt 1 ]; then
         echo "please be more specific:"
         echo "$server" | grep $1
         return
      fi
      server=`echo $server`        # get rid of leading whitespace and color
      server_ip=`/usr/bin/knife node show -a ipaddress $server -c $KNIFERB | \grep ipaddress | awk '{print $2}'|tr -d '\n'`
      shift
      cmd="$*"
      case $KNIFTLA in
         ccd|pek|w11|w12|w13) ssh_identy_file=~/.ssh/Red5China.pem      ;;
                         dts) ssh_identy_file=~/.ssh/Red5DevTest.pem    ;;
                         sna) ssh_identy_file=~/.ssh/Red5PublicTest.pem ;;
                           *) ssh_identy_file=~/.ssh/Red5Community.pem  ;;
      esac
      echo "/usr/bin/ssh -i $ssh_identy_file ubuntu@$server_ip \"$cmd\""
      #/usr/bin/ssh -i ~/.ssh/Red5China.pem ubuntu@$server_ip "$cmd" 2> /dev/null
      /usr/bin/ssh -q -i $ssh_identy_file ubuntu@$server_ip "$cmd"
      echo -ne "\033]0;`whoami`@`hostname`\007"
   fi
}

function mkalias () {	# TOOL
# make an alias and add it to this file
   if [[ $1 && $2 ]]; then
      echo "alias $1=\"$2\"" >> ~/.bash_aliases
      alias $1="$2"
   fi
}

function mktb () {	# MISC
# get rid of all the MISC, RHUG, and TRUG functions from $BRCSRC
# and save the rest to $BRCDST
 local BRCSRC=/home/praco/.bashrc
 local BRCDST=/home/praco/.bashrc.tools
   rm -f $BRCDST
   sed '/^function.*# MISC$/,/^}$/d;/^function.*# RHUG$/,/^}$/d;/^function.*# TRUG$/,/^}$/d' $BRCSRC > $BRCDST
}

function oav () {	# TOOL
# OpenStack attach a VIP (and optional FIP)
# 
# Usage: oav [-f] <instance> <last octet of vip>
# Option: -f	Create and attach a FIP to the VIP
   local pcsgo
   if [ -z "$OS_PASSWORD" -o -z "$OS_AUTH_URL" -o -z "$OS_USERNAME" -o -z "$OS_TENANT_NAME" ]; then
      echo "error: all of the OpenStack Environment variables aren't set"
      return 2
   fi
   if [ "$1" = "-f" ]; then
      afip="true"
      shift
   else
      afip="false"
   fi
   instance=$1
   loov=$2
   if [ -n "$instance" -a -n "$loov" ]; then
      instance_interfaces=`nova interface-list $instance | \grep ACTIVE`
      if [ $? -eq 0 ]; then
         instance_portid=`echo $instance_interfaces | awk '{print $4}'`
         instance_netid=`echo $instance_interfaces | awk '{print $6}'`
         instance_ip=`echo $instance_interfaces | awk '{print $8}'`
         iilo=`echo $instance_ip | cut -d'.' -f4`	#instance_ip_last_octect
         vip=`echo $instance_ip | sed 's/.'"$iilo"'$/.'"$loov"'/'`
         vippll=`neutron port-list | \fgrep '"'$vip'"'`
         if [ $? -ne 0 ]; then
            echo "creating VIP $vip with the following command:"
            for isg in `nova list-secgroup $instance | \egrep -v 'Id.*Name.*Description|------+------'|awk '{print $2}'`; do
               [ -n "$isg" ] && pcsgo="$pcsgo --security-group $isg"
            done
            echo "  neutron port-create --fixed-ip ip_address=$vip $pcsgo $instance_netid"
            ##vipid=test_vipid ##debug##
            vipid=`neutron port-create --fixed-ip ip_address=$vip $pcsgo $instance_netid | \fgrep "| id " | awk '{print $4}'`
         else
            echo "the VIP $vip already exists"
            vipid=`echo $vippll | awk '{print $2}'`
         fi
         ipsal=`neutron port-show $instance_portid | \fgrep allowed_address_pairs | \fgrep '"'$vip'"'`
         if [ $? -ne 0 ]; then
            echo "allowing the VIP to send traffic to the instance with the following command:"
            echo "  neutron port-update $instance_portid --allowed_address_pairs list=true type=dict ip_address=$vip"
            neutron port-update $instance_portid --allowed_address_pairs list=true type=dict ip_address=$vip
         else
            echo "the VIP is already allowed to send traffic to the instance"
            echo "  $ipsal"
         fi
         if [ "$afip" = "true" ]; then
            fipll=`neutron floatingip-list | \fgrep " $vip "`
            if [ $? -ne 0 ]; then
               echo "creating a FIP with the following command:"
               echo "  neutron floatingip-create net04_ext"
               ##fipid=test_fipid ##debug##
               fipid=`neutron floatingip-create net04_ext | \fgrep "| id " | awk '{print $4}'`
               echo "attaching a FIP using the following command"
               echo "  neutron floatingip-associate $fipid $vipid"
               ##fip=`neutron floatingip-associate $fipid $vipid | \fgrep "| id " | awk '{print $4}'` 
               neutron floatingip-associate $fipid $vipid > /dev/null
               fip=`neutron floatingip-list | \fgrep $fipid | awk '{print $6}'` 
               echo "VIP ($vip) is now attached to FIP ($fip)"
            else
               fip=`echo $fipll | awk '{print $6}'`
               echo "VIP ($vip) is already attached to FIP ($fip)"
            fi
         else
            echo "not creating a FIP or attaching it to the VIP"
         fi
      else
         echo "cannot get the interface info for instance: $instance"
      fi
   else
      echo "error: you did not specify an instance to attach the VIP to and last ip octet for the VIP"
   fi
}

function pag () {	# TOOL
   ps auxfw | grep $*
}

function peg () {	# TOOL
   ps -ef | grep $*
}

function rc () {	# MISC
# remember command - save the given command for later retreval
 COMMAND="$*"
 COMMANDS_FILE=/home/praco/.commands.txt
   echo "$COMMAND" >> $COMMANDS_FILE
   sort $COMMANDS_FILE > $COMMANDS_FILE.sorted
   mv -f $COMMANDS_FILE.sorted $COMMANDS_FILE
   echo "added '$COMMAND' to: $COMMANDS_FILE"
   scp -q $COMMANDS_FILE $OTHERVM:/home/praco
}

function rf () {	# MISC
# remember file - save the given file for later retreval
 FILE="$*"
 FILES_FILE=/home/praco/.files.txt
   echo "$FILE" >> $FILES_FILE
   sort $FILES_FILE > $FILES_FILE.sorted
   mv -f $FILES_FILE.sorted $FILES_FILE
   echo "added '$FILE' to: $FILES_FILE"
   scp -q $FILES_FILE $OTHERVM:/home/praco
}

function s3 () {
# `s3cmd` command wrapper to use my dynamically set s3cfg file
   if [ -z "$KNIFERB" ]; then
      echo "chef/knife environment NOT set - use 'ske'"
   else
      eval s3cmd -c $S3CFG '$*'
   fi
}

function update_spiceweasel_repo () {
# set which spiceweasel YAML file to use
 SPICEWEASELREPO=$REPO_DIR/spiceweasel
   cd $SPICEWEASELREPO > /dev/null
   hg incoming > /dev/null
   if [ $? -eq 0 ]; then
      echo -n "updating spiceweasel repo... "
      hg pu > /dev/null
      echo "done... "
   else
      echo "spiceweasel repo is up to date"
   fi
   cd - > /dev/null
   [ ! -e $SW_YAML_FILE ] && echo "No such file: $SW_YAML_FILE"
}

function showf () {	# TOOL
ALIASES_FILE="$HOME/.bash_aliases"
# show a function
   if [[ $1 ]]; then
      #declare -f $1 > /dev/null 2>&1
      grep -q "^function $1 " $ALIASES_FILE
      if [ $? -eq 0 ]; then
         echo -e "\n/-------------------------------------------------"
         #declare -f $1 | awk '{print "| "$0}'
         sed -n '/^function '"$1"' /,/^}/p' $ALIASES_FILE | awk '{print "| "$0}'
         echo -e "\-------------------------------------------------\n"
      else
         echo "function: '$1' - not found"
      fi
   else
      echo
      echo "which function do you want to see?"
      #declare -F | awk -v c=4 '{if(NR%c){printf "  %-15s",$3}else{printf "  %-15s\n",$3}}END{print CR}'
      grep "^function .* " $ALIASES_FILE | awk '{print $2}' | cut -d'(' -f1 |  awk -v c=4 'BEGIN{print "\n\t--- Functions (use \`sf\` to show details) ---"}{if(NR%c){printf "  %-18s",$1}else{printf "  %-18s\n",$1}}END{print CR}'
      echo -ne "enter function: "
      read func
      showf $func
   fi
}

function ske () {	# TOOL
# set knife environment
 local REPO=$CHEF_REPO
 local CHEF=$REPO/.chef
 local arg="$1"
 local SPICEWEASELREPO=$REPO_DIR/spiceweasel

   if [ -n "$arg" ]; then
      case $arg in
         ccd) akrb="knife_pek01_censorship.rb";     aenv="China Censorship Destra DNA"
              s3cg="$HOME/.s3cfg.pek01-censorship"; osrc="$HOME/.ccd.openstackrc.prod-pek01.sh"
              swyf="$SPICEWEASELREPO/production.vpc01.pek01-censorship.nodes.yml"               ;;
         dte) akrb="knife_devtest_ew.rb";           aenv="DevTest Europe West"                  ;;
         dts) akrb="knife_sna01_dts.rb";            aenv="OpenStack:DevTest US West SNA01"
              s3cg="$HOME/.s3cfg.sna01.dts";        osrc="$HOME/.dts.openstackrc.devtest-sna01.sh"
              swyf="$SPICEWEASELREPO/devtest.vpc01.sna01.nodes.yml"                             ;;
         dtu) akrb="knife_devtest_uw.rb";           aenv="DevTest US West"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/devtest.vpc01.us-west-2.nodes.yml"                         ;;
         nun) akrb="none";                          aenv="None"                                 ;;
         oce) akrb="knife_openstack_corp.rb";       aenv="OpenStack:Corp"                       ;;
         pek) akrb="knife_pek01.rb";                aenv="Asia Pacific PEK01"
              s3cg="$HOME/.s3cfg.pek01";            osrc="$HOME/.pek.openstackrc.prod-pek01.sh"
              swyf="$SPICEWEASELREPO/production.vpc01.pek01.nodes.yml"                          ;;
         pew) akrb="knife_prod_ew.rb";              aenv="Production Europe West"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/production.vpc01.eu-west-1.nodes.yml"                      ;;
         pms) akrb="knife_pms.rb";                  aenv="Production Migration Stack"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/production.vpc02.us-west-2.nodes.yml"                      ;;
         pue) akrb="knife_prod_ue.rb";              aenv="Production US East"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/production.vpc01.us-east-1.nodes.yml"                      ;;
         puw) akrb="knife_prod_uw.rb";              aenv="Production US West"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/production.vpc01.us-west-2.nodes.yml"                      ;;
         pte) akrb="knife_pubtest_ew.rb";           aenv="PubTest Europe West"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/pubtest.vpc01.eu-west-1.nodes.yml"                         ;;
         ptu) akrb="knife_pubtest_uw.rb";           aenv="PubTest US West"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/pubtest.vpc01.us-west-2.nodes.yml"                         ;;
         rou) akrb="knife_r5ops_uw.rb";             aenv="R5Ops US West"
              s3cg="";                              osrc=""
              swyf="$SPICEWEASELREPO/r5ops.vpc01.us-west-2.nodes.yml"                           ;;
         sna) akrb="knife_sna01_pts.rb";            aenv="OpenStack:PubTest US West SNA01"
              s3cg="$HOME/.s3cfg.sna01.pts";        osrc="$HOME/.sna.openstackrc.pubtest-sna01.sh"
              swyf="$SPICEWEASELREPO/pubtest.vpc01.sna01.nodes.yml"                             ;;
         w11) akrb="knife_wux01v01.rb";             aenv="OpenStack:Prod Asia Pacific WUX01-VPC01"
              s3cg="$HOME/.s3cfg.wux01v01";         osrc="$HOME/.wux01v01.openstackrc.prod-wux01.sh"
              swyf="$SPICEWEASELREPO/production.vpc01.wux01.nodes.yml"                           ;;
         w12) akrb="knife_wux01v02.rb";             aenv="OpenStack:Prod Asia Pacific WUX01-VPC02"
              s3cg="$HOME/.s3cfg.wux01v02";         osrc="$HOME/.wux01v02.openstackrc.prod-wux01.sh"
              swyf="$SPICEWEASELREPO/production.vpc02.wux01.nodes.yml"                           ;;
         w13) akrb="knife_wux01v03.rb";             aenv="OpenStack:Prod Asia Pacific WUX01-VPC03"
              s3cg="$HOME/.s3cfg.wux01v03";         osrc="$HOME/.wux01v03.openstackrc.prod-wux01.sh"
              swyf="$SPICEWEASELREPO/production.vpc03.wux01.nodes.yml"                           ;;
           *) echo "unknown environment; (known: ccd dte dts dtu nun oce pek pew pms pue puw pte ptu rou sna w11 w12 w13)"; return 2 ;;
      esac
      if [ "$arg" != "nun" ]; then
         export KNIFTLA=$arg
         export KNIFERB=$CHEF/$akrb
         export KNIFENV=$aenv
         export S3CFG=$s3cg
         export SW_YAML_FILE=$swyf
         export OSRC=$osrc
         [ -n "$OSRC" ] && source $OSRC
         export AWS_DEFAULT_PROFILE=$arg	# for `aws` (instead of using --profile)
         #echo "$KNIFENV (KNIFERB='$KNIFERB')"
         echo "environment has been set to --> $KNIFENV"
      else
         unset KNIFTLA
         unset KNIFERB
         unset KNIFENV
         unset S3CFG
         unset SW_YAML_FILE
         unset OSRC
         unset AWS_DEFAULT_PROFILE
         #echo "knife environment has been unset"
         echo "environment has been unset"
      fi
      ## I don't want to set this link anymore to force myself to set my environment
      ##(cd $CHEF; ln -fs $akrb $krb) 
      if [ "$COLOR_PROMPT" = yes ]; then
         case $arg in
            nun)
               PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]│\[\033[01;36m\]\$\[\033[00m\] ' ;;
            dte|dts|dtu|rou)
               PS1='\[\033[01;36m\][$KNIFTLA]\[\033[00m\]${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]│\[\033[01;36m\]\$\[\033[00m\] ' ;;
            pte|ptu|oce|sna)
               PS1='\[\033[01;33m\][$KNIFTLA]\[\033[00m\]${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]│\[\033[01;33m\]\$\[\033[00m\] ' ;;
            ccd|pek|pew|pms|pue|puw|w11|w12|w13)
               PS1='\[\033[01;31m\][$KNIFTLA]\[\033[00m\]${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\u@\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]│\[\033[01;31m\]\$\[\033[00m\] ' ;;
         esac
      fi
   else
      if [ -n "$KNIFERB" ]; then
         echo "--- $KNIFENV ---"
         echo " KNIFTLA             = '$KNIFTLA'"
         echo " KNIFERB             = '$KNIFERB'"
         echo " KNIFENV             = '$KNIFENV'"
         echo " S3CFG               = '$S3CFG'"
         echo " SW_YAML_FILE        = '$SW_YAML_FILE'"
         echo " OSRC                = '$OSRC'"
         echo " AWS_DEFAULT_PROFILE = '$AWS_DEFAULT_PROFILE'"
         #echo "$KNIFENV (KNIFERB='$KNIFERB')"
      else
         #echo "knife environment not set: KNIFENV='$KNIFENV' (KNIFERB='$KNIFERB')"
         echo "environment not set:"
         echo " KNIFTLA             = '$KNIFTLA'"
         echo " KNIFERB             = '$KNIFERB'"
         echo " KNIFENV             = '$KNIFENV'"
         echo " S3CFG               = '$S3CFG'"
         echo " SW_YAML_FILE        = '$SW_YAML_FILE'"
         echo " OSRC                = '$OSRC'"
         echo " AWS_DEFAULT_PROFILE = '$AWS_DEFAULT_PROFILE'"
      fi
   fi
}

function son () {	# TOOL
# ssh as ubuntu to an server via IP supplied by user
   nip=$1
   if [ -n "$nip" ]; then
      snauc=`ssh ubuntu@$nip -i ~/.ssh/Red5China.pem`
      echo "here's the command:"
      echo "	$snauc"
      read -p "is this correct? " ans
      if [ "$ans" = "y" ]; then
         echo "ok, running the command"
         eval "$snauc"
      else
         echo "ok, NOT running the command"
      fi
   else
      echo "need to specify an ip"
   fi
}

function sons () {	# TOOL
# ssh as ubuntu to an server via IP using knife
   if knife_env_set; then
      source_ssh_env 
      server=`/usr/bin/knife node list -c $KNIFERB | \grep $1`
      nos=`echo "$server" | wc -l`
      if [ $nos -gt 1 ]; then
         sai=0
         echo "which server?"
         for srvr in $server; do
            ((sai++))
            echo "	$sai: $srvr"
            server_array[$sai]=$srvr
         done
         read -p "enter choice (1-$sai): " choice
         if [ $choice -gt 0 -a $choice -le $sai ]; then
            server=${server_array[$choice]}
         else
            echo "seriously?"
            return
         fi
      fi
      server=`echo $server`	# get rid of leading whitespace and color
      server_ip=`/usr/bin/knife node show -a ipaddress $server -c $KNIFERB | \grep ipaddress | awk '{print $2}'`
      echo "$server ($server_ip)"
      #echo "ssh ubuntu@$server_ip -i ~/.ssh/Red5China.pem"
      #ssh ubuntu@$server_ip -i ~/.ssh/Red5China.pem 2> /dev/null
      #ssh -q ubuntu@$server_ip -i ~/.ssh/Red5China.pem
      echo "ssh ubuntu@$server_ip -i ~/.ssh/Red5Community.pem"
      ssh -q ubuntu@$server_ip -i ~/.ssh/Red5Community.pem
   fi
}

function source_ssh_env () {
 SSH_ENV="$HOME/.ssh/environment"

   if [ -f "${SSH_ENV}" ]; then
       . "${SSH_ENV}" > /dev/null
       #ps ${SSH_AGENT_PID} doesn't work under cywgin
       ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
           start_ssh_agent;
       }
   else
       start_ssh_agent;
   fi
}

##function sshc () {	# TOOL
##   source_ssh_env 
##   if [ $# -ge 2 ]; then
##      host=$1
##      shift
##      cmd="$*"
##      host $host > /dev/null
##      if [ $? -eq 0 ]; then
##         #ssh ecisupp@$host ''"$cmd"'' 2> /dev/null
##         ssh -q ecisupp@$host ''"$cmd"''
##      else
##         echo "unknown host: $host"
##      fi
##   else
##      echo "you did not specify the 'host' and 'cmd'"
##   fi
##}

function start_ssh_agent () {
 SSH_ENV="$HOME/.ssh/environment"

   echo -n "Initializing new SSH agent... "
   /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
   echo succeeded
   chmod 600 "${SSH_ENV}"
   . "${SSH_ENV}" > /dev/null
   /usr/bin/ssh-add;
}

function tb () {
   echo -ne "\033]0; $* \007"
}

function wtc () {	# MISC
# what's that command - retrieve the given command for use
 COMMAND_PATTERN="$*"
 COMMANDS_FILE=/home/praco/.commands.txt
   thecmd=`grep "$COMMAND_PATTERN" $COMMANDS_FILE`
   echo "$thecmd"
}

function wtf () {	# MISC
# what's that file - retrieve the given file for use
 FILE_PATTERN="$*"
 FILES_FILE=/home/praco/.files.txt
   thefile=`grep $FILE_PATTERN $FILES_FILE`
   echo "$thefile"
}

function zipstuff () {	# MISC
# zip up specified files for backup
   SRCSERVER="racovm"
##   DSTSERVER="jump1"
   STUFFZIP="/home/praco/stuff.r5.zip"
##   EMAILTO="praco@red5studios.com"
   FILES="
.*rc
.bash*
.commands.txt
.files.txt
.profile
.s3cfg
.ssh/config
.ssh/environment
projs
repos/.chef
repos/cloud-creator
repos/learningchef
repos/tools
scripts
"
   #EXCLUDE_FILES="*/.hg/\* repos/.chef/checksums/\* *.zip"	# didn't figure out how to make this work
   thisserver=`hostname`
   if [ "$thisserver" = "$SRCSERVER" ]; then
      echo "ziping $FILES to $STUFFZIP... "
      #/usr/bin/zip -ru $STUFFZIP $FILES -x $EXCLUDE_FILES
      /usr/bin/zip -ru $STUFFZIP $FILES -x */.hg/\* repos/.chef/checksums/\* */*/.git/\* */*.zip */*/*.zip
      echo done
##      echo "copying $STUFFZIP to $DSTSERVER:/misc/shared/Everyone/praco... "
##      scp $STUFFZIP $DSTSERVER:/misc/shared/Everyone/praco
##      echo done
   else
      echo "you have to be on $SRCSERVER to run this"
   fi
}

#alias a="alias"
alias a="alias | cut -d= -f1 | awk -v c=4 'BEGIN{print \"\n\t--- Aliases (use \`sa\` to show details) ---\"}{if(NR%c){printf \"  %-15s\",\$2}else{printf \"  %-15s\n\",\$2}}END{print CR}'"
alias c="clear"
#alias cba='echo "comparing ~/.bash_aliases with ${OTHERVM}... "; scp -pq $OTHERVM:/home/praco/.bash_aliases /home/praco/.bash_aliases.other; oldba=`ls -rt /home/praco/.bash_aliases{,.other}|head -1`; newba=`ls -rt /home/praco/.bash_aliases{,.other}|tail -1`; diff $oldba $newba; echo "done"'
alias cba='echo "comparing ~/.bash_aliases with ${OTHERVM}... "; scp -pq $OTHERVM:/home/praco/.bash_aliases /home/praco/.bash_aliases.other; diff ~/.bash_aliases{,.other}; echo "done"'
alias cp='cp -i'
alias crt='~/scripts/chef_recipe_tree.sh'
alias diff="colordiff -u"
#alias f="declare -F | awk '{print \$3}' | more"
#alias f="declare -F | awk -v c=4 'BEGIN{print \"\n\t--- Functions (use \`sf\` to show details) ---\"}{if(NR%c){printf \"  %-15s\",\$3}else{printf \"  %-15s\n\",\$3}}END{print CR}'"
alias f="grep '^function .* ' ~/.bash_aliases | awk '{print $2}' | cut -d'(' -f1 | awk -v c=4 'BEGIN{print \"\n\t--- Functions (use \`sf\` to show details) ---\"}{if(NR%c){printf \"  %-18s\",\$2}else{printf \"  %-18s\n\",\$2}}END{print CR}'"
alias fuck='echo "sudo $(history -p \!\!)"; sudo $(history -p \!\!)'
alias gh="history | grep"
alias ghwt='dmidecode | grep "Product Name"'
#alias grep="grep --color=auto"
alias grep="grep --color=always"
alias gsuid='printf "%x\n" `date +%s`'
alias h="history"
##alias hg="history | grep $1"	# conflicts with mercurial
#alias kcl='kf client list'
#alias knl='kf node list'
#alias l.='ls -d .* --color=auto'
alias l.='ls -d .* --color=always'
#alias la='ls -a --color=auto'
alias la='ls -a --color=always'
alias less="less -FrX"
#alias ll='ls -l --color=auto'
alias ll='ls -l --color=always'
#alias lla='ls -la --color=auto'
alias lla='ls -la --color=always'
#alias ls='ls --color=auto'
alias ls='ls --color=always'
alias mv='mv -i'
alias pushba='echo -n "pushing ~/.bash_aliases to $OTHERVM... "; scp -q /home/praco/.bash_aliases $OTHERVM:/home/praco/.bash_aliases; echo "done"'
alias pullba='echo -n "pulling ~/.bash_aliases from $OTHERVM... "; scp -q $OTHERVM:/home/praco/.bash_aliases /home/praco/.bash_aliases; echo "done"'
#alias psa='ps auxfw'
alias pa='ps auxfw'
#alias pse='ps -ef'
alias pe='ps -ef'
alias ring="/home/praco/scripts/ring.sh"
alias rsshk='ssh-keygen -f "/home/praco/.ssh/known_hosts" -R'
alias rm='rm -i'
alias sa=alias
alias sba='echo -n "sourcing ~/.bash_aliases... "; source ~/.bash_aliases; echo "done"'
alias sf=showf
alias sing="/home/praco/scripts/sing.sh"
#alias tt='echo -ne "\e]62;`whoami`@`hostname`\a"'
alias tt='echo -ne "\033]0;`whoami`@`hostname`\007"'
alias xterm='xterm -fg white -bg black -fs 10 -cn -rw -sb -si -sk -sl 5000'
alias u=uptime
alias vvaf=~/scripts/verify_vipsnfips.sh
alias vba='echo -n "editing ~/.bash_aliases... "; vi ~/.bash_aliases; echo "done"; echo -n "sourcing ~/.bash_aliases... "; source ~/.bash_aliases; echo "done"'
alias vsy='vi $SW_YAML_FILE' 
