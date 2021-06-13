#!/bin/bash

# train_HarvOxf_96R_gcs_HCP_N351
# ------------------------------
# sbj=101309
grp=HCP
sbj=${1}
fp=/mnt_fp # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
ap=/mnt_ap # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
tp=/mnt_tp # /p/scratch/cjinm71/jung3/03_Structural_Connectivity
atl=HarvardOxford/HarvardOxford-cortl-maxprob-thr0-1mm.nii.gz
mni_brain=/usr/share/fsl/5.0/data/standard/MNI152_T1_1mm_brain.nii.gz
tmp=${tp}/${grp}/${sbj}/temp

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

# Temporary folder check
# ----------------------
if [[ -d ${tmp} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Temporary folder exists, so the process will overwrite the files in the target folder.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Create a temporary folder.\n"
	mkdir -p ${tmp}
fi

mri_convert ${fp}/${grp}_${sbj}/mri/brain.mgz ${tmp}/fs_t1_brain.nii.gz

# Linear transformation from T1-weigted image to the MNI152 T1 1mm
# --------------------------------------------------------------------
flirt -ref ${mni_brain} -in ${tmp}/fs_t1_brain.nii.gz -omat ${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat -dof 12

# Non-linear transformation from T1-weigted image to the MNI152 T1 1mm
# --------------------------------------------------------------------
fnirt --in=${tmp}/fs_t1_brain.nii.gz --aff=${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat --cout=${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --config=T1_2_MNI152_2mm

# Apply the deformation to the atlas on the MNI152 T1
# ---------------------------------------------------
invwarp --ref=${tmp}/fs_t1_brain.nii.gz --warp=${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --out=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz
applywarp --ref=${tmp}/fs_t1_brain.nii.gz --in=${ap}/${atl} --warp=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --out=${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz --interp=nn

# Create annotation files (lh and rh)
# -----------------------------------
mri_convert ${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz ${fp}/${grp}_${sbj}/mri/HarvardOxford_96R.mgz 
mris_sample_parc -ct ${ap}/HO_R96_color_table.txt -sdir ${fp} ${grp}_${sbj} rh HarvardOxford_96R.mgz rh.HarvardOxford_96R.annot
mris_sample_parc -ct ${ap}/HO_R96_color_table.txt -sdir ${fp} ${grp}_${sbj} lh HarvardOxford_96R.mgz lh.HarvardOxford_96R.annot
