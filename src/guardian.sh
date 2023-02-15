#!/bin/bash

gtmp="/home/leaveit/guardian-server/gtmp"
glog="/usr/share/guardian-server/log"
gaudit="/usr/share/guardian-server/audit"

rkhunter () {
    cmd=`sudo rkhunter -c -q --summary >$gtmp`
    # sudo cat /var/log/rkhunter.log
    cmd=`cat /$gtmp | grep "Files checked" | sed 's/  //g' | sed 's/Files checked//g'`
    echo "files checked$cmd"
    cmd=`cat /$gtmp | grep "Suspect files" | sed 's/  //g' | sed 's/Suspect files//g'`
    echo "Suspect files$cmd"
    cmd=`cat /$gtmp | grep "Rootkits checked" | sed 's/  //g' | sed 's/Rootkits checked//g'`
    echo "Rootkits checked$cmd"
    cmd=`cat /$gtmp | grep "Possible rootkits" | sed 's/  //g' | sed 's/Possible rootkits//g'`
    echo "Possible rootkits$cmd"
}

rkhunter