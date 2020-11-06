#!/usr/bin/env zsh 
set -x


#Step4: Trim .trk

trigger1_linenumber=` grep -n Trigger $1.trk | awk 'NR==1' |awk -F':' '{print $1}' `

echo $trigger1_linenumber

deleted_before_trigger1=`echo "$(($trigger1_linenumber-1))"`

echo $deleted_before_trigger1

echo `cat $1.trk | sed '1,'$deleted_before_trigger1' d' ` >$1_partially_trimmed.trk

echo `cat $1_partially_trimmed.trk | sed '$d' | awk '{print $1}'` >trk1.txt

echo `while read i;do
    if [[ "$i" -lt "${stop_millisecs}" ]];then
        echo $i;
    else
        echo Bad
fi
done <trk1.txt`  >trk2.txt

trigger_last_TR_linenumber=` grep -n Bad trk2.txt | awk 'NR==1' |awk -F':' '{print $1}' `
echo $trigger_last_TR_linenumber

deleted_after=`echo "$(($trigger_last_TR_linenumber+1))"`

echo $deleted_after

echo `cat $1_partially_trimmed.trk | sed ' '$deleted_after', $d '` >$1_fully_trimmed.trk

