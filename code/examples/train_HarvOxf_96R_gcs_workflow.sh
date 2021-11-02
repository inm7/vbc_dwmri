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

# EXPLANATION
# -----------
# The personalized parcellation needs a classifier to parcel cortical areas on the surface in the native T1 space. 
# Some atlases provide classifiers corresponding to volumetric labeled images in the standard brain template, such as MNI152. 
# If it is not the case, we can also create a classifier for the given volumetric images.
# For example, figure 8 illustrates the process of creating a classifier based  on transformed volumetric images from the MNI space for the Harvard-Oxford atlas.
# Based on individual volumetric label images, we can project the labels on the vertices of cortical surfaces. 
# After that, we can take a representative one, which has the most frequent on each vertex. 
# Subsequently, we have the most representative annotation on the vertices based on the used samples. 
# The annotation file is used to generate a classifier. Finally, we created classifiers of the Harvard-Oxford atlas for each hemisphere.
# Figure 9 shows annotation examples about different results by thresholding with 25% or 0% of the Harvard-Oxford atlas.
# In the case of 25% thresholding, we met some empty vertices due to compact cortical volumes.
# In contrast, the 0% thresholding gives relatively large region volumes which can cover empty vertices.
# Therefore, we used 0% thresholding to create the classifiers of the Harvard-Oxford atlas.

# train_HarvOxf_96R_gcs_step_1.sh : Non-linear transformation from MNI152 1mm to T1-weighted image
# ------------------------------------------------------------------------------------------------
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

# train_HarvOxf_96R_gcs_step_2.sh : Volumetric parcellations to surface annotation with a given colors (look-up table)
# --------------------------------------------------------------------------------------------------------------------
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

# train_HarvOxf_96R_gcs_step_3.sh : Create a gcs file (classifier) by training 351 HCP subjects
# ---------------------------------------------------------------------------------------------
# SCRIPT='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri/code/examples/train_HarvOxf_96R_gcs_step_3.sh'
# printf "singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh &\n"
# singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh
# wait

# train_HarvOxf_96R_gcs_step_4.sh : Project to individuals
# --------------------------------------------------------
# SCRIPT='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri/code/examples/train_HarvOxf_96R_gcs_step_4.sh'
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
