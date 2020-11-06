#!/usr/bin/env zsh 
set -x

#Step2: Trim .mp4 

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