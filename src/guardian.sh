#!/bin/bash

./etc/rc.d/init.d/functions

gtmp="/usr/share/guardian-server/src/gtmp.txt"
glog="/usr/share/guardian-server/src/log"
gaudit="/usr/share/guardian-server/src/audit.txt"
gconf="/usr/share/guardian-server/src/guardian.conf"

dir_list=$(grep "dir_list" $gconf | sed 's/dir_list="//g' | sed 's/"//g')
gdest=$(grep "backup_dest" $gconf | sed 's/backup_dest="//g' | sed 's/"//g')
gsrc=$(grep "backup_src" $gconf | sed 's/backup_src="//g' | sed 's/"//g')
greciver=$(grep "mailreciver" $gconf | sed 's/mailreciver="//g' | sed 's/"//g')
gsender=$(grep "mailsender" $gconf | sed 's/mailsender="//g' | sed 's/"//g')
gpassword=$(grep "passwordsender" $gconf | sed 's/passwordsender="//g' | sed 's/"//g')
gntfy=$(grep "topic" $gconf | sed 's/topic="//g' | sed 's/"//g')



check () {
    echo -e "Checking require\n------------------------"
    liste=( "lynis" "clamscan" )

    for element in "${liste[@]}"
    do
        if command -v "$element" >/dev/null 2>&1 ; then
            echo_success
        else
            echo_failure
        fi
    done

    echo -e "\n\nChecking file intergity\n------------------------"
    gprintf "guardian config file"
    if [ -f "/usr/share/guardian-server/src/guardian.conf" ]; then echo echo_success ;else echo echo_failure ;fi

    echo -e "\n\nChecking guardian config\n------------------------"
    gprintf "backup destination"
    if [ -z "$gdest" ]; then echo_failure ;else echo_success ;fi
    gprintf "backup source"
    if [ -z "$gsrc" ]; then echo_failure ;else echo_success ;fi
    gprintf "directories list scan"
    if [ -z "$dir_list" ]; then echo_failure ;else echo_success ;fi
    gprintf "mail reciver"
    if [ -z "$greciver" ]; then echo_failure ;else echo_success ;fi
    gprintf "mail sender"
    if [ -z "$gsender" ]; then echo_failure ;else echo_success ;fi
    gprintf "mail sender passord"
    if [ -z "$gpassword" ]; then echo_failure ;else echo_success ;fi
    gprintf "ntfy topic"
    if [ -z "$gntfy" ]; then echo_failure ;else echo_success ;fi

}

lynis () {
    echo -e "\n[+] System scan\n-----------\n" >> $gaudit

    sudo lynis audit system --no-colors >$gtmp
    cmd=`cat $gtmp | grep "Warnings" | sed 's/(//g' | sed 's/)//g' | sed 's/://g' | sed 's/Warnings//g' | sed 's/ //g'`
    echo "Warning: $cmd" >> $gaudit
    cmd=`cat $gtmp | grep "Suggestions" | sed 's/(//g' | sed 's/)//g' | sed 's/://g' | sed 's/Suggestions//g' | sed 's/ //g'`
    echo "Suggestions: $cmd" >> $gaudit

    sudo sed -i -e 's/  //g' $gtmp
    echo "Recommendations\n" > $glog
    sudo grep '^*' $gtmp >> $glog
    
}

clamav () {
    echo -e "\n\n[+] Virus scan\n-----------\n" >> $gaudit

    sudo clamscan -r $dir_list > $gtmp

    inf_file=$(grep "Infected files" $gtmp)
    tot_file=$(grep "Scanned files" $gtmp)
    dir_scan=$(grep "Scanned directories" $gtmp)

    echo -e "$tot_file\n$inf_file\n$dir_scan" >> $gaudit
}

backup () {
    echo -e "\n\n[+] Backup\n-----------\n" >> $gaudit
    dat=`date '+%Y-%m-%d_%H:%M'`

    sudo mkdir "$gdest/$dat"

    sudo cp -fr "$gsrc" "$gdest/$dat/"

    sudo cd $dest

    sudo zip -r "$dat" "$dat" >> $gdest/$dat/back_log
    sudo rm -fr "$dat"

    sizedir=`sudo du -hs $gdest | awk '{ print $1 }'`
    nbdir=`sudo ls $gdest | wc -l`

    echo -e "size of dir: $sizedir\nnumber of directories: $nbdir\n" >> $gaudit
}

echo -e "\n\nguardian result\n==================" > $gaudit
check
echo -ne "\nchecking system..."
lynis
echo_success
echo -n "checking virus..."
clamav
echo_success
echo -n "backup..."
backup
echo_success
cat $gaudit


audit_send=`cat $gaudit`
curl -d "$audit_send" $gntfy