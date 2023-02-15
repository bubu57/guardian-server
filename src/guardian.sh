#!/bin/bash

gtmp="/home/leaveit/guardian-server/src/gtmp.txt"
glog="/usr/share/guardian-server/log"
gaudit="/home/leaveit/guardian-server/src/audit.txt"
gconf="/home/leaveit/guardian-server/src/guardian.conf"

dir_list=$(grep "dir_list" $gconf | sed 's/dir_list="//g' | sed 's/"//g')


check () {
    echo -e "Checking packets...\n"
    liste=( "lynis" "clamscan" )

    for element in "${liste[@]}"
    do
        if command -v "$element" >/dev/null 2>&1 ; then
            echo -e "$element FOUND"
        else
            echo -e "$element NOT FOUND"
        fi
    done
}

lynis () {
    echo -e "system scann\n" >> $gaudit

    sudo lynis audit system --no-colors >$gtmp
    cmd=`cat $gtmp | grep "Warnings" | sed 's/(//g' | sed 's/)//g' | sed 's/://g' | sed 's/Warnings//g' | sed 's/ //g'`
    echo "Warning: $cmd" >> $gaudit
    cmd=`cat $gtmp | grep "Suggestions" | sed 's/(//g' | sed 's/)//g' | sed 's/://g' | sed 's/Suggestions//g' | sed 's/ //g'`
    echo "Suggestions: $cmd" >> $gaudit
    
}

clamav () {
    echo -e "\n\nVirus scan\n" >> $gaudit

    sudo clamscan -r $dir_list > $gtmp

    inf_file=$(grep "Infected files" $gtmp)
    tot_file=$(grep "Scanned files" $gtmp)

    echo -e "$tot_file\n$inf_file" >> $gaudit
}

check
echo -e "\nSystem check"
lynis
echo -e "\nVirus check"
clamav
cat $gaudit