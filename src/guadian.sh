#!/bin/bash

gtmp="/usr/share/guardian-server/gatmp"
glog="/usr/share/guardian-server/log"
gaudit="/usr/share/guardian-server/audit"

rkhunter () {
    cmd=`sudo rkhunter -c -q --summary >$gtmp`
    sudo cat /var/log/rkhunter.log
    cmd=`cat /$gtmp | grep "Files checked" | sed 's/  //g' | sed 's/Files checked: //g'`
    echo "files checked: $cmd1"
    cmd=`cat /$gtmp | grep "Suspect files" | sed 's/  //g' | sed 's/Suspect files: //g'`
    echo "Suspect files: $cmd2"
}