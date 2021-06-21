#!/bin/bash

# train_HarvOxf_96R_gcs_HCP_N351.sh
# ---------------------------------
# grp=HCP
# sbj=101309
fn=${1}
grp=${2}
startNum=${3}
totalNum=${4}

fp=/mnt_fp # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
ap=/mnt_ap # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
tp=/mnt_tp # /p/scratch/cjinm71/jung3/03_Structural_Connectivity
atl=HarvardOxford/HarvardOxford-cortl-maxprob-thr0-1mm.nii.gz
mni_brain=/usr/share/fsl/5.0/data/standard/MNI152_T1_1mm_brain.nii.gz

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

for (( i = startNum; i < totalNum + 1 ; i++ )); do
    sbj=$(sed -n ${i}p ${fn})

	tmp=${tp}/${grp}/${sbj}/temp

	# Temporary folder check
	# ----------------------
	if [[ -d ${tmp} ]]; then
		printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Temporary folder exists, so the process will overwrite the files in the target folder.\n"
	else
		printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Create a temporary folder.\n"
		mkdir -p ${tmp}
	fi

	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Convert T1 brain: ${tmp}/fs_t1_brain.nii.gz.\n"
	mri_convert ${fp}/${grp}_${sbj}/mri/brain.mgz ${tmp}/fs_t1_brain_ori.nii.gz

	# AC-PC alignment
	# ---------------
	robustfov -i ${tmp}/fs_t1_brain_ori.nii.gz -b 170 -m ${tmp}/acpc_roi2full.mat -r ${tmp}/acpc_robustroi.nii.gz
	flirt -interp spline -in ${tmp}/acpc_robustroi.nii.gz -ref ${mni_brain} -omat ${tmp}/acpc_roi2std.mat -out ${tmp}/acpc_roi2std.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30
	convert_xfm -omat ${tmp}/acpc_full2roi.mat -inverse ${tmp}/acpc_roi2full.mat
	convert_xfm -omat ${tmp}/acpc_full2std.mat -concat ${tmp}/acpc_roi2std.mat ${tmp}/acpc_full2roi.mat
	aff2rigid ${tmp}/acpc_full2std.mat ${tmp}/acpc.mat
	convert_xfm -omat ${tmp}/acpc_inv.mat -inverse ${tmp}/acpc.mat
	applywarp --rel --interp=spline -i ${tmp}/fs_t1_brain_ori.nii.gz -r ${mni_brain} --premat=${tmp}/acpc.mat -o ${tmp}/fs_t1_brain.nii.gz
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - AC-PC alignment: ${tmp}/acpc.mat and ${tmp}/acpc_inv.mat has been calculated.\n"

	# Linear transformation from T1-weigted image to the MNI152 T1 1mm
	# --------------------------------------------------------------------
	flirt -ref ${mni_brain} -in ${tmp}/fs_t1_brain.nii.gz -omat ${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat -dof 12
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Linear transformation: ${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat has been saved.\n"

	# Non-linear transformation from T1-weigted image to the MNI152 T1 1mm
	# --------------------------------------------------------------------
	fnirt --in=${tmp}/fs_t1_brain.nii.gz --aff=${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat --cout=${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --config=T1_2_MNI152_2mm
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Non-linear transformation: ${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz has been saved.\n"

	# Apply the deformation to the atlas on the MNI152 T1
	# ---------------------------------------------------
	invwarp --ref=${tmp}/fs_t1_brain.nii.gz --warp=${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --out=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz
	applywarp --ref=${tmp}/fs_t1_brain.nii.gz --in=${ap}/${atl} --warp=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --out=${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz --interp=nn
	applywarp -i ${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz -r ${tmp}/fs_t1_brain_ori.nii.gz -o ${tp}/${grp}/${sbj}/HO_to_fs_t1_ori.nii.gz --premat=${tmp}/acpc_inv.mat --interp=nn
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Apply the deformation: ${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz has been saved.\n"

	# Create annotation files (lh and rh)
	# -----------------------------------
	mri_convert ${tp}/${grp}/${sbj}/HO_to_fs_t1_ori.nii.gz ${fp}/${grp}_${sbj}/mri/HarvardOxford_96R.mgz 
	mris_sample_parc -ct ${ap}/HO_R96_color_table.txt -sdir ${fp} ${grp}_${sbj} lh HarvardOxford_96R.mgz lh.HarvardOxford_96R.annot
	mris_sample_parc -ct ${ap}/HO_R96_color_table.txt -sdir ${fp} ${grp}_${sbj} rh HarvardOxford_96R.mgz rh.HarvardOxford_96R.annot
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Annotation files: lh.HarvardOxford_96R.annot and rh.HarvardOxford_96R.annot have been saved.\n"
done
# mris_ca_train -sdir /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/subjects -n 10 -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt lh sphere.reg HarvardOxford_96R HCP_101309 HCP_102311 HCP_103111 HCP_108525 HCP_110411 HCP_111009 HCP_111413 HCP_112920 HCP_126628 HCP_131217 lh.HarvardOxford_96R_HCP_N10.gcs
# mris_ca_train -sdir /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/subjects -n 10 -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt rh sphere.reg HarvardOxford_96R HCP_101309 HCP_102311 HCP_103111 HCP_108525 HCP_110411 HCP_111009 HCP_111413 HCP_112920 HCP_126628 HCP_131217 rh.HarvardOxford_96R_HCP_N10.gcs

# mris_ca_label -sdir ${FS} -l ${FS}/PD_HHU_PD_020130429/label/lh.cortex.label -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt PD_HHU_PD_020130429 lh ${FS}/PD_HHU_PD_020130429/surf/lh.sphere.reg /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/lh.HarvardOxford_96R_HCP_N10.gcs ${FS}/PD_HHU_PD_020130429/label/lh.HarvardOxford_96R_HCP_N10.annot
# mris_ca_label -sdir ${FS} -l ${FS}/PD_HHU_PD_020130429/label/rh.cortex.label -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt PD_HHU_PD_020130429 rh ${FS}/PD_HHU_PD_020130429/surf/rh.sphere.reg /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/rh.HarvardOxford_96R_HCP_N10.gcs ${FS}/PD_HHU_PD_020130429/label/rh.HarvardOxford_96R_HCP_N10.annot

# export SUBJECTS_DIR=${FS}
# mri_aparc2aseg --s PD_HHU_PD_020130429 --o ./temp_atlas.nii.gz --annot HarvardOxford_96R_HCP_N10
# export SUBJECTS_DIR=/Applications/freesurfer/7.1.1/subjects
