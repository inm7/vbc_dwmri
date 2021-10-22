#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

# Part 1: Preprocessing
# ---------------------
printf "/mnt_sw/code/container_SC_preprocess.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_preprocess.sh ${input} ${threads} ${sbj}
wait

# Part 2: Tractography
# --------------------
printf "/mnt_sw/code/container_SC_tractography.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_tractography.sh ${input} ${threads} ${sbj}
wait

# Part 3: Atlas transformation
# ----------------------------
printf "/mnt_sw/code/container_SC_atlas_transformation.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_atlas_transformation.sh ${input} ${threads} ${sbj}
wait

# Part 4: Reconstruct
# -------------------
printf "/mnt_sw/code/container_SC_reconstruct.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_SC_reconstruct.sh ${input} ${threads} ${sbj}
wait
