#!/bin/bash
fn=${1}
input=${2}
startNum=${3}
totalNum=${4}

threads=1
for (( i = startNum; i < totalNum + 1 ; i++ )); do
    sbj=$(sed -n ${i}p ${fn})

	# Part 4: Reconstruct
	# -------------------
	printf "/usr/local/bin/container_SC_reconstruct.sh ${input} ${threads} ${sbj}\n"
	/usr/local/bin/container_SC_reconstruct.sh ${input} ${threads} ${sbj}
done