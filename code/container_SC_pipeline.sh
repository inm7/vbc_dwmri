#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

# Part 1: Preprocessing
# ---------------------
printf "/usr/local/bin/container_SC_preprocess.sh ${input} ${threads} ${sbj}\n"
/usr/local/bin/container_SC_preprocess.sh ${input} ${threads} ${sbj}

# Part 2: Tractography
# --------------------
printf "/usr/local/bin/container_SC_tractography.sh ${input} ${threads} ${sbj}\n"
/usr/local/bin/container_SC_tractography.sh ${input} ${threads} ${sbj}

# Part 3: Atlas transformation
# ----------------------------
printf "/usr/local/bin/container_SC_atlas_transformation.sh ${input} ${threads} ${sbj}\n"
/usr/local/bin/container_SC_atlas_transformation.sh ${input} ${threads} ${sbj}

# Part 4: Reconstruct
# -------------------
printf "/usr/local/bin/container_SC_reconstruct.sh ${input} ${threads} ${sbj}\n"
/usr/local/bin/container_SC_reconstruct.sh ${input} ${threads} ${sbj}
