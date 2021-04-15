#!/bin/bash

input=${1}
totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
threads=${threads3}
num=${numparc}

ctx=${tp}/${grp}/${sbj}/fs_t1_ctx_mask_to_dwi.nii.gz
atl=${tp}/${grp}/${sbj}/${atlname}_to_dwi.nii.gz
tmp=${tp}/${grp}/${sbj}/temp

# Colors
# ------
RED='\033[1;31m'
GRN='\033[1;32m'
NCR='\033[0m' # No Color

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Freesurfer license
# ------------------
if [[ -f /opt/freesurfer/license.txt ]]; then
	printf "Freesurfer license has been checked.\n"
else
	echo "${email}" >> $FREESURFER_HOME/license.txt
	echo "${digit}" >> $FREESURFER_HOME/license.txt
	echo "${line1}" >> $FREESURFER_HOME/license.txt
	echo "${line2}" >> $FREESURFER_HOME/license.txt
	printf "Freesurfer license has been updated.\n"
fi

startingtime=$(date +%s)
et=${tp}/${grp}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC atlas transformation - $(date)" >> ${et}
echo "Starting time in seconds ${startingtime}" >> ${et}

if [[ -f ${atl} ]]; then
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Atlas transformation was already performed!!!\n"
else
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Transform the target atlas.\n"
	mri_convert ${fp}/${grp}_${sbj}/mri/brainmask.mgz ${tmp}/fs_t1.nii.gz
	fslreorient2std ${tmp}/fs_t1.nii.gz ${tmp}/fs_t1.nii.gz
	for (( i = 1; i < num + 1; i++ )); do
		fslmaths ${ap} -thr ${i} -uthr ${i} ${tmp}/temp_mask1.nii.gz
		fslmaths ${tmp}/temp_mask1.nii.gz -bin ${tmp}/temp_mask1.nii.gz
		applywarp --ref=${tmp}/fs_t1.nii.gz --in=${tmp}/temp_mask1.nii.gz --out=${tmp}/temp_mask2.nii.gz --warp=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --premat=${tp}/${grp}/${sbj}/mni_to_fs_t1_flirt.mat
		applywarp -i ${tmp}/temp_mask2.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcec_avg_bet.nii.gz -o ${tmp}/temp_mask3.nii.gz --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
		fslmaths ${tmp}/temp_mask3.nii.gz -thr 0.5 -uthr 0.5 ${tmp}/temp_mask4.nii.gz
		fslmaths ${tmp}/temp_mask3.nii.gz -sub ${tmp}/temp_mask4.nii.gz ${tmp}/temp_mask3.nii.gz
		fslmaths ${tmp}/temp_mask3.nii.gz -thr 0.5 ${tmp}/temp_mask3.nii.gz
		fslmaths ${tmp}/temp_mask3.nii.gz -bin ${tmp}/temp_mask3.nii.gz
		fslmaths ${tmp}/temp_mask3.nii.gz -mul ${i} ${tmp}/temp_mask3.nii.gz
		if [[ ${i} = 1 ]]; then
			cp ${tmp}/temp_mask3.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_mask3.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	mv ${tmp}/temp_mask.nii.gz ${atl}
	fslmaths ${tp}/${grp}/${sbj}/fs_t1_ctx_mask_to_dwi.nii.gz -add ${tp}/${grp}/${sbj}/fs_t1_subctx_mask_to_dwi.nii.gz ${tmp}/temp_mask5.nii.gz
	fslmaths ${tmp}/temp_mask5.nii.gz -add ${tp}/${grp}/${sbj}/fs_t1_neck_gm_mask_to_dwi.nii.gz ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz -bin ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz

	fslmaths ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz -add ${tp}/${grp}/${sbj}/fs_t1_neck_wm_mask_to_dwi.nii.gz ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz -bin ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz

	fslmaths ${atl} -mul ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz ${atl}

	rm ${tmp}/temp*.nii.gz
	
	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "${elapsedtime} ${atlname}" >> ${et}
fi
