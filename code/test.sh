#!/bin/bash
num=${1}
threads=${2}

nThr=0
for (( i = 1; i < num + 1; i++ ))
do
    printf "    Process ${i}"
    sleep 3 &
    (( nThr++ ))
    printf ", Running threads ${nThr}\n"
    if [[ ${nThr} -eq ${threads} ]]; then
        wait
        nThr=0
    fi
done
wait