#!/usr/bin/env zsh 
set -x

#Step1: Convert .vid to .mp4, add metadata (creation_time)

ffmpeg -f rawvideo -framerate 250 -video_size 640x480 -pixel_format gray -r 250 -i $1.vid $1.mp4

sed "s/$(printf '\r')\$//" $1.trk > $1_modified.trk

a=`grep 'start timecounter:' $1_modified.trk`

echo $a

ffmpeg -i $1.mp4 -movflags use_metadata_tags -metadata creation_time=$a $1_fixed.mp4

#ffmpeg -i $1_fixed.mp4 -filter_complex drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text=\'${b}\' :
#          x=25: y=25: fontsize=12: fontcolor=white@0.9: box=0: boxcolor=black@0.8" -c:a copy $1_timestamped.mp4
