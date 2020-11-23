#!/bin/bash
input=${1}

# Part 1: Preprocessing
# ---------------------
printf "/usr/local/bin/container_SC_preprocess.sh ${input}\n"
/usr/local/bin/container_SC_preprocess.sh ${input}

# Part 2: Tractography
# --------------------
printf "/usr/local/bin/container_SC_tractography.sh ${input}\n"
/usr/local/bin/container_SC_tractography.sh ${input}

# Part 3: Atlas transformation
# ----------------------------
printf "/usr/local/bin/container_SC_atlas_transformation.sh ${input}\n"
/usr/local/bin/container_SC_atlas_transformation.sh ${input}

# Part 4: Reconstruct
# -------------------
printf "/usr/local/bin/container_SC_reconstruct.sh ${input}\n"
/usr/local/bin/container_SC_reconstruct.sh ${input}

