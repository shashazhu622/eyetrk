#!/usr/bin/env zsh 
set -x

#Step1
ffmpeg -f rawvideo -framerate 250 -video_size 640x480 -pixel_format gray -r 250 -i $1.vid $1.mp4

sed "s/$(printf '\r')\$//" $1.trk > $1_modified.trk

a=`grep 'start timecounter:' $1_modified.trk`

echo $a

ffmpeg -i $1.mp4 -movflags use_metadata_tags -metadata creation_time=$a $1_fixed.mp4

ffprobe $1_fixed.mp4 1>&$1.txt

sed "s/$(printf '\r')\$//" $1.txt > $1_modified.txt

date=`cat $1_modified.txt | grep creation | awk -F'T' '{print $ (NF-1) }' | awk -F'time:' '{print $NF}'`

echo $date

time=`cat $1_modified.txt | grep creation | awk -F'T' '{print $NF }'| awk -F'.' '{print $ (NF-1) }'`

echo $time

#b=`echo -e "${date} \n\n ${time} \n\n%{pts\:hms}"`
#
#echo $b

#ffmpeg -i $1_fixed.mp4 -filter_complex drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text=\'${b}\' :
#          x=25: y=25: fontsize=12: fontcolor=white@0.9: box=0: boxcolor=black@0.8" -c:a copy $1_timestamped.mp4
#

#Step2

trigger_1=`cat $1_modified.trk | grep Trigger | awk -F'T' '{print $1 }'  | awk 'NR==1'`

echo $trigger_1

start_timecounter=`cat $1_modified.trk | grep 'start timecounter' | awk -F'time' '{print $(NF-1) }'|awk -F':' '{print $NF}'`

echo $start_timecounter

millisecs=`echo "$(($trigger_1-$start_timecounter))" |awk -F'.' '{print $1}'`

echo $millisecs

secs=`echo "$(($millisecs/1000))"`

echo $secs

secs_hhmmss=`printf '%d:%d:%d\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))`

echo $secs_hhmmss

trigger_last=`cat $1_modified.trk | grep Trigger | awk -F'T' '{print $1 }'  | awk 'END{print}'|awk -F'.' '{print $1}'`

echo $trigger_last

cat $1_modified.trk | grep Trigger | awk -F'T' '{print $1 }' > tr.txt #saves the times which have triggers

num_trigg=`wc -l tr.txt | awk '{print $(1)}'` #gets the length of the txt file which is the number of triggers

echo $num_trigg

trig_time=`echo "$(($trigger_last-$trigger_1))"`

echo $trig_time

TR_avg=`echo "$(($trig_time/($num_trigg-1)))"`

echo $TR_avg

stop_millisecs=`echo "$(($trigger_last+$TR_avg))"`

echo $stop_millisecs

duration_millisecs=`echo $(($stop_millisecs-$trigger_1))| awk -F'.' '{print $1}'`

echo $duration_millisecs

duration_secs=`echo "$(($duration_millisecs/1000))"`

echo $duration_secs

duration=`printf '%d:%d:%d\n' $(($duration_secs/3600)) $(($duration_secs%3600/60)) $(($duration_secs%60))`

echo $duration

ffmpeg -i $1_fixed.mp4 -ss ${secs_hhmmss} -t ${duration}  -c:a copy $1_trimmed.mp4


#Step3

time_in_secs=`echo ${time} | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'`

echo $time_in_secs

scan_start_secs=`echo "$(($time_in_secs+$secs))"`

echo $scan_start_secs

scan_start=`printf '%d:%d:%d\n' $(($scan_start_secs/3600)) $(($scan_start_secs%3600/60)) $(($scan_start_secs%60))`

echo $scan_start

c=`echo -e "${date} \n\n ${scan_start} \n\n%{pts\:hms}"`

echo $c

ffmpeg -i $1_trimmed.mp4 -filter_complex drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text=\'${c}\' :
          x=25: y=25: fontsize=12: fontcolor=white@0.9: box=0: boxcolor=black@0.8" -c:a copy $1_final.mp4
          

ffmpeg -i $1_final.mp4 -movflags use_metadata_tags -metadata creation_time="${date} ${scan_start}" $1_final_fixed.mp4


#Step4
trigger1_linenumber=` grep -n Trigger $1.trk | awk 'NR==1' |awk -F':' '{print $1}' `

echo $trigger1_linenumber

deleted_before_trigger1=`echo "$(($trigger1_linenumber-1))"`

echo $deleted_before_trigger1

echo `cat $1.trk | sed '1,'$deleted_before_trigger1' d' ` >$1_partially_trimmed.trk

echo `cat $1.trk | sed '1,'$deleted_before_trigger1' d' | sed '$d' | awk '{print $1}'` >trk1.txt

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



