#!/bin/bash
fn=${1}
grp=${2}
startNum=${3}
endNum=${4}
maxTasks=${5}

VBC_DWMRI='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri_v1.3.simg'
FREESURFER_LICENSE='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/license.txt'

SET_FP='/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects'
SET_TP='/p/scratch/cjinm71/jung3/03_Structural_Connectivity'
SET_AP='/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas'

# train_HarvOxf_96R_gcs_step_1.sh
# -------------------------------
# SCRIPT='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri/code/examples/train_HarvOxf_96R_gcs_step_1.sh'
# nTask=0
# for (( i = startNum; i < endNum + 1 ; i++ )); do
#     sbj=$(sed -n ${i}p ${fn})
#     ARGUMENTS="${grp} ${sbj}"
# 	  printf "singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${ARGUMENTS} &\n"
#     singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${ARGUMENTS} &
#     (( nTask++ ))
#     if [[ ${nTask} -eq ${maxTasks} ]]; then
#         wait
#         nTask=0
#     fi
# done
# wait

# train_HarvOxf_96R_gcs_step_2.sh
# -------------------------------
# SCRIPT='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri/code/examples/train_HarvOxf_96R_gcs_step_2.sh'
# nTask=0
# for (( i = startNum; i < endNum + 1 ; i++ )); do
#     sbj=$(sed -n ${i}p ${fn})
#     ARGUMENTS="${grp} ${sbj}"
# 	  printf "singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${ARGUMENTS} &\n"
#     singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${ARGUMENTS} &
#     (( nTask++ ))
#     if [[ ${nTask} -eq ${maxTasks} ]]; then
#         wait
#         nTask=0
#     fi
# done
# wait

# train_HarvOxf_96R_gcs_step_3.sh
# -------------------------------
SCRIPT='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri/code/examples/train_HarvOxf_96R_gcs_step_3.sh'

printf "singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh &\n"
singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh
wait
