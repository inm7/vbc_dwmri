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

# fn=${1}
# startNum=${2}
# totalNum=${3}
# wp=$(pwd)
# for (( i = startNum; i < totalNum + 1 ; i++ )); do
#     sbj=$(sed -n ${i}p ${wp}/${fn})
# done

# fn=${1}
# totalNum=${2}
# sp=/data/group/mathneuro/Popovych/PD_HHU/raw
# wp=$(pwd)
# tp=$(pwd)
# printf "MRI\n"
# for (( i = 1; i < totalNum + 1 ; i++ )); do
#   sbj=$(sed -n ${i}p ${wp}/${fn})
# 	t1w=${sp}/${sbj}/3D/${sbj}_orig.nii.gz
# 	dwi=${sp}/${sbj}/DWI/${sbj}.nii.gz
# 	bval=${sp}/${sbj}/DWI/${sbj}.bval
# 	bvec=${sp}/${sbj}/DWI/${sbj}.bvec
# 	epi=${sp}/${sbj}/EPI/${sbj}.nii.gz
# 	sbj_bool=true
# 	if [[ -f ${t1w} ]]; then
# 		t1w_bool=true	
# 	else
# 		sbj_bool=false
# 	fi
# 	if [[ -f ${dwi} && -f ${bval} && -f ${bvec} ]]; then
# 		dwi_bool=true
# 	else
# 		sbj_bool=false
# 	fi
# 	if [[ -f ${epi} ]]; then
# 		epi_bool=true
# 	else
# 		sbj_bool=false
# 	fi
# 	if ${sbj_bool}; then
# 		mkdir -p ${tp}/${sbj}/anat
# 		mkdir -p ${tp}/${sbj}/dwi
# 		mkdir -p ${tp}/${sbj}/func
# 		cp ${t1w} ${tp}/${sbj}/anat/${sbj}_T1w.nii.gz
# 		cp ${bval} ${tp}/${sbj}/dwi/${sbj}_dwi.bval
# 		cp ${bvec} ${tp}/${sbj}/dwi/${sbj}_dwi.bvec
# 		cp ${dwi} ${tp}/${sbj}/dwi/${sbj}_dwi.nii.gz
# 		cp ${epi} ${tp}/${sbj}/func/${sbj}_task-rest_bold.nii.gz
# 		printf "1\n"
# 	else
# 		printf "0\n"
# 	fi
# done

# nStep=0
# for i in $(seq 1001 2 1095) $(seq 2002 2 2096)
# do
#     (( nStep++ ))
#     printf "step ${nStep}: ${i}\n"
# done
