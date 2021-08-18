#!/bin/bash

input=${1}
threads=${2}
sbj=${3}

totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done

# num=${numparc}

# Source path (BIDS)
# ------------------
sp=/mnt_sp

# Target path (BOLD)
# ------------------
tp=${ppfc}/${grp}

# Set file paths
# --------------
t1=${sp}/${grp}/${sbj}/anat/${sbj}_T1w.nii.gz
sliceorder=/opt/sliceorder.txt
epiup=${tp}/${sbj}/epi_sm_upsample.nii.gz
epi_avg=${tp}/${sbj}/epi_sm_upsample_avg.nii.gz
epi_out=${tp}/${sbj}/epi_sm_upsample
tmp=/tmp/${grp}_${sbj}
mc=${tp}/${sbj}/mc.1D
mcdt=${tp}/${sbj}/mcdt.1D
sc_tmp=${ppsc}/${grp}/${sbj}/temp
aseg=${sc_tmp}/aseg.nii.gz
atlt1w=${ppsc}/${sbj}/${atlname}_to_fs_t1_native+subctx.nii.gz
atlepi=${tp}/${sbj}/${atlname}_to_epi_upsample_native+subctx.nii.gz

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

# Transform function for loops
# ----------------------------
Transform()
{
	idx=${1}
	mask1=${tmp}/temp_label${idx}_mask1.nii.gz
	mask2=${tmp}/temp_label${idx}_mask2.nii.gz
	mask3=${tmp}/temp_label${idx}_mask3.nii.gz
	mask4=${tmp}/temp_label${idx}_mask4.nii.gz

	fslmaths ${atlt1w} -thr ${idx} -uthr ${idx} -bin ${mask1}
	wait
	applywarp -i ${mask1} -r ${epi_ref} -o ${mask3} --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat
	wait
	fslmaths ${mask3} -thr 0.5 -uthr 0.5 ${mask4}
	wait
	fslmaths ${mask3} -sub ${mask4} -thr 0.5 -bin -mul ${idx} ${mask3}
	wait
}

# Loop for extrating the first eigenvariate of BOLD in a region
# -------------------------------------------------------------
ExtractEigenvariateBOLD()
{
	idx=${1}
	mask1=${tmp}/temp_${atlname}_label${idx}_mask1.nii.gz

	fslmaths ${atlepi} -thr ${idx} -uthr ${idx} -bin ${mask1}
	wait
	fslmeants -i ${epi_out} -m ${mask1} --eig -o ${tmp}/${atlname}_${idx}_eig.txt
	wait
}

# Format as 'csv'
# ---------------
ConvertCSV()
{
    cat ${tmp}/temp_BOLD.txt | tr -s " " >> ${tmp}/temp.txt
    cat ${tmp}/temp.txt | tr ' ' ',' >> ${tmp}/temp2.txt
    cat ${tmp}/temp2.txt | sed 's/.$//' > ${tmp}/temp3.txt
    mv ${tmp}/temp3.txt ${epi_out}_${atlname}_native_subctx_EigenBOLD.csv
	wait
    rm -f ${tmp}/temp*.txt
	printf "  + ${epi_out}_${atlname}_native_subctx_EigenBOLD.csv has been saved.\n"
}

# Check directories
# -----------------
if [[ -d ${tp}/${sbj} ]]; then
	printf "  + ${tp}/${sbj} exists.\n"
else
	printf "  + Create ${tp}/${sbj}.\n"
	mkdir -p ${tp}/${sbj}
fi
if [[ -d ${tmp} ]]; then
	printf "  + ${tmp} exists.\n"
else
	printf "  + Create ${tmp}.\n"
	mkdir -p ${tmp}
fi

# Start the FC preprocess
# -----------------------
startingtime=$(date +%s)
et=${tp}/${sbj}/FC_preprocess_elapsedtime.txt
echo "[+] Functional preprocessing with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

# Check EPI
# ---------
if [[ -f ${sp}/${grp}/${sbj}/func/${sbj}_task-rest_bold.nii.gz ]]; then
	printf "${GRN}[Functional EPI]${RED} ID: ${grp}${sbj}${NCR} - Check file: ${sp}/${grp}/${sbj}/func/${sbj}_task-rest_bold.nii.gz\n"
else
	printf "${RED}[Functional EPI]${RED} ID: ${grp}${sbj}${NCR} - There is not a functional EPI!!!\n"
	exit 1
fi

# Check slice order
# -----------------
if [[ -f ${sliceorder} ]]; then
	printf "${GRN}[Functional EPI]${RED} ID: ${grp}${sbj}${NCR} - Check file: ${sliceorder}\n"
else
	printf "${RED}[Functional EPI]${RED} ID: ${grp}${sbj}${NCR} - There is not a functional EPI!!!\n"
	exit 1
fi

