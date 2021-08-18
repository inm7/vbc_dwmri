#!/bin/bash
# v1.3

CPUS='4'
RAM='48G'
DISK='120G'
LOGS_DIR=~/htcondor-templates/vbc_dwmri/logs
VBC_DWMRI='/data/project/singularity/vbc_dwmri_1.1.0.simg'
SOFTWARE_DIR='/data/project/personalized_pipeline/01_MRI_pipelines/Container/vbc_dwmri'
DATA_DIR='/data/project/personalized_pipeline/02_MRI_data'
ATLAS_DIR='/data/project/personalized_pipeline/02_MRI_data/Atlases'
OUTPUT_SC_DIR='/data/project/personalized_pipeline/03_Structural_Connectivity'
OUTPUT_FC_DIR='/data/project/personalized_pipeline/03_Functional_Connectivity'
FREESURFER_OUTPUT='/data/project/personalized_pipeline/Neuroimage/Tools/freesurfer/subjects'
FREESURFER_LICENSE='/opt/freesurfer/6.0/license.txt'
INPUT_PARAMETERS='/data/project/personalized_pipeline/02_MRI_data/input_TEST_10M_Schaefer100P17N.txt'
SLICEORDER='/data/project/personalized_pipeline/02_MRI_data/TEST_sliceorder.txt'
# SHELL_SCRIPT=$(pwd)/${1}

# create the logs dir if it doesn't exist
[ ! -d "${LOGS_DIR}" ] && mkdir -p "${LOGS_DIR}"

# print the .submit header
printf "# The environment
universe       = vanilla
getenv         = True
request_cpus   = ${CPUS}
request_memory = ${RAM}
request_disk   = ${DISK}

# Execution
initial_dir    = \$ENV(HOME)/htcondor-templates/vbc_dwmri
executable     = /usr/bin/singularity
\n"

# loop over all subjects
for sub in 101309 102311; do
    printf "arguments = exec --cleanenv \
                        -B ${SOFTWARE_DIR}:/mnt_sw,${DATA_DIR}:/mnt_sp,${OUTPUT_SC_DIR}:/mnt_sc,${OUTPUT_FC_DIR}:/mnt_fc,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SHELL_SCRIPT}:/opt/script.sh,${INPUT_PARAMETERS}:/opt/input.txt,${SLICEORDER}:/opt/sliceorder.txt \
                        ${VBC_DWMRI} \
                        /mnt_sw/code/container_FC_pipeline.sh \
                        /opt/input.txt \
                        ${CPUS} \
                        ${sub}\n"
    printf "log       = ${LOGS_DIR}/\$(Cluster).\$(Process).${sub}.log\n"
    printf "output    = ${LOGS_DIR}/\$(Cluster).\$(Process).${sub}.out\n"
    printf "error     = ${LOGS_DIR}/\$(Cluster).\$(Process).${sub}.err\n"
    printf "Queue\n\n"
done
