#!/usr/bin/env zsh 
set -x

#Step3: Timestamp the trimmed .mp4, add renewed metadata to the trimmed and timestamped  .mp4

ffprobe $1_fixed.mp4 1>&$1.txt

sed "s/$(printf '\r')\$//" $1.txt > $1_modified.txt

date=`cat $1_modified.txt | grep creation | awk -F'T' '{print $ (NF-1) }' | awk -F'time:' '{print $NF}'`

echo $date

time=`cat $1_modified.txt | grep creation | awk -F'T' '{print $NF }'| awk -F'.' '{print $ (NF-1) }'`

echo $time

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
          

ffmpeg -i $1_retimestamped.mp4 -movflags use_metadata_tags -metadata creation_time="${date} ${scan_start}" $1_final_fixed.mp4
