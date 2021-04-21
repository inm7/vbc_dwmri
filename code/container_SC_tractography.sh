#!/bin/bash

input=${1}
totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
threads=${threads2}

# Path setting
# ------------
ftt=${tp}/${grp}/${sbj}/5tt.nii.gz
ftt_w_neck=${tp}/${grp}/${sbj}/5tt_w_neck.nii.gz
wm=${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
wmneck=${tp}/${grp}/${sbj}/fs_t1_neck_wm_mask_to_dwi.nii.gz

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

if [[ ${tract} -gt 999999 ]]; then
	tractM=$((${tract}/1000000))M
else
	tractM=$((${tract}/1000))K
fi

# Start the SC tractography
# -------------------------
startingtime=$(date +%s)
et=${tp}/${grp}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC tractography for ${tractM} - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

# Files for MRtrix
# ----------------
tck=${tp}/${grp}/${sbj}/WBT_${tractM}_ctx.tck
out=${tp}/${grp}/${sbj}/WBT_${tractM}_seeds_ctx.txt
mc_bval=${tp}/${grp}/${sbj}/mc_bval.dat
mc_bvec=${tp}/${grp}/${sbj}/mc_bvec.dat
odfGM=${tp}/${grp}/${sbj}/odf_gm.mif
odfWM=${tp}/${grp}/${sbj}/odf_wm.mif
odfCSF=${tp}/${grp}/${sbj}/odf_csf.mif
resGM=${tp}/${grp}/${sbj}/response_gm.txt
resWM=${tp}/${grp}/${sbj}/response_wm.txt
resSFWM=${tp}/${grp}/${sbj}/response_sfwm.txt
resCSF=${tp}/${grp}/${sbj}/response_csf.txt

# FOD estimation
# --------------
if [[ -f  ${odfWM} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - FOD (Fibre orientation distribution was already estimated!!!\n"
else

	# Response function
	# -----------------
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Estimate response functions.\n"
	case ${tracking_algorithm} in
	msmt_5tt )
	dwi2response ${tracking_algorithm} -shells ${shells} -force -nthreads ${threads} -voxels ${tp}/${grp}/${sbj}/response_voxels.nii.gz -mask ${wmneck} -pvf 0.95 -fa 0.2  -wm_algo tournier -fslgrad ${mc_bvec} ${mc_bval} ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ${ftt_w_neck} ${resWM} ${resGM} ${resCSF}
		;;
	tournier )
	dwi2response ${tracking_algorithm} ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ${resSFWM} -shells  ${non_zero_shells} -force -nthreads ${threads} -voxels ${tp}/${grp}/${sbj}/response_voxels.nii.gz -mask ${wmneck} -fslgrad ${mc_bvec} ${mc_bval}
		;;
	dhollander )
	dwi2response ${tracking_algorithm} -shells ${shells} -force -nthreads ${threads} -voxels ${tp}/${grp}/${sbj}/response_voxels.nii.gz -mask ${wmneck} -erode 3 -fa 0.2 -sfwm 0.5 -gm 2 -csf 10 -fslgrad ${mc_bvec} ${mc_bval} ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ${resWM} ${resGM} ${resCSF}
	if [[ -f ${resSFWM} ]]; then
		rm -f ${resSFWM}
	fi
	echo $(tail -n 1 ${resWM}) >> ${resSFWM}
		;;
	* )
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Invalid tracking algorithm for dwi2response!\n"
	exit 1
		;;
	esac
	if [[ -f ${resWM} ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${resWM} has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${resWM} has not been saved!!\n"
		exit 1
	fi

	# FOD estimation
	# --------------
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Estimate fibre orientation distributions using spherical deconvolution.\n"
	case ${fod_algorithm} in
	msmt_csd )
	dwi2fod ${fod_algorithm} -shells ${shells} -force -nthreads ${threads} -mask ${tp}/${grp}/${sbj}/dwi_bcecmc_avg_bet_mask_w_neck.nii.gz -fslgrad ${mc_bvec} ${mc_bval} ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ${resWM} ${odfWM} ${resGM} ${odfGM} ${resCSF} ${odfCSF}
		;;
	csd )
	dwi2fod ${fod_algorithm} ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ${resSFWM} ${odfWM} -shells ${non_zero_shells} -force -nthreads ${threads} -mask ${tp}/${grp}/${sbj}/dwi_bcecmc_avg_bet_mask_w_neck.nii.gz -fslgrad ${mc_bvec} ${mc_bval}
		;;
	* )
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Invalid FOD algorithm for dwi2fod!\n"
	exit 1
		;;
	esac
	if [[ -f ${odfWM} ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${odfWM} has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${odfWM} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} FOD estimation" >> ${et}
fi

# Whole-brain tractography
# ------------------------
if [[ -f ${tck} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Whole brain tracking was already performed!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Start whole brain tracking.\n"
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Output: WBT_${tractM}_ctx.tck\n"
	tckgen -algorithm ${tckgen_algorithm} -select ${tract} -step ${tckgen_step} -angle ${tckgen_angle} -minlength ${tckgen_minlength} -maxlength ${tckgen_maxlength} -cutoff ${tckgen_cutoff} -trials ${tckgen_trials} -downsample ${tckgen_downsample} -seed_dynamic ${odfWM} -max_attempts_per_seed ${tckgen_max_attempts_per_seed} -output_seeds ${out} -act ${ftt_w_neck} -backtrack -crop_at_gmwmi -samples ${tckgen_samples} -power ${tckgen_power} -fslgrad ${mc_bvec} ${mc_bval} -nthreads ${threads} ${odfWM} ${tck}
	if [[ -f ${tck} ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${tck} has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${tck} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Whole-brain tractography" >> ${et}
fi
