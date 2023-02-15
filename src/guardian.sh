#!/bin/bash

gtmp="/home/leaveit/guardian-server/src/gtmp.txt"
glog="/usr/share/guardian-server/log"
gaudit="/usr/share/guardian-server/audit"


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
    echo -e "\n\nLynis scan...\n"
    sudo lynis audit system --no-colors >$gtmp
    cmd=`cat $gtmp | grep "Warnings" | sed 's/(//g' | sed 's/)//g' | sed 's/://g' | sed 's/Warnings//g' | sed 's/ //g'`
    echo "Warning: $cmd"
    cmd=`cat $gtmp | grep "Suggestions" | sed 's/(//g' | sed 's/)//g' | sed 's/://g' | sed 's/Suggestions//g' | sed 's/ //g'`
    echo "Suggestions: $cmd"
}

clamav () {
    echo -e "\n\nclamav scan...\n"

    sudo clamscan -r /bin > $gtmp

    inf_file=$(grep "Infected files" $gtmp)
    tot_file=$(grep "Scanned files" $gtmp)

    echo -e "$tot_file\n$inf_file"
}

# check
# lynis
clamav