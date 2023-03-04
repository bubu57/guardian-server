#!/bin/bash

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
            echo -e "$element   [FOUND]"
        else
            echo -e "$element   [NOT FOUND]"
        fi
    done

    echo -e "\n\nChecking file intergity\n------------------------"
    if [ -f "/usr/share/guardian-server/src/guardian.conf" ]; then echo "guardian config file   [FOUND]" ;else echo "guardian config file  [NOT FOUND]" ;fi

    echo -e "\n\nChecking guardian config\n------------------------"
    if [ -z "$gdest" ]; then echo "backup destination   [EMPTY]" ;else echo "backup destination  [DONE]" ;fi
    if [ -z "$gsrc" ]; then echo "backup source   [EMPTY]" ;else echo "backup source  [DONE]" ;fi
    if [ -z "$dir_list" ]; then echo "directories list scan   [EMPTY]" ;else echo "directories list scan  [DONE]" ;fi
    if [ -z "$greciver" ]; then echo "mail reciver   [EMPTY]" ;else echo "mail reciver  [DONE]" ;fi
    if [ -z "$gsender" ]; then echo "mail sender   [EMPTY]" ;else echo "mail sender  [DONE]" ;fi
    if [ -z "$gpassword" ]; then echo "mail sender password   [EMPTY]" ;else echo "mail sender password    [DONE]" ;fi
    if [ -z "$gntfy" ]; then echo "ntfy topic   [EMPTY]" ;else echo "ntfy topic  [DONE]" ;fi
    
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

    # sizedir=`sudo du -hs $gdest | awk '{ print $1 }'`
    nbdir=`sudo ls $gdest | wc -l`

    echo -e "size of dir: $sizedir\nnumber of directories: $nbdir\n" >> $gaudit
}

echo -e "\n\nguardian result\n==================" > $gaudit
check
echo -ne "\nchecking system..."
lynis
echo "  [DONE]"
echo -n "checking virus..."
clamav
echo "  [DONE]"
# echo -n "backup..."
# backup
# echo "  [DONE]"
cat $gaudit

audit_send=`cat $gaudit`
curl -d "$audit_send" $gntfy