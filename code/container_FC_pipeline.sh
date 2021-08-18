#!/bin/bash
input=${1}
threads=${2}
sbj=${3}

# Part 1: Preprocessing
# ---------------------
printf "/mnt_sw/code/container_FC_preprocess.sh ${input} ${threads} ${sbj}\n"
/mnt_sw/code/container_FC_preprocess.sh ${input} ${threads} ${sbj}

# Part 2: BOLD extraction
# -----------------------
# printf "/mnt_sw/code/container_FC_bold_extraction.sh ${input} ${threads} ${sbj}\n"
# /mnt_sw/code/container_FC_bold_extraction.sh ${input} ${threads} ${sbj}
