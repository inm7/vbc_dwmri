#!/bin/bash
grp=${1}
sbj=${2}

fp=/mnt_fp # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
ap=/mnt_ap # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
tp=/mnt_tp # /p/scratch/cjinm71/jung3/03_Structural_Connectivity

LUT=${ap}/HarvardOxford_96Parcels_LUT.txt

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

mris_ca_label -sdir ${fp} -t ${LUT} -l ${fp}/${grp}_${sbj}/label/lh.cortex.label ${grp}_${sbj} lh ${fp}/${grp}_${sbj}/surf/lh.sphere.reg ${ap}/lh.HarvardOxford_96Parcels.gcs ${fp}/${grp}_${sbj}/label/lh.HarvardOxford_96Parcels.annot
mris_ca_label -sdir ${fp} -t ${LUT} -l ${fp}/${grp}_${sbj}/label/rh.cortex.label ${grp}_${sbj} rh ${fp}/${grp}_${sbj}/surf/rh.sphere.reg ${ap}/rh.HarvardOxford_96Parcels.gcs ${fp}/${grp}_${sbj}/label/rh.HarvardOxford_96Parcels.annot
export SUBJECTS_DIR=${fp}
mri_aparc2aseg --s ${grp}_${sbj} --o ${fp}/${grp}_${sbj}_HarvardOxford_96Parcels.nii.gz --annot HarvardOxford_96Parcels
mri_convert ${fp}/${grp}_${sbj}_HarvardOxford_96Parcels.nii.gz ${fp}/${grp}_${sbj}/mri/aparc.HarvardOxford_96Parcels+aseg.mgz
export SUBJECTS_DIR=/opt/freesurfer/subjects
printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Native parcellation: ${fp}/${grp}_${sbj}/mri/aparc.HarvardOxford_96Parcels+aseg.mgz has been saved.\n"
