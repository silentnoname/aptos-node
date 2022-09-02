#!/bin/bash
check_sync()
{
    sync=$(curl 127.0.0.1:9101/metrics 2> /dev/null | grep 'aptos_state_sync_version{type="synced"}'| sed -n -e '1p' | grep -o '[0-9]*')
    echo -n  ${sync}
}

check_outbound()
{
    outbound=$(curl 127.0.0.1:9101/metrics 2> /dev/null | grep "outbound" |sed -n -e '1p')
    outboundf=$(echo "${outbound:(-3)}" |  grep -o '[0-9]*')
    echo -n  ${outboundf}
}

check_consensus_proposals_count()
{
    aptos_consensus_proposals_count=$(curl 127.0.0.1:9101/metrics 2> /dev/null | grep 'aptos_consensus_proposals_count')
    count=$(echo "$aptos_consensus_proposals_count"|sed -n -e '3p' | grep -o '[0-9]*')
    echo -n  ${count}
}

check_running_status()
{
    outbound=$(check_outbound)
    if [ -z $outbound ];then
       sleep 30
       outboundn=$(check_outbound)
       if [ -z $outboundn ];then
          echo  -n 0
       else 
          echo  -n 1
       fi
    else 
      echo  -n 1
    fi
}



restart_docker()
{
    echo $(date) "Restarting your docker, pls wait 30 seconds"
    docker compose stop
    sleep 30
    docker compose start
    echo $(date) "Sleep 60s after restarting"
    sleep 60
}


monitor()
{  
   time_count=0
   tempsync=0
   temppro=0
   while true; do
   status=$(check_running_status)
   if [ $status == 0 ];then
      echo $(date) "Your node might not running, will restart your node"
      restart_docker
      time_count=0
      tempsync=0
      temppro=0
   else 
      echo $(date) "Your node looks normal, will check more node status"  
   fi
   sync=$(check_sync)
   if [[ $sync -le $tempsync && -n $sync ]];then
      echo $(date) "You node not syncing for 2 min, will restart your node. Last time "$tempsync", Now "$sync""
      restart_docker
      tempsync=0
      time_count=0
      temppro=0
   else 
      echo $(date) "Your node current sync: "$sync" ."
   fi
   tempsync=$sync
   proposals=$(check_consensus_proposals_count)
   echo $(date) "Your current consensus_proposals_count is "$proposals""
   if [[ $proposals -gt $temppro && -n $proposals  ]];then
         time_count=0
         let temppro=$proposals
         echo $(date) "Your node have made new proposals, will reset counter"
   fi
   if [ $time_count  == 12 ];then
         echo "Around 24 min no new consensus_proposals , will restart your node"
         restart_docker
         tempsync=0
         time_count=0
         temppro=0
   fi
   sleep 120
   let time_count=$time_count+1
   done
}
monitor