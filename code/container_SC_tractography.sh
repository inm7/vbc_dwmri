#!/bin/bash

input=${1}
totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
threads=${threads2}

ftt=${tp}/${grp}/${sbj}/5tt.nii.gz
# ftt_w_neck=${tp}/${grp}/${sbj}/5tt_w_neck.nii.gz

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


if [[ ${tract} -gt 999999 ]]; then
	tractM=$((${tract}/1000000))M
else
	tractM=$((${tract}/1000))K
fi

startingtime=$(date +%s)
et=${tp}/${grp}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC tractography for ${tractM} - $(date)" >> ${et}
echo "Starting time in seconds ${startingtime}" >> ${et}

# MRtrix
# ------
# tck=${tp}/${grp}/${sbj}/WBT_${tractM}_ctx_w_neck.tck
# out=${tp}/${grp}/${sbj}/WBT_${tractM}_seeds_ctx_w_neck.txt
# odfGM=${tp}/${grp}/${sbj}/odf_gm_w_neck.mif
# odfWM=${tp}/${grp}/${sbj}/odf_wm_w_neck.mif
# odfCSF=${tp}/${grp}/${sbj}/odf_csf_w_neck.mif
# resGM=${tp}/${grp}/${sbj}/response_gm_w_neck.txt
# resWM=${tp}/${grp}/${sbj}/response_wm_w_neck.txt
# resCSF=${tp}/${grp}/${sbj}/response_csf_w_neck.txt
tck=${tp}/${grp}/${sbj}/WBT_${tractM}_ctx.tck
out=${tp}/${grp}/${sbj}/WBT_${tractM}_seeds_ctx.txt
mbvec=${tp}/${grp}/${sbj}/dt_recon/bvecs.dat
mbval=${tp}/${grp}/${sbj}/dt_recon/bvals.dat
odfGM=${tp}/${grp}/${sbj}/odf_gm.mif
odfWM=${tp}/${grp}/${sbj}/odf_wm.mif
odfCSF=${tp}/${grp}/${sbj}/odf_csf.mif
resGM=${tp}/${grp}/${sbj}/response_gm.txt
resWM=${tp}/${grp}/${sbj}/response_wm.txt
resCSF=${tp}/${grp}/${sbj}/response_csf.txt
if [[ -f  ${odfWM} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - FOD (Fibre orientation distribution was already estimated!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Estimate response functions.\n"

	# dwi2response msmt_5tt -shells ${shells} -force -nthreads ${threads} -voxels ${tp}/${grp}/${sbj}/response_voxels_w_neck.nii.gz -fslgrad ${mbvec} ${mbval} ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz ${ftt_w_neck} ${resWM} ${resGM} ${resCSF}
	dwi2response ${tracking_algorithm} -shells ${shells} -force -nthreads ${threads} -voxels ${tp}/${grp}/${sbj}/response_voxels.nii.gz -fslgrad ${mbvec} ${mbval} ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz ${ftt} ${resWM} ${resGM} ${resCSF}

	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Estimate fibre orientation distributions using spherical deconvolution.\n"
	
	# dwi2fod msmt_csd -shells ${shells} -force -nthreads ${threads} -mask ${tp}/${grp}/${sbj}/dwi_bcec_avg_bet_mask_w_neck.nii.gz -fslgrad ${mbvec} ${mbval} ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz ${resWM} ${odfWM} ${resGM} $odfGM ${resCSF} ${odfCSF}
	dwi2fod ${fod_algorithm} -shells ${shells} -force -nthreads ${threads} -mask ${tp}/${grp}/${sbj}/dwi_bcec_avg_bet_mask.nii.gz -fslgrad ${mbvec} ${mbval} ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz ${resWM} ${odfWM} ${resGM} $odfGM ${resCSF} ${odfCSF}
fi
if [[ -f ${tck} ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Whole brain tracking was already performed!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Start whole brain tracking.\n"
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Output: WBT_${tractM}_ctx.tck\n"
	# tckgen -algorithm iFOD2 -select ${tract} -step 0.625 -angle 45 -minlength 2.5 -maxlength 250 -cutoff 0.06 -trials 1000 -downsample 3 -seed_dynamic ${odfWM} -max_attempts_per_seed 50 -output_seeds ${out} -act ${ftt_w_neck} -backtrack -crop_at_gmwmi -samples 4 -power 0.25 -fslgrad ${mbvec} ${mbval} -bvalue_scaling true -nthreads ${threads} ${odfWM} ${tck}
	tckgen -algorithm ${tckgen_algorithm} -select ${tract} -step ${tckgen_step} -angle ${tckgen_angle} -minlength ${tckgen_minlength} -maxlength ${tckgen_maxlength} -cutoff ${tckgen_cutoff} -trials ${tckgen_trials} -downsample ${tckgen_downsample} -seed_dynamic ${odfWM} -max_attempts_per_seed ${tckgen_max_attempts_per_seed} -output_seeds ${out} -act ${ftt} -backtrack -crop_at_gmwmi -samples ${tckgen_samples} -power ${tckgen_power} -fslgrad ${mbvec} ${mbval} -nthreads ${threads} ${odfWM} ${tck}
fi

# Elapsed time
# ------------
elapsedtime=$(($(date +%s) - ${startingtime}))
printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
echo "${elapsedtime} Whole_Brain_Tractography" >> ${et}