# Slice timing correction
# -----------------------
if [[ -f ${tp}/${sbj}/epi_s.nii.gz ]]; then
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Slice timing was already performed.\n"
else
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Slice timing correction.\n"
	slicetimer -i ${sp}/${grp}/${sbj}/func/${sbj}_task-rest_bold.nii.gz -o ${tp}/${sbj}/epi_s -r ${TR} --ocustom=${sliceorder}

	if [[ -f ${tp}/${sbj}/epi_s.nii.gz ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_s.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_s.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Slice timing correction" >> ${et}
fi

# Mean volume for a reference image
# ---------------------------------
printf "  + Mean volume for a reference image\n"
if [[ -f ${tp}/${sbj}/epi_sm_mean.nii.gz ]]; then
    printf "  + ${tp}/${sbj}/epi_sm_mean.nii.gz has been checked! Skip averaging EPI for a reference image.\n"
else
	mcflirt -in ${tp}/${sbj}/epi_s.nii.gz -o ${tp}/${sbj}/temp -meanvol -dof 6 -cost normcorr
	fslmaths ${tp}/${sbj}/temp.nii.gz -Tmean ${tp}/${sbj}/epi_sm_mean

	if [[ -f ${tp}/${sbj}/epi_sm_mean.nii.gz ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_sm_mean.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_sm_mean.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Mean volume for a reference image" >> ${et}
fi

# Head motion correction
# ----------------------
printf "  + Head motion correction\n"
if [[ -f ${tp}/${sbj}/epi_sm.nii.gz ]]; then
    printf "  + ${tp}/${sbj}/epi_sm.nii.gz has been checked! Skip averaging EPI for a reference image.\n"
else
	mcflirt -in ${tp}/${sbj}/epi_s.nii.gz -o ${tp}/${sbj}/epi_sm -reffile ${tp}/${sbj}/epi_sm_mean.nii.gz -plots -dof 6 -mats -cost normcorr -stages 3

	if [[ -f ${tp}/${sbj}/epi_sm.nii.gz ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_sm.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_sm.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Head motion correction" >> ${et}
fi

# EPI upsampling 2mm iso-cubic
# ----------------------------
printf "  + EPI upsampling 2mm iso-cubic\n"
if [[ -f ${epiup} ]]; then
    printf "  + ${epiup} has been checked! Skip upsampling.\n"
else
    cd ${tmp}
    fslsplit ${tp}/${sbj}/epi_sm.nii.gz temp_epi_ -t
    cmd="fslmerge -t ${tmp}/merged_upsampled_epi.nii.gz"
    for i in {0..299}; do
    	epinum=$(printf "%04d" ${i})
    	flirt -in ${tmp}/temp_epi_${epinum}.nii.gz -ref ${tmp}/temp_epi_${epinum}.nii.gz -applyisoxfm 2.0 -out ${tmp}/temp_epi_${epinum}_upsample.nii.gz
    	cmd+=" ${tmp}/temp_epi_${epinum}_upsample.nii.gz"
    done
    eval "${cmd}"
    rm -rf ${tmp}/temp_epi_*.nii.gz
    mv ${tmp}/merged_upsampled_epi.nii.gz ${epiup}

	# Intensity normalization
	# -----------------------
	printf "  + Intensity normalization\n"
	fslmaths ${epiup} -inm 10000 ${epiup}

	if [[ -f ${epiup} ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${epiup} has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${epiup} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} EPI upsampling 2mm iso-cubic" >> ${et}
fi

# Detrending with very slow fluctuation (High-pass)
# -------------------------------------------------
printf "  + Detrending with very slow fluctuation (hp=0.5*1000/TR)\n"
if [[ -f ${epi_out}_detrend.nii.gz ]]; then
    printf "  + ${epi_out}_detrend.nii.gz has been checked! Skip upsampling.\n"
else
	fslmaths ${epiup} -Tmean ${epi_avg}
	fslmaths ${epiup} -bptf 226 -1 ${epi_out}_detrend
	fslmaths ${epi_out}_detrend -add ${epi_avg} ${epi_out}_detrend

	if [[ -f ${epi_out}_detrend.nii.gz ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${epi_out}_detrend.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${epi_out}_detrend.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Detrending with very slow fluctuation (High-pass)" >> ${et}
fi

# Mean EPI volume for coregistration to T1
# ----------------------------------------
printf "  + Mean EPI volume for coregistration to T1\n"
if [[ -f ${epi_avg} ]]; then
    printf "  + ${epi_avg} has been checked! Skip upsampling.\n"
else
	fslmaths ${epi_out}_detrend -Tmean ${epi_avg}

	if [[ -f ${epi_avg} ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${epi_avg} has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${epi_avg} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Mean EPI volume for coregistration to T1" >> ${et}
fi

# Preprocessed file
# -----------------
if [[ -f ${epi_out}_detrend.nii.gz ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - ${epi_out}_detrend.nii.gz has been saved (Final oputput).\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - ${epi_out}_detrend.nii.gz has not been saved!!\n"
	exit 1
fi

# Bias field correction (Average EPI)
# -----------------------------------
printf "  + Bias field correction for referencing\n"
if [[ -f ${tp}/${sbj}/epi_avg_bc2.nii.gz ]]; then
    printf "  + ${tp}/${sbj}/epi_avg_bc2.nii.gz has been checked! Skip upsampling.\n"
else
	N4BiasFieldCorrection -i ${epi_avg} -o [${tp}/${sbj}/epi_avg_bc1.nii.gz,${tp}/${sbj}/epi_avg_bf1.nii.gz]
	N4BiasFieldCorrection -i ${tp}/${sbj}/epi_avg_bc1.nii.gz -o [${tp}/${sbj}/epi_avg_bc2.nii.gz,${tp}/${sbj}/epi_avg_bf2.nii.gz]
	epi_ref=${tp}/${sbj}/epi_avg_bc2.nii.gz

	if [[ -f ${tp}/${sbj}/epi_avg_bc2.nii.gz ]]; then
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_avg_bc2.nii.gz has been saved.\n"
	else
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_avg_bc2.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Bias field correction (Average EPI)" >> ${et}
fi

# Check a subject directory for structural process
# ------------------------------------------------
if [[ -d ${ppsc}/${grp}/${sbj} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - The subject directory (${ppsc}/${grp}/${sbj}) exists.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Make a subject directory.\n"
	mkdir -p ${ppsc}/${grp}/${sbj}
fi
if [[ -d ${sc_tmp} ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - The subject directory (${sc_tmp}) exists.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Make a subject directory.\n"
	mkdir -p ${sc_tmp}
fi

# Check a subject directory for Freesurfing
# -----------------------------------------
if [[ -d ${fp}/${grp}_${sbj}/mri/orig ]]; then
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - The subject directory exists.\n"
else
	printf "${GRN}[Unix]${RED} ID: ${grp}${sbj}${NCR} - Make a subject directory.\n"
	mkdir -p ${fp}/${grp}_${sbj}/mri/orig
fi

# Check T1WI for freesurfing, if not, do the AC-PC alignment and the bias-field correction for T1WI
# -------------------------------------------------------------------------------------------------
if [[ -f ${fp}/${grp}_${sbj}/mri/orig/001.mgz ]]; then
	printf "${GRN}[ANTs, Freesurfer, and FSL]${RED} ID: ${grp}${sbj}${NCR} - The T1-weighted image exists in the subject directory for recon-all.\n"
else

	# Bias-field correction for T1-weighted image before recon-all
	# ------------------------------------------------------------
	if [[ -f ${ppsc}/${grp}/${sbj}/t1w_bc.nii.gz ]]; then
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Bias-field correction for T1-weighted image was already performed.\n"
	else
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Estimate bias-field of T1-weighted image.\n"
		
		# 4-time iterative bias-field corrections, because of the bright occipital lobe by very dark outside of the brain.
		# ----------------------------------------------------------------------------------------------------------------
		N4BiasFieldCorrection -i ${t1} -o [${ppsc}/${grp}/${sbj}/t1w_bc1.nii.gz,${ppsc}/${grp}/${sbj}/t1_bf1.nii.gz]
		N4BiasFieldCorrection -i ${ppsc}/${grp}/${sbj}/t1w_bc1.nii.gz -o [${ppsc}/${grp}/${sbj}/t1w_bc2.nii.gz,${ppsc}/${grp}/${sbj}/t1_bf2.nii.gz]
		N4BiasFieldCorrection -i ${ppsc}/${grp}/${sbj}/t1w_bc2.nii.gz -o [${ppsc}/${grp}/${sbj}/t1w_bc3.nii.gz,${ppsc}/${grp}/${sbj}/t1_bf3.nii.gz]
		N4BiasFieldCorrection -i ${ppsc}/${grp}/${sbj}/t1w_bc3.nii.gz -o [${ppsc}/${grp}/${sbj}/t1w_bc.nii.gz,${ppsc}/${grp}/${sbj}/t1_bf4.nii.gz]
		
		rm -f ${ppsc}/${grp}/${sbj}/t1w_bc1.nii.gz
		rm -f ${ppsc}/${grp}/${sbj}/t1w_bc2.nii.gz
		rm -f ${ppsc}/${grp}/${sbj}/t1w_bc3.nii.gz

		if [[ -f ${ppsc}/${grp}/${sbj}/t1w_bc.nii.gz ]]; then
			printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${ppsc}/${grp}/${sbj}/t1w_bc.nii.gz has been saved.\n"
		else
			printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - ${ppsc}/${grp}/${sbj}/t1w_bc.nii.gz has not been saved!!\n"
			exit 1
		fi

		# Elapsed time
		# ------------
		elapsedtime=$(($(date +%s) - ${startingtime}))
		printf "${GRN}[ANTs]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
		echo "    ${elapsedtime} N4BiasFieldCorrection" >> ${et}
	fi

	# AC-PC alignment
	# ---------------
	if [[ -f ${sc_tmp}/t1w_acpc.nii.gz ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - AC-PC aligned T1-weighted image exists!!!l.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - AC-PC align and convert T1-weighted image to mgz.\n"
		fslreorient2std ${ppsc}/${grp}/${sbj}/t1w_bc.nii.gz ${sc_tmp}/t1w_bc_reori.nii.gz
		robustfov -i ${sc_tmp}/t1w_bc_reori.nii.gz -b 170 -m ${sc_tmp}/acpc_roi2full.mat -r ${sc_tmp}/acpc_robustroi.nii.gz
		flirt -interp spline -in ${sc_tmp}/acpc_robustroi.nii.gz -ref ${mni} -omat ${sc_tmp}/acpc_roi2std.mat -out ${sc_tmp}/acpc_roi2std.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30
		convert_xfm -omat ${sc_tmp}/acpc_full2roi.mat -inverse ${sc_tmp}/acpc_roi2full.mat
		convert_xfm -omat ${sc_tmp}/acpc_full2std.mat -concat ${sc_tmp}/acpc_roi2std.mat ${sc_tmp}/acpc_full2roi.mat
		aff2rigid ${sc_tmp}/acpc_full2std.mat ${sc_tmp}/acpc.mat
		applywarp --rel --interp=spline -i ${sc_tmp}/t1w_bc_reori.nii.gz -r ${mni} --premat=${sc_tmp}/acpc.mat -o ${sc_tmp}/t1w_acpc.nii.gz
		if [[ -f ${sc_tmp}/t1w_acpc.nii.gz ]]; then
			printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/t1w_acpc.nii.gz has been saved.\n"
		else
			printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/t1w_acpc.nii.gz has not been saved!!\n"
			exit 1
		fi

		# Elapsed time
		# ------------
		elapsedtime=$(($(date +%s) - ${startingtime}))
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
		echo "    ${elapsedtime} AC-PC alignment" >> ${et}
	fi

	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Convert T1-weighted image to mgz.\n"
	mri_convert ${sc_tmp}/t1w_acpc.nii.gz ${fp}/${grp}_${sbj}/mri/orig/001.mgz

	if [[ -f ${fp}/${grp}_${sbj}/mri/orig/001.mgz ]]; then
		printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - ${fp}/${grp}_${sbj}/mri/orig/001.mgz has been saved.\n"
	else
		printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - ${fp}/${grp}_${sbj}/mri/orig/001.mgz has not been saved!!\n"
		exit 1
	fi
fi

# Check recon-all by Freesurfer
# -----------------------------
if [[ -f ${fp}/${grp}_${sbj}/scripts/recon-all.done ]]; then
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Freesurfer already preprocessed!!!\n"
else
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Start recon-all.\n"
	recon-all -subjid ${grp}_${sbj} -all -noappend -no-isrunning -parallel -openmp ${threads} -sd ${fp}
	if [[ -f ${fp}/${grp}_${sbj}/scripts/recon-all.done ]]; then
		printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - ${fp}/${grp}_${sbj}/scripts/recon-all.done has been saved.\n"
	else
		printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - ${fp}/${grp}_${sbj}/scripts/recon-all.done has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} recon-all" >> ${et}
fi

# Create brain masks on T1 space (Freesurfer output)
# --------------------------------------------------
if [[ -f ${sc_tmp}/fs_t1_gmwm_mask.nii.gz ]]; then
	printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - Brain masks on T1 space (Freesurfer output) exist!!!\n"
else
	printf "${GRN}[FSL & Image processing]${RED} ID: ${grp}${sbj}${NCR} - Create brain masks on T1 space (Freesurfer output).\n"
	mri_convert ${fp}/${grp}_${sbj}/mri/aseg.mgz ${aseg}

	# White-matter mask with a neck
	# -----------------------------
	for i in 2 7 16 28 41 46 60 77 251 252 253 254 255
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${sc_tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 2 ]]; then
			cp ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		else
			fslmaths ${sc_tmp}/temp_mask.nii.gz -add ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${sc_tmp}/temp_mask.nii.gz -bin ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz
	fslreorient2std ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz
	if [[ -f ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# White-matter
	# ------------
	fslmaths ${sc_tmp}/temp_roi_2.nii.gz -add ${sc_tmp}/temp_roi_41.nii.gz -add ${sc_tmp}/temp_roi_77.nii.gz -add ${sc_tmp}/temp_roi_251.nii.gz -add ${sc_tmp}/temp_roi_252.nii.gz -add ${sc_tmp}/temp_roi_253.nii.gz -add ${sc_tmp}/temp_roi_254.nii.gz -add ${sc_tmp}/temp_roi_255.nii.gz -bin ${sc_tmp}/fs_t1_wm_mask.nii.gz
	fslreorient2std ${sc_tmp}/fs_t1_wm_mask.nii.gz ${sc_tmp}/fs_t1_wm_mask.nii.gz
	if [[ -f ${sc_tmp}/fs_t1_wm_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_wm_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_wm_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Cortical mask
	# -------------
	for i in 3 8 42 47
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${sc_tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 3 ]]; then
			cp ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		else
			fslmaths ${sc_tmp}/temp_mask.nii.gz -add ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${sc_tmp}/temp_mask.nii.gz -bin ${sc_tmp}/fs_t1_ctx_mask.nii.gz
	fslreorient2std ${sc_tmp}/fs_t1_ctx_mask.nii.gz ${sc_tmp}/fs_t1_ctx_mask.nii.gz
	if [[ -f ${sc_tmp}/fs_t1_ctx_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_ctx_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_ctx_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Subcortical mask
	# ----------------
	for i in 10 11 12 13 17 18 26 49 50 51 52 53 54 58
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${sc_tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 10 ]]; then
			cp ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		else
			fslmaths ${sc_tmp}/temp_mask.nii.gz -add ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${sc_tmp}/temp_mask.nii.gz -bin ${sc_tmp}/fs_t1_subctx_mask.nii.gz
	fslreorient2std ${sc_tmp}/fs_t1_subctx_mask.nii.gz ${sc_tmp}/fs_t1_subctx_mask.nii.gz
	if [[ -f ${sc_tmp}/fs_t1_subctx_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_subctx_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_subctx_mask.nii.gz has not been saved!!\n"
		exit 1
	fi
	
	# Cerebrospinal fluid (CSF)
	# -------------------------
	for i in 4 5 14 15 24 31 43 44 63
	do
		fslmaths ${aseg} -thr ${i} -uthr ${i} -bin ${sc_tmp}/temp_roi_${i}.nii.gz
		if [[ ${i} = 4 ]]; then
			cp ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		else
			fslmaths ${sc_tmp}/temp_mask.nii.gz -add ${sc_tmp}/temp_roi_${i}.nii.gz ${sc_tmp}/temp_mask.nii.gz
		fi
	done
	fslmaths ${sc_tmp}/temp_mask.nii.gz -bin ${sc_tmp}/fs_t1_csf_mask.nii.gz
	fslreorient2std ${sc_tmp}/fs_t1_csf_mask.nii.gz ${sc_tmp}/fs_t1_csf_mask.nii.gz
	if [[ -f ${sc_tmp}/fs_t1_csf_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_csf_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_csf_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Brain-tissue
	# ------------
	fslmaths ${sc_tmp}/fs_t1_ctx_mask.nii.gz -add ${sc_tmp}/fs_t1_subctx_mask.nii.gz -bin ${sc_tmp}/fs_t1_neck_gm_mask.nii.gz
	fslmaths ${sc_tmp}/fs_t1_neck_gm_mask.nii.gz -add ${sc_tmp}/fs_t1_neck_wm_mask.nii.gz -bin ${sc_tmp}/fs_t1_gmwm_mask.nii.gz
	if [[ -f ${sc_tmp}/fs_t1_gmwm_mask.nii.gz ]]; then
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_gmwm_mask.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Tissue masks]${RED} ID: ${grp}${sbj}${NCR} - ${sc_tmp}/fs_t1_gmwm_mask.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Creating tissue masks" >> ${et}
fi

# Brain tissue mask on T1 (Freesurfer)
# ------------------------------------
if [[ -f ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz ]]; then
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Coregistration from T1WI in Freesurfer to DWI space was already performed!!!\n"
else
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Start coregistration.\n"
	mri_convert ${fp}/${grp}_${sbj}/mri/nu.mgz ${sc_tmp}/fs_t1.nii.gz
	fslreorient2std ${sc_tmp}/fs_t1.nii.gz ${sc_tmp}/fs_t1.nii.gz

	# Dilate the brain-tissue mask
	# ----------------------------
	mri_binarize --i ${sc_tmp}/fs_t1_gmwm_mask.nii.gz --min 0.5 --max 1.5 --dilate 20 --o ${sc_tmp}/fs_t1_gmwm_mask_dilate.nii.gz
	fslmaths ${sc_tmp}/fs_t1.nii.gz -mas ${sc_tmp}/fs_t1_gmwm_mask_dilate.nii.gz ${ppsc}/${grp}/${sbj}/fs_t1.nii.gz
	fslmaths ${sc_tmp}/fs_t1.nii.gz -mas ${sc_tmp}/fs_t1_gmwm_mask.nii.gz ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz

	if [[ -f ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz ]]; then
		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Brain-tissue mask" >> ${et}
fi

# Coregistration from T1 (1mm freesurfered) to EPI (upsampled)
# ------------------------------------------------------------
# t1_ctx=${ppsc}/${grp}/${sbj}/temp/fs_t1_ctx_mask.nii.gz
# t1_subctx=${ppsc}/${grp}/${sbj}/temp/fs_t1_subctx_mask.nii.gz
# t1_wm=${ppsc}/${grp}/${sbj}/temp/fs_t1_wm_mask.nii.gz
# t1_csf=${ppsc}/${grp}/${sbj}/temp/fs_t1_csf_mask.nii.gz

# Co-registration between T1-weighted image and EPI (rs-fMRI)
# -----------------------------------------------------------
printf "  + Co-registration between T1-weighted image and EPI (rs-fMRI)\n"
if [[ -f ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat ]]; then
    printf "  + ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat has been checked! Skip co-registration.\n"
else
    flirt -in ${epi_ref} -ref ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz -out ${tp}/${sbj}/epi_to_fs_t1_affine.nii.gz -omat ${tp}/${sbj}/epi_to_fs_t1_affine.mat -dof 6 -cost mutualinfo
    convert_xfm -omat ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat -inverse ${tp}/${sbj}/epi_to_fs_t1_affine.mat
    applywarp -i ${ppsc}/${grp}/${sbj}/fs_t1.nii.gz -r ${epi_ref} -o ${tp}/${sbj}/fs_t1_to_epi.nii.gz --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat
    applywarp -i ${ppsc}/${grp}/${sbj}/fs_t1_brain.nii.gz -r ${epi_ref} -o ${tp}/${sbj}/fs_t1_brain_to_epi.nii.gz --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat

	if [[ -f ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat ]]; then
		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat has been saved.\n"
	else
		printf "${GRN}[FSL Co-registration]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Co-registration between R1-weighted image and EPI (rs-fMRI)" >> ${et}
fi

# Transform tissue masks in T1 to the upsampled EPI
# -------------------------------------------------
printf "  + Transform tissue masks in T1 to the upsampled EPI\n"
if [[ -f ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample.nii.gz ]]; then
    printf "  + ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample.nii.gz has been checked! Skip transformations of tissue masks.\n"
else
	for tissue in ctx subctx wm csf; do
		applywarp -i ${ppsc}/${grp}/${sbj}/temp/fs_t1_${tissue}_mask.nii.gz -r ${epi_ref} -o ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat
		fslmaths ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample -thr 0.5 -bin ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample
	done
	fslmaths ${tp}/${sbj}/fs_t1_wm_mask_to_epi_upsample -add ${tp}/${sbj}/fs_t1_csf_mask_to_epi_upsample -add ${tp}/${sbj}/fs_t1_ctx_mask_to_epi_upsample -add ${tp}/${sbj}/fs_t1_subctx_mask_to_epi_upsample -bin ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample

	if [[ -f ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample.nii.gz ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample.nii.gz has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample.nii.gz has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Transform tissue masks in T1 to the upsampled EPI" >> ${et}
fi

# Prepare regressors
# ------------------
printf "  + Prepare regressors\n"
if [[ -f ${tp}/${sbj}/regressor_global.txt ]]; then
    printf "  + ${tp}/${sbj}/regressor_global.txt has been checked! Skip transformations of tissue masks.\n"
else
	# Motion regressors
	# -----------------
	rm -rf ${tp}/${sbj}/mc*.txt
	cp ${tp}/${sbj}/epi_sm.par ${mc}

	# Calculate derivatives of 6 motions
	# ----------------------------------
	printf "  + Calculate derivatives of 6 motions\n"
	1d_tool.py -infile ${mc} -derivative -write ${mcdt}

	# 6 head motions
	# --------------
	awk '{print $1}' ${mc} > ${tp}/${sbj}/mc1.1D
	awk '{print $2}' ${mc} > ${tp}/${sbj}/mc2.1D
	awk '{print $3}' ${mc} > ${tp}/${sbj}/mc3.1D
	awk '{print $4}' ${mc} > ${tp}/${sbj}/mc4.1D
	awk '{print $5}' ${mc} > ${tp}/${sbj}/mc5.1D
	awk '{print $6}' ${mc} > ${tp}/${sbj}/mc6.1D

	# Derivatives
	# -----------
	awk '{print $1}' ${mcdt} > ${tp}/${sbj}/mcdt1.1D
	awk '{print $2}' ${mcdt} > ${tp}/${sbj}/mcdt2.1D
	awk '{print $3}' ${mcdt} > ${tp}/${sbj}/mcdt3.1D
	awk '{print $4}' ${mcdt} > ${tp}/${sbj}/mcdt4.1D
	awk '{print $5}' ${mcdt} > ${tp}/${sbj}/mcdt5.1D
	awk '{print $6}' ${mcdt} > ${tp}/${sbj}/mcdt6.1D

	# Calculate Friston24 (Friston et al., 1996. Movement-related effects in fMRI time-series)
	# ----------------------------------------------------------------------------------------
	for i in {1..6}
	do
		# Calculate the squared derivatives
		# ---------------------------------
		1deval -a ${tp}/${sbj}/mc${i}.1D -expr 'a*a' > ${tp}/${sbj}/mcsqr${i}.1D

		# Calculate one-step previous points of the 6 motions (AR1) and squared them
		# --------------------------------------------------------------------------
		1deval -a ${tp}/${sbj}/mc${i}.1D -b ${tp}/${sbj}/mcdt${i}.1D -expr 'a-b' > ${tp}/${sbj}/mcar${i}.1D
		1deval -a ${tp}/${sbj}/mcar${i}.1D -expr 'a*a' > ${tp}/${sbj}/mcarsqr${i}.1D
	done

	HMlist=""
	for label in mc mcar mcsqr mcarsqr
	do 
		for i in {1..6}
		do
			HMlist="${HMlist} ${tp}/${sbj}/${label}${i}.1D"
		done
	done
	echo ${HMlist} >> ${tp}/${sbj}/HMlist.1D
	paste ${HMlist} >> ${tp}/${sbj}/Friston-24.txt

	for tissue in ctx subctx wm csf global; do
		fslmeants -i ${epiup} -m ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample.nii.gz -o ${tp}/${sbj}/regressor_${tissue}.txt
	done

	paste ${tp}/${sbj}/regressor_wm.txt ${tp}/${sbj}/regressor_csf.txt ${tp}/${sbj}/Friston-24.txt >> ${tp}/${sbj}/regressors_wm_csf_Friston.txt
	paste ${tp}/${sbj}/regressor_wm.txt ${tp}/${sbj}/regressor_csf.txt ${tp}/${sbj}/regressor_global.txt ${tp}/${sbj}/Friston-24.txt >> ${tp}/${sbj}/regressors_wm_csf_global_Friston.txt
	paste ${tp}/${sbj}/regressor_wm.txt ${tp}/${sbj}/regressor_csf.txt ${tp}/${sbj}/regressor_ctx.txt ${tp}/${sbj}/regressor_subctx.txt ${tp}/${sbj}/Friston-24.txt >> ${tp}/${sbj}/regressors_wm_csf_ctx_subctx_Friston.txt

	if [[ -f ${tp}/${sbj}/regressor_global.txt ]]; then
		printf "${GRN}[AFNI and Unix]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/regressor_global.txt has been saved.\n"
	else
		printf "${GRN}[AFNI and Unix]${RED} ID: ${grp}${sbj}${NCR} - ${tp}/${sbj}/regressor_global.txt has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[AFNI and Unix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Nuisance regressors" >> ${et}
fi

# Atlas derived by a classifier (gcs)
# -----------------------------------
if [[ -f ${atlt1w} ]]; then
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atlt1w} has been checked!!!\n"
else
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Transform the target atlas.\n"
	printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Parcellation scheme is ${parcellation}.\n"

	case ${parcellation} in

	# Atlas on the native T1 (Freesurfer)
	# -----------------------------------
	native )
		printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Atlas: ${atlt1w}.\n"
		mris_ca_label -sdir ${fp} -l ${fp}/${grp}_${sbj}/label/lh.cortex.label -seed 1234 ${grp}_${sbj} lh ${fp}/${grp}_${sbj}/surf/lh.sphere.reg ${ap}/${gcs_lh} ${fp}/${grp}_${sbj}/label/lh.${atlname}.annot
		mris_ca_label -sdir ${fp} -l ${fp}/${grp}_${sbj}/label/rh.cortex.label -seed 1234 ${grp}_${sbj} rh ${fp}/${grp}_${sbj}/surf/rh.sphere.reg ${ap}/${gcs_rh} ${fp}/${grp}_${sbj}/label/rh.${atlname}.annot
		TMP_SUBJECTS_DIR=${SUBJECTS_DIR}
		export SUBJECTS_DIR=${fp}
		mri_aparc2aseg --s ${grp}_${sbj} --o ${tmp}/temp_atlas.nii.gz --annot ${atlname}
		export SUBJECTS_DIR=${TMP_SUBJECTS_DIR}
		
		# Relabeling in ascending order
		# -----------------------------
		fslmaths ${tmp}/temp_atlas.nii.gz -mul 0 ${tmp}/temp.nii.gz
		case ${atlname} in

		# Schaefer 100-Parcel
		# -------------------
		Schaefer2018_100Parcels_17Networks )
			nLabel=0
			for i in {1001..1050} {2001..2050}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Harvard-Oxford 96-Parcel
		# ------------------------
		HarvardOxford_96Parcels )
			nLabel=0
			for i in $(seq 1001 2 1095) $(seq 2002 2 2096)
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		# Kleist 98-Parcel
		# ----------------
		Kleist_98Parcels )
			nLabel=0
			for i in {1001..1049} {2001..2049}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Smith 88-Parcel
		# ---------------
		Smith_88Parcels )
			nLabel=0
			for i in {1001..1044} {2001..2044}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		
		# Desikan-Killiany-Tourville (DKT) atlas
		# --------------------------------------
		DKTaparc.atlas.acfb40.noaparc.i12.2020-05-13 )
			nLabel=0
			for i in 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1034 1035 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2034 2035
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		# Desikan-Killiany (DK) atlas
		# ---------------------------
		DesikanKilliany_68Parcels )
			nLabel=0
			for i in 1001 1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1032 1033 1034 1035 2001 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;

		* )
			nLabel=0
			for i in ${labels}
			do
				(( nLabel++ ))
				fslmaths ${tmp}/temp_atlas.nii.gz -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
			done
			;;
		esac
		num=${nLabel}

		# Add subcortical areas
		# ---------------------
		for i in 10 11 12 13 17 18 26 49 50 51 52 53 54 58
		do
			(( nLabel++ ))
			fslmaths ${aseg} -thr ${i} -uthr ${i} -bin -mul ${nLabel} -add ${tmp}/temp.nii.gz ${tmp}/temp.nii.gz
		done
		num=${nLabel}

		mv ${tmp}/temp.nii.gz ${atlt1w}
		fslreorient2std ${atlt1w} ${atlt1w}
		wait
		rm -rf ${tmp}/temp*.nii.gz
		wait

		if [[ -f ${atlt1w} ]]; then
			printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atlt1w} has been saved.\n"
		else
			printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atlt1w} has not been saved!!\n"
			exit 1
		fi

		# Elapsed time
		# ------------
		elapsedtime=$(($(date +%s) - ${startingtime}))
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
		echo "    ${elapsedtime} Atlas on the native T1 (Freesurfer)" >> ${et}
		;;

	# Atlas on the MNI152 T1 1mm (standard)
	# -------------------------------------
	mni152 )
		printf "${GRN}[Freesurfer & FSL]${RED} ID: ${grp}${sbj}${NCR} - Atlas on the MNI space is not supported by the current pipeline.\n"
		;;
	* )
	esac
fi

# Atlas transformation from T1 to resliced EPI
# --------------------------------------------
if [[ -f ${atlepi} ]]; then
    printf "  + ${atlepi} has been checked! Skip atlas transformation.\n"
else
	case ${atlname} in
        Schaefer2018_100Parcels_17Networks )
        num=114
        ;;
        DesikanKilliany_68Parcels )
        num=82
        ;;
        Smith_88Parcels )
        num=102
        ;;
        Kleist_98Parcels )
        num=112
        ;;
        HarvardOxford_96Parcels )
        num=110
        ;;
    esac

	# Transform native parcellations to the EPI space
	# -----------------------------------------------
	printf "  + Transform native parcellations to the EPI space\n"
	nThr=0
	for (( i = 1; i < num + 1; i++ ))
	do
	    Transform ${i} &
	    (( nThr++ ))
	    printf "[+] Running thread ${nThr} - index ${i}\n"
	    if [[ ${nThr} -eq ${threads} ]]; then
	        wait
	        nThr=0
	    fi
	done
	wait
	fslmaths ${epi_ref} -mul 0 ${tmp}/temp_mask.nii.gz
	for (( i = 1; i < num + 1; i++ ))
	do
	    fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_label${i}_mask3.nii.gz ${tmp}/temp_mask.nii.gz
		wait
	done
	mv ${tmp}/temp_mask.nii.gz ${atlepi}
	wait
	rm -f ${tmp}/temp*.nii.gz
	wait

	if [[ -f ${atlepi} ]]; then
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atlepi} has been saved.\n"
	else
		printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - ${atlepi} has not been saved!!\n"
		exit 1
	fi

	# Elapsed time
	# ------------
	elapsedtime=$(($(date +%s) - ${startingtime}))
	printf "${GRN}[FSL]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
	echo "    ${elapsedtime} Atlas transformation from T1 to resliced EPI" >> ${et}
fi

# Nuisance regression
# -------------------
# printf "  + Nuisance regression (WM, CSF, CTX, SubCTX, and Friston-24)\n"
# fsl_glm -i ${epi_out}_detrend -d ${tp}/${sbj}/regressors.txt --des_norm --out_res=${epi_out}_glm
# fslmaths ${epi_out}_glm -add ${epi_avg} ${epi_out}_glm
# wait
# mv ${epi_out}_glm.nii.gz ${tp}/${sbj}/prefiltered_func_data.nii.gz
# epi_out=${tp}/${sbj}/prefiltered_func_data
# printf "  + ${tp}/${sbj}/prefiltered_func_data.nii.gz has been saved.\n"

# Band-pass filtering
# -------------------
# printf "  + Band-pass filtering [${highbands},${lowbands}]\n"
# hp=`echo "1 / ( ${highbands} * ${TR} * 2 )" | bc -l`
# lp=`echo "1 / ( ${lowbands} * ${TR} * 2)" | bc -l`
# printf "  + Highpass sigma = ${hp}, lowpass sigma = ${lp}\n"
# fslmaths ${epi_out} -Tmean ${epi_out}_avg
# epi_glm_avg=${epi_out}_avg
# fslmaths ${epi_out} -bptf ${hp} ${lp} ${epi_out}_bptf
# epi_out=${epi_out}_bptf
# fslmaths ${epi_out} -add ${epi_glm_avg} ${tp}/${sbj}/filtered_func_data
# printf "  + ${tp}/${sbj}/filtered_func_data.nii.gz has been saved.\n"

# Smoothing
# ---------
# printf "  + Smoothing with 6FWFM\n"
# epi_out=${epi_out}_6fwhm
# fslmaths ${epi_out} -add ${epi_glm_avg} ${tp}/${sbj}/filtered_func_data
# epi_out=${tp}/${sbj}/filtered_func_data

# Delete files
# ------------
printf "  + Delete files\n"
rm -rf ${tp}/${sbj}/temp.nii.gz
rm -rf ${tp}/${sbj}/temp_mean_reg.nii.gz
rm -rf ${tp}/${sbj}/epi_s.nii.gz
rm -rf ${tp}/${sbj}/mc*.1D
rm -rf ${tp}/${sbj}/epi_sm_upsample.nii.gz
# rm -rf ${tp}/${sbj}/prefiltered_func_data_bptf.nii.gz
# rm -rf ${tp}/${sbj}/prefiltered_func_data_avg.nii.gz
# rm -rf ${epi_out}
# rm -rf ${tp}/${sbj}/epi_sm_upsample_detrend.nii.gz
# rm -rf ${tp}/${sbj}/epi_sm_upsample_glm.nii.gz
# rm -rf ${tp}/${sbj}/epi_sm_upsample.nii.gz
rm -rf ${tp}/${sbj}/epi_sm.nii.gz
rm -rf ${tp}/${sbj}/epi_sm_mean.nii.gz
rm -rf ${tp}/${sbj}/epi_sm.mat
# rm -rf ${tp}/${sbj}/HMlist.1D

# Elapsed time
# ------------
elapsedtime=$(($(date +%s) - ${startingtime}))
printf "\n  - Elapsed time of the FC pipeline = ${elapsedtime} seconds.\n"
echo "    ${elapsedtime} FC preprocess has finished." >> ${et}
