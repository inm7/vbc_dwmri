#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
# threads=${threads3}
num=${numparc}

# Path setting
# ------------
atlmni=${ap}/${atlas}
ctx=${tp}/${grp}/${sbj}/fs_t1_ctx_mask_to_dwi.nii.gz
atl=${tp}/${grp}/${sbj}/${atlname}_to_dwi.nii.gz
tmp=${tp}/${grp}/${sbj}/temp

# Transform function for loops
# ----------------------------
Transform()
{
	idx=${1}
	mask1=${tmp}/temp_label${idx}_mask1.nii.gz
	mask2=${tmp}/temp_label${idx}_mask2.nii.gz
	mask3=${tmp}/temp_label${idx}_mask3.nii.gz
	mask4=${tmp}/temp_label${idx}_mask4.nii.gz

	fslmaths ${atlmni} -thr ${idx} -uthr ${idx} -bin ${mask1}
	applywarp --ref=${tmp}/fs_t1.nii.gz --in=${mask1} --out=${mask2} --warp=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --premat=${tp}/${grp}/${sbj}/mni_to_fs_t1_flirt.mat
	applywarp -i ${mask2} -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${mask3} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${mask3} -thr 0.5 -uthr 0.5 ${mask4}
	fslmaths ${mask3} -sub ${mask4} -thr 0.5 -bin -mul ${idx} ${mask3}
}

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

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

# Start the SC atlas transformation
# ---------------------------------
startingtime=$(date +%s)
et=${tp}/${grp}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC atlas transformation with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

if [[ -f ${atl} ]]; then
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Atlas transformation was already performed!!!\n"
else
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Transform the target atlas.\n"
	mri_convert ${fp}/${grp}_${sbj}/mri/nu.mgz ${tmp}/fs_t1.nii.gz
	fslreorient2std ${tmp}/fs_t1.nii.gz ${tmp}/fs_t1.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/dwi_bcecmc_avg_bet_mask.nii.gz -mul 0 ${tmp}/temp_mask.nii.gz
	for (( i = 1; i < num + 1; i++ ))
	do
		Transform ${i} &
	done
	wait
	for (( i = 1; i < num + 1; i++ ))
	do
		fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_thread${i}_mask3.nii.gz ${tmp}/temp_mask.nii.gz
	done
	fslmaths ${tp}/${grp}/${sbj}/fs_t1_ctx_mask_to_dwi.nii.gz -add ${tp}/${grp}/${sbj}/fs_t1_subctx_mask_to_dwi.nii.gz -add ${tp}/${grp}/${sbj}/fs_t1_neck_gm_mask_to_dwi.nii.gz -bin ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz -add ${tp}/${grp}/${sbj}/fs_t1_neck_wm_mask_to_dwi.nii.gz -bin ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
	fslmaths ${tmp}/temp_mask.nii.gz -mul ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz ${atl}
	rm -f ${tmp}/temp*.nii.gz
	if [[ -f ${atl} ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atl} has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atl} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} ${atlname}" >> ${et}
fi

echo "[-] SC atlas transformation - $(date)" >> ${et}