#!/bin/bash
# num=${1}
# threads=${2}

# nThr=0
# for (( i = 1; i < num + 1; i++ ))
# do
#     printf "    Process ${i}"
#     sleep 3 &
#     (( nThr++ ))
#     printf ", Running threads ${nThr}\n"
#     if [[ ${nThr} -eq ${threads} ]]; then
#         wait
#         nThr=0
#     fi
# done
# wait

# threads=${1}
# max_threads=48
# for (( j = 1; j < threads + 1; j++ )); do
#     if [[ ${j} -eq 1 ]]; then
#         run_threads="1"
#         null_threads="0"
#     else
#         run_threads+="1"
#         null_threads+="0"
#     fi
# done
# printf "run_threads = ${run_threads}\n"
# printf "null_threads = ${null_threads}\n"

# for (( i = threads; i < max_threads + 1; i+= threads )); do
#     if [[ ${i} -eq 1 ]]; then
#         bind_bin=${run_threads}
#         zero_bin=${null_threads}
#     else
#         bind_bin=${run_threads}${zero_bin}
#         zero_bin+=${null_threads}
#     fi
#     if [[ ${i} -gt ${max_threads} ]]; then
#         printf "Exceeded ${i} out of ${max_threads}\n"
#     else
#         bind_hex=$(echo "obase=16;ibase=2;${bind_bin}" | bc )
#         printf "${bind_bin} > ${bind_hex} (Job ${i})\n"
#     fi
# done
