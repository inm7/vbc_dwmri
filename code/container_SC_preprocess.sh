#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
# threads=${threads1}

# Path setting
# ------------
wp=$(pwd)
tmp=${tp}/${grp}/${sbj}/temp
seg=${tmp}/aseg.auto_noCCseg.nii.gz
parcseg=${tmp}/aparc.a2009s+aseg.nii.gz

t1=${sp}/${grp}/${sbj}/anat/${sbj}_T1w.nii.gz
dwi=${sp}/${grp}/${sbj}/dwi/${sbj}_dwi.nii.gz
dwi_json=${sp}/${grp}/${sbj}/dwi/${sbj}_dwi.json
bval=${sp}/${grp}/${sbj}/dwi/${sbj}_dwi.bval
bvec=${sp}/${grp}/${sbj}/dwi/${sbj}_dwi.bvec

mc_bval=${tp}/${grp}/${sbj}/mc_bval.dat
mc_bvec=${tp}/${grp}/${sbj}/mc_bvec.dat
ctx=${tp}/${grp}/${sbj}/fs_t1_ctx_mask_to_dwi.nii.gz
sub=${tp}/${grp}/${sbj}/fs_t1_subctx_mask_to_dwi.nii.gz
csf=${tp}/${grp}/${sbj}/fs_t1_csf_mask_to_dwi.nii.gz
wm=${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
wmneck=${tp}/${grp}/${sbj}/fs_t1_neck_wm_mask_to_dwi.nii.gz
gmneck=${tp}/${grp}/${sbj}/fs_t1_neck_gm_mask_to_dwi.nii.gz
ftt=${tp}/${grp}/${sbj}/5tt.nii.gz
ftt_w_neck=${tp}/${grp}/${sbj}/5tt_w_neck.nii.gz

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

# Target folder check
# -------------------
if [[ -d ${tp}/${grp}/${sbj} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Target folder exists, so the process will overwrite the files in the target folder.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Create a target folder.\n"
	mkdir -p ${tp}/${grp}/${sbj}
fi

# Temporary folder check
# ----------------------
if [[ -d ${tmp} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Temporary folder exists, so the process will overwrite the files in the target folder.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Create a temporary folder.\n"
	mkdir -p ${tmp}
fi

# Start the SC preprocessing
# --------------------------
startingtime=$(date +%s)
et=${tp}/${grp}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC preprocessing with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

# Check T1-weighted image
# -----------------------
if [[ -f ${t1} ]]; then
	printf "${GRN}[T1-weighted]${RED} ID: ${grp}${sbj}${NCR} - Check file: ${t1}\n"
else
	printf "${RED}[T1-weighted]${RED} ID: ${grp}${sbj}${NCR} - There is not T1-weighted image!!! ${t1}\n"
	exit 1
fi

# Check Diffusion-weighted images
# -------------------------------
if [[ -f ${dwi} ]]; then
	printf "${GRN}[Diffusion-weighted]${RED} ID: ${grp}${sbj}${NCR} - Check file: ${dwi}\n"
else
	printf "${RED}[Diffusion-weighted]${RED} ID: ${grp}${sbj}${NCR} - There is not Diffusion-weighted image!!!\n"
	exit 1
fi

# Check a json file of DWIs
# -------------------------
if [[ -f ${dwi_json} ]]; then
	printf "${GRN}[Diffusion-weighted]${RED} ID: ${grp}${sbj}${NCR} - Check file: ${dwi_json}\n"
	printf "${GRN}[Diffusion-weighted]${RED} ID: ${grp}${sbj}${NCR} - The option 'pe_json' has been set as 'json'.\n"
	pe_json=json
else
	printf "${GRN}[Diffusion-weighted]${RED} ID: ${grp}${sbj}${NCR} - There is not a json file for diffusion-weighted image!!!\n"
	printf "${GRN}[Diffusion-weighted]${RED} ID: ${grp}${sbj}${NCR} - The option 'pe_json' has been set as 'none'.\n"
	pe_json=none
fi

# Bias-field correction for T1-weighted image before recon-all
# ------------------------------------------------------------
if [[ -f ${tp}/${grp}/${sbj}/t1w_bc.nii.gz ]]; then
	printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Bias-field correction for T1-weighted image was already performed.\n"
else
	printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Estimate bias-field of T1-weighted image.\n"
	
	# 4-time iterative bias-field corrections, because of the bright occipital lobe by very dark outside of the brain.
	# ----------------------------------------------------------------------------------------------------------------
	N4BiasFieldCorrection -i ${t1} -o [${tp}/${grp}/${sbj}/t1w_bc1.nii.gz,${tp}/${grp}/${sbj}/t1_bf1.nii.gz]
	N4BiasFieldCorrection -i ${tp}/${grp}/${sbj}/t1w_bc1.nii.gz -o [${tp}/${grp}/${sbj}/t1w_bc2.nii.gz,${tp}/${grp}/${sbj}/t1_bf2.nii.gz]
	N4BiasFieldCorrection -i ${tp}/${grp}/${sbj}/t1w_bc2.nii.gz -o [${tp}/${grp}/${sbj}/t1w_bc3.nii.gz,${tp}/${grp}/${sbj}/t1_bf3.nii.gz]
	N4BiasFieldCorrection -i ${tp}/${grp}/${sbj}/t1w_bc3.nii.gz -o [${tp}/${grp}/${sbj}/t1w_bc4.nii.gz,${tp}/${grp}/${sbj}/t1_bf4.nii.gz]
	
	rm ${tp}/${grp}/${sbj}/t1w_bc1.nii.gz
	rm ${tp}/${grp}/${sbj}/t1w_bc2.nii.gz
	rm ${tp}/${grp}/${sbj}/t1w_bc3.nii.gz
	rm ${tp}/${grp}/${sbj}/t1w_bc4.nii.gz

	if [[ -f ${tp}/${grp}/${sbj}/t1w_bc.nii.gz ]]; then
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/t1w_bc.nii.gz has been saved.\n"
	else
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/t1w_bc.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} N4BiasFieldCorrection" >> ${et}
fi

# Check a subject directory for Freesurfing
# -----------------------------------------
if [[ -d ${fp}/${grp}_${sbj}/mri/orig ]]; then
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - The subject directory exists.\n"
else
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Make a subject directory.\n"
	mkdir -p ${fp}/${grp}_${sbj}/mri/orig
fi
if [[ -f ${fp}/${grp}_${sbj}/mri/orig/001.mgz ]]; then
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - The T1-weighted image exists in the subject directory.\n"
else
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Convert T1-weighted image to mgz.\n"
	mri_convert ${tp}/${grp}/${sbj}/t1w_bc.nii.gz ${fp}/${grp}_${sbj}/mri/orig/001.mgz
fi

# Check recon-all by Freesurfer
# -----------------------------
if [[ -f ${fp}/${grp}_${sbj}/scripts/recon-all.done ]]; then
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Freesurfer already preprocessed!!!\n"
else
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Start recon-all.\n"
	recon-all -subjid ${grp}_${sbj} -all -noappend -no-isrunning -parallel -openmp ${threads} -sd ${fp}
	if [[ -f ${fp}/${grp}_${sbj}/scripts/recon-all.done ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${fp}/${grp}_${sbj}/scripts/recon-all.done has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${fp}/${grp}_${sbj}/scripts/recon-all.done has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} recon-all" >> ${et}
fi

# Check denoise of DWIs
# ---------------------
if [[ -f ${tp}/${grp}/${sbj}/dwi_denoise.nii.gz ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Denoising of DWIs was already performed!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Start denoise.\n"
	dwidenoise ${dwi} ${tp}/${grp}/${sbj}/dwi_denoise.nii.gz -nthreads ${threads}
	if [[ -f ${tp}/${grp}/${sbj}/dwi_denoise.nii.gz ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_denoise.nii.gz has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_denoise.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} dwidenoise" >> ${et}
fi

# Check degibbs of DWIs
# ---------------------
if [[ -f ${tp}/${grp}/${sbj}/dwi_denoise_degibbs.nii.gz ]]; then
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Degibbsing of DWIs was already performed!!!\n"
else
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Start degibbs.\n"
	mrdegibbs ${dwi} ${tp}/${grp}/${sbj}/dwi_denoise_degibbs.nii.gz -nthreads ${threads}
	if [[ -f ${tp}/${grp}/${sbj}/dwi_denoise_degibbs.nii.gz ]]; then
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_denoise_degibbs.nii.gz has been saved.\n"
	else
		printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_denoise_degibbs.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} mrdegibbs" >> ${et}
fi

# Bias-field correction (DWIs)
# ----------------------------
if [[ -f ${tp}/${grp}/${sbj}/dwi_bc.nii.gz ]]; then
	printf "${GRN}[MRtrix & ANTs]${RED} ID: ${grp}${sbj}${NCR} - Bias-field correction was already performed!!!\n"
else
	printf "${GRN}[MRtrix & ANTs]${RED} ID: ${grp}${sbj}${NCR} - Estimate Bias-field (dwibiascorrect by ANTs).\n"
	dwibiascorrect ants -bias ${tp}/${grp}/${sbj}/dwi_biasfield.nii.gz -fslgrad ${bvec} ${bval} -nthreads ${threads} -force ${tp}/${grp}/${sbj}/dwi_denoise_degibbs.nii.gz ${tp}/${grp}/${sbj}/dwi_bc.nii.gz
	if [[ -f ${tp}/${grp}/${sbj}/dwi_bc.nii.gz ]]; then
		printf "${GRN}[MRtrix & ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_bc.nii.gz has been saved.\n"
	else
		printf "${GRN}[MRtrix & ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_bc.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix & ANTs]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} dwibiascorrect" >> ${et}
fi

# Eddy current correction, head motion correction, and b-vector rotation
# ----------------------------------------------------------------------
if [[ -f ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ]]; then
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${grp}${sbj}${NCR} - DWIs preprocessing by eddy was already processed!!!\n"
else
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${grp}${sbj}${NCR} - Start dwifslpreproc for head motion correction, b-vector rotation and eddy correction.\n"
	case ${pe_json} in
		json )
		dwifslpreproc ${tp}/${grp}/${sbj}/dwi_bc.nii.gz ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz -fslgrad ${bvec} ${bval} -export_grad_fsl ${mc_bvec} ${mc_bval} -nthreads ${threads} -rpe_header -json_import ${dwi_json}
		;;
		none )
		dwifslpreproc ${tp}/${grp}/${sbj}/dwi_bc.nii.gz ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz -fslgrad ${bvec} ${bval} -export_grad_fsl ${mc_bvec} ${mc_bval} -nthreads ${threads} -rpe_none -pe_dir ${pe_dir}
		;;
	esac
	if [[ -f ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ]]; then
		printf "${GRN}[MRtrix & FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz has been saved.\n"
	else
		printf "${GRN}[MRtrix & FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} dwifslpreproc" >> ${et}
fi

# Check dt_recon results
# ----------------------
# if [[ -f ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz ]]; then
# 	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - DWIs preprocessing by dt_recon was already processed!!!\n"
# else
# 	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Start dt_recon.\n"
# 	dt_recon --i ${tp}/${grp}/${sbj}/dwi_bc.nii.gz --no-reg --no-tal --b ${bval} ${bvec} --s ${grp}_${sbj} --o ${tp}/${grp}/${sbj}/dt_recon --sd ${fp}
# 	if [[ -f ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz ]]; then
# 		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz has been saved.\n"
# 	else
# 		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/dt_recon/dwi-ec.nii.gz has not been saved!!\n"
# 		exit 1
# 	fi

# 	# Elapsed time
# 	# ------------
# 	elapsedtime=$(($(date +%s) - ${startingtime}))
# 	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
# 	echo "    ${elapsedtime} dt_recon" >> ${et}
# fi

# Co-registration (from T1WI to averaged DWI)
# -------------------------------------------
if [[ -f ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz ]]; then
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${grp}${sbj}${NCR} - An averaged DWI was already created!!!\n"
else
	printf "${GRN}[MRtrix & FSL]${RED} ID: ${grp}${sbj}${NCR} - Make an averaged DWI.\n"
	dwiextract -shells ${non_zero_shells} -fslgrad ${mc_bvec} ${mc_bval} -nthreads ${threads} ${tp}/${grp}/${sbj}/dwi_bcecmc.nii.gz ${tp}/${grp}/${sbj}/dwi_nonzero_bval.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/dwi_nonzero_bval.nii.gz -Tmean ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz
fi
if [[ -f ${tp}/${grp}/${sbj}/fs_t1_to_dwi.nii.gz ]]; then
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Coregistration from T1WI in Freesurfer to DWI space was already performed!!!\n"
else
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Start coregistration.\n"
	mri_convert ${fp}/${grp}_${sbj}/mri/nu.mgz ${tmp}/fs_t1.nii.gz
	fslreorient2std ${tmp}/fs_t1.nii.gz ${tmp}/fs_t1.nii.gz
	flirt -in ${tmp}/fs_t1.nii.gz -ref ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -out ${tp}/${grp}/${sbj}/fs_t1_to_dwi.nii.gz -omat ${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat -dof ${coreg_flirt_dof} -cost ${coreg_flirt_cost} -searchcost mutualinfo
	if [[ -f ${tp}/${grp}/${sbj}/fs_t1_to_dwi.nii.gz ]]; then
		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/fs_t1_to_dwi.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/fs_t1_to_dwi.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Co-registration" >> ${et}
fi

# Registration from MNI space to DWI space
# ----------------------------------------
if [[ -f ${tp}/${grp}/${sbj}/mni_to_dwi.nii.gz ]]; then
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Registration from MNI to DWI space was already performed!!!\n"
else
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Start registration from MNI to T1WI space.\n"
	flirt -in ${mni}/MNI152_T1_1mm.nii.gz -ref ${tmp}/fs_t1.nii.gz -out ${tp}/${grp}/${sbj}/mni_to_fs_t1_flirt.nii.gz -omat ${tp}/${grp}/${sbj}/mni_to_fs_t1_flirt.mat -dof ${reg_flirt_dof} -cost ${reg_flirt_cost}
	fnirt --ref=${tmp}/fs_t1.nii.gz --in=${tp}/${grp}/${sbj}/mni_to_fs_t1_flirt.nii.gz --iout=${tp}/${grp}/${sbj}/mni_to_fs_t1.nii.gz --cout=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --interp=${reg_fnirt_interp}
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Start registration from MNI to DWI space.\n"
	applywarp -i ${tp}/${grp}/${sbj}/mni_to_fs_t1.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${tp}/${grp}/${sbj}/mni_to_dwi.nii.gz --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	if [[ -f ${tp}/${grp}/${sbj}/mni_to_dwi.nii.gz ]]; then
		printf "${GRN}[FSL Non-linear registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/mni_to_dwi.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Non-linear registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${grp}/${sbj}/mni_to_dwi.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Non-linear registration" >> ${et}
fi

# Make a cortical mask (Destrieux; aparc.a2009s)
# ----------------------------------------------
if [[ -f ${csf} ]]; then
	printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - A cortical mask of Destrieux in Freesurfer exists!!!\n"
else
	printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - Make a cortical mask of Destrieux in Freesurfer.\n"

	# Cortical gray-matter mask
	# -------------------------
	mri_convert ${fp}/${grp}_${sbj}/mri/aparc.a2009s+aseg.mgz ${parcseg}
	fslmaths ${parcseg} -thr 11101 -uthr 11175 -bin ${tmp}/temp_LH_mask.nii.gz
	fslmaths ${parcseg} -thr 12101 -uthr 12175 -bin ${tmp}/temp_RH_mask.nii.gz
	cp ${tmp}/temp_LH_mask.nii.gz ${tmp}/temp_BH_mask.nii.gz
	fslmaths ${tmp}/temp_LH_mask.nii.gz -add ${tmp}/temp_RH_mask.nii.gz -bin ${tmp}/temp_BH_mask.nii.gz
	fslreorient2std ${tmp}/temp_BH_mask.nii.gz ${tmp}/fs_t1_ctx_mask.nii.gz
	applywarp -i ${tmp}/fs_t1_ctx_mask.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${ctx} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${ctx} -thr 0.5 -bin ${ctx}
	if [[ -f ${ctx} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${ctx} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${ctx} has not been saved!!\n"
		exit 1
	fi

	# Cerebellum
	# ----------
	mri_convert ${fp}/${grp}_${sbj}/mri/aseg.auto_noCCseg.mgz ${seg}
	for k in 8 47
	do
		fslmaths ${seg} -thr ${k} -uthr ${k} -bin ${tmp}/temp_mask1.nii.gz
		if [[ ${k} = 8 ]]; then
			cp ${tmp}/temp_mask1.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_mask1.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_LH_mask.nii.gz -add ${tmp}/temp_RH_mask.nii.gz -bin ${tmp}/temp_mask.nii.gz
	fslreorient2std ${tmp}/temp_mask.nii.gz ${tmp}/temp_mask.nii.gz
	applywarp -i ${tmp}/temp_mask.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${gmneck} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${gmneck} -thr 0.5 -bin ${gmneck}
	if [[ -f ${gmneck} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${gmneck} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${gmneck} has not been saved!!\n"
		exit 1
	fi

	# White-matter
	# ------------
	fslmaths ${parcseg} -thr 2 -uthr 2 -bin ${tmp}/temp_WM_LH_mask.nii.gz
	fslmaths ${parcseg} -thr 41 -uthr 41 -bin ${tmp}/temp_WM_RH_mask.nii.gz
	fslmaths ${parcseg} -thr 251 -uthr 255 -bin ${tmp}/temp_WM_CC_mask.nii.gz
	fslmaths ${parcseg} -thr 85 -uthr 85 -bin ${tmp}/temp_WM_OC_mask.nii.gz
	fslmaths ${tmp}/temp_WM_LH_mask.nii.gz -add ${tmp}/temp_WM_RH_mask.nii.gz -add ${tmp}/temp_WM_CC_mask.nii.gz -add ${tmp}/temp_WM_OC_mask.nii.gz -bin ${tmp}/fs_t1_wm_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_wm_mask.nii.gz ${tmp}/fs_t1_wm_mask.nii.gz
	applywarp -i ${tmp}/fs_t1_wm_mask.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${wm} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${wm} -thr 0.5 -bin ${wm}
	if [[ -f ${wm} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${wm} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${wm} has not been saved!!\n"
		exit 1
	fi

	# White-matter with a neck
	# ------------------------
	for k in 7 16 28 46 60
	do
		fslmaths ${seg} -thr ${k} -uthr ${k} -bin ${tmp}/temp_mask1.nii.gz
		if [[ ${k} = 7 ]]; then
			cp ${tmp}/temp_mask1.nii.gz ${tmp}/temp_mask.nii.gz
		else
			fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_mask1.nii.gz ${tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${tmp}/temp_mask.nii.gz -bin -add ${tmp}/temp_WM_LH_mask.nii.gz -add ${tmp}/temp_WM_RH_mask.nii.gz -add ${tmp}/temp_WM_CC_mask.nii.gz -add ${tmp}/temp_WM_OC_mask.nii.gz -bin ${tmp}/temp_mask.nii.gz
	fslreorient2std ${tmp}/temp_mask.nii.gz ${tmp}/temp_mask.nii.gz
	applywarp -i ${tmp}/temp_mask.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${wmneck} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${wmneck} -thr 0.5 -bin ${wmneck}
	if [[ -f ${wmneck} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${wmneck} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${wmneck} has not been saved!!\n"
		exit 1
	fi

	# Subcortical areas
	# -----------------
	for i in 10 11 12 13 17 18 26 28 49 50 51 52 53 54 58 60
	do
		fslmaths ${parcseg} -thr ${i} -uthr ${i} -bin ${tmp}/temp_subctx_${i}_mask.nii.gz
	done
	cp ${tmp}/temp_subctx_10_mask.nii.gz ${tmp}/fs_t1_subctx_mask.nii.gz
	for i in 11 12 13 17 18 26 28 49 50 51 52 53 54 58 60
	do
		fslmaths ${tmp}/fs_t1_subctx_mask.nii.gz -add ${tmp}/temp_subctx_${i}_mask.nii.gz ${tmp}/fs_t1_subctx_mask.nii.gz
	done
	fslmaths ${tmp}/fs_t1_subctx_mask.nii.gz -bin ${tmp}/fs_t1_subctx_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_subctx_mask.nii.gz ${tmp}/fs_t1_subctx_mask.nii.gz
	applywarp -i ${tmp}/fs_t1_subctx_mask.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${sub} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${sub} -thr 0.5 -bin ${sub}
	if [[ -f ${sub} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${sub} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${sub} has not been saved!!\n"
		exit 1
	fi

	# Cerebrospinal fluid (CSF)
	# -------------------------
	for i in 4 5 14 15 24 43 44
	do
		fslmaths ${parcseg} -thr ${i} -uthr ${i} -bin ${tmp}/temp_csf_${i}_mask.nii.gz
	done
	cp ${tmp}/temp_csf_4_mask.nii.gz ${tmp}/fs_t1_csf_mask.nii.gz
	for i in 5 14 15 24 43 44
	do
		fslmaths ${tmp}/fs_t1_csf_mask.nii.gz -add ${tmp}/temp_csf_${i}_mask.nii.gz ${tmp}/fs_t1_csf_mask.nii.gz
	done
	fslmaths ${tmp}/fs_t1_csf_mask.nii.gz -bin ${tmp}/fs_t1_csf_mask.nii.gz
	fslreorient2std ${tmp}/fs_t1_csf_mask.nii.gz ${tmp}/fs_t1_csf_mask.nii.gz
	applywarp -i ${tmp}/fs_t1_csf_mask.nii.gz -r ${tp}/${grp}/${sbj}/dwi_bcecmc_avg.nii.gz -o ${csf} --premat=${tp}/${grp}/${sbj}/fs_t1_to_dwi.mat
	fslmaths ${csf} -thr 0.5 -bin ${csf}
	if [[ -f ${csf} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${csf} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${csf} has not been saved!!\n"
		exit 1
	fi

	# Clear temporary files
	# ---------------------
	rm ${tmp}/temp_*.nii.gz

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Cortical masks" >> ${et}
fi

# Make 5TT (Five-type tissues)
# ----------------------------
if [[ -f ${ftt_w_neck} ]]; then
	printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - 5TT image exists!!!\n"
else
	printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - Make a 5TT image.\n"
	cp ${csf} ${tmp}/temp.nii.gz
	fslmaths ${tmp}/temp.nii.gz -uthr 0.5 ${tmp}/temp.nii.gz
	fslmerge -t ${ftt} ${ctx} ${sub} ${wm} ${csf} ${tmp}/temp.nii.gz
	fslmerge -t ${tp}/${grp}/${sbj}/5tt_xsub.nii.gz ${ctx} ${tmp}/temp.nii.gz ${wm} ${csf} ${tmp}/temp.nii.gz
	fslmaths ${ctx} -add ${sub} -add ${wm} ${tp}/${grp}/${sbj}/dwi_bcecmc_avg_bet_mask.nii.gz
	rm ${tmp}/temp.nii.gz

	cd ${tp}/${grp}/${sbj}
	fslsplit ${ftt} split -t
	cd ${wp}
	
	fslmaths ${tp}/${grp}/${sbj}/split0000.nii.gz -add ${gmneck} -thr 0.5 -bin ${tp}/${grp}/${sbj}/split0000.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/split0001.nii.gz -sub ${wmneck} -thr 0.5 -bin ${tp}/${grp}/${sbj}/split0001.nii.gz
	fslmaths ${tp}/${grp}/${sbj}/split0002.nii.gz -add ${wmneck} -thr 0.5 -bin ${tp}/${grp}/${sbj}/split0002.nii.gz
	
	fslmaths ${tp}/${grp}/${sbj}/dwi_bcecmc_avg_bet_mask.nii.gz -add ${tp}/${grp}/${sbj}/split0000.nii.gz -add ${tp}/${grp}/${sbj}/split0002.nii.gz -bin ${tp}/${grp}/${sbj}/dwi_bcecmc_avg_bet_mask_w_neck.nii.gz

	fslmaths ${tp}/${grp}/${sbj}/split0000.nii.gz -add ${tp}/${grp}/${sbj}/split0001.nii.gz -bin ${tp}/${grp}/${sbj}/fs_t1_gm_mask_to_dwi.nii.gz
	
	cp ${tp}/${grp}/${sbj}/split0002.nii.gz ${tp}/${grp}/${sbj}/fs_t1_wm_mask_to_dwi.nii.gz
	
	fslmerge -t ${ftt_w_neck} ${tp}/${grp}/${sbj}/split0000.nii.gz ${tp}/${grp}/${sbj}/split0001.nii.gz ${tp}/${grp}/${sbj}/split0002.nii.gz ${tp}/${grp}/${sbj}/split0003.nii.gz ${tp}/${grp}/${sbj}/split0004.nii.gz
	if [[ -f ${ftt_w_neck} ]]; then
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${ftt_w_neck} has been saved.\n"
	else
		printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - ${ftt_w_neck} has not been saved!!\n"
		exit 1
	fi
	rm ${tp}/${grp}/${sbj}/split*.nii.gz
	rm ${seg}

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} 5-tissue type images" >> ${et}
fi

echo "[-] SC preprocessing - $(date)" >> ${et}
