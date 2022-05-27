mkdir frames_block
mkdir blockanimframes
rm -rf output.avi

cropsize=16

numblocksX=7
numblocksY=7

ffmpeg -r 20 -hide_banner -i 3333.gif -vf scale=$((cropsize*numblocksX)):$((cropsize*numblocksY)) -c:v r210 output.avi

nb_frames_beforenum=$(ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -show_streams 'output.avi' | grep nb_frames)
framecount=${nb_frames_beforenum#*=}

count=0
vidposX=0
vidposY=0
parseanimframe () {
    cropposX=$((cropsize*vidposX))
    cropposY=$((cropsize*vidposY))
    ffmpeg -hide_banner -i output.avi -filter:v crop=$cropsize:$cropsize:$cropposX:$cropposY -c:v r210 blockframe.avi
    ffmpeg -hide_banner -i blockframe.avi frames_block/%04d.png
    rm blockframe.avi
    montage frames_block/*.png -geometry +0+0 -tile x1 blockanimframes/$(echo $count | sed -e :a -e 's/^.\{1,3\}$/0&/;ta').png
}

echo '#' > animations.txt

for i in $(seq $numblocksY); do
    for i in $(seq $numblocksX); do
        count=$((count + 1))
        parseanimframe
        animputputY=$((numblocksX*vidposY))
        animputputX=$((vidposX))
        animputput_realY=$((animputputY+animputputX))
        echo $vidposX $((8+vidposY)) 0 $((cropsize*animputput_realY)) $cropsize $framecount 0 >> animations.txt
        vidposX=$((vidposX + 1))
    done
    vidposX=0
    vidposY=$((vidposY + 1))
done

montage blockanimframes/*.png -geometry +0+0 -tile 1x  animations.png

rm -rf output.avi
rm -rf frames_block
rm -rf blockanimframes