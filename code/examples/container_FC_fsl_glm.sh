#!/bin/bash
grp=${1}
sbj=${2}
# atlname=${3}
# num=${4}

threads=1
TR=2.21

highbands=0.01
lowbands=0.1

source /etc/fsl/fsl.sh
source /etc/afni/afni.sh
export LC_ALL=C
export ANTSPATH=/usr/lib/ants
export PATH=${PATH}:/usr/lib/ants

# Source path (BIDS)
# ------------------
sp=/mnt_sp

# Target path (BOLD)
# ------------------
tp=/mnt_tp/PD_HHU_by_KJung

# Start the SC tractography
# -------------------------
startingtime=$(date +%s)
et=${tp}/${sbj}/FC_pipeline_elapsedtime.txt
echo "[+] Functional preprocessing with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

ppsc=/mnt_sc
sliceorder=${sp}/PD_HHU_sliceorder.txt
epiup=${tp}/${sbj}/epi_sm_upsample.nii.gz
epi_avg=${tp}/${sbj}/epi_sm_upsample_avg.nii.gz
epi_out=${tp}/${sbj}/epi_sm_upsample
tmp=/tmp/${grp}_${sbj}

mc=${tp}/${sbj}/mc.1D
mcdt=${tp}/${sbj}/mcdt.1D

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
	mkdir ${tp}/${sbj}
fi
if [[ -d ${tmp} ]]; then
	printf "  + ${tmp} exists.\n"
else
	printf "  + Create ${tmp}.\n"
	mkdir ${tmp}
fi

# Slice timing correction
# -----------------------
printf "  + Slice timing correction\n"
slicetimer -i ${sp}/${grp}/${sbj}/func/${sbj}_task-rest_bold.nii.gz -o ${tp}/${sbj}/epi_s -r ${TR} --ocustom=${sliceorder}

# Mean volume for a reference image
# ---------------------------------
printf "  + Mean volume for a reference image\n"
mcflirt -in ${tp}/${sbj}/epi_s.nii.gz -o ${tp}/${sbj}/temp -meanvol -dof 6 -cost normcorr
fslmaths ${tp}/${sbj}/temp.nii.gz -Tmean ${tp}/${sbj}/epi_sm_mean

# Head motion correction
# ----------------------
printf "  + Head motion correction\n"
mcflirt -in ${tp}/${sbj}/epi_s.nii.gz -o ${tp}/${sbj}/epi_sm -reffile ${tp}/${sbj}/epi_sm_mean.nii.gz -plots -dof 6 -mats -cost normcorr -stages 3

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
fi

# Intensity normalization
# -----------------------
printf "  + Intensity normalization\n"
fslmaths ${epiup} -inm 10000 ${epiup}

# Detrending with very slow fluctuation (High-pass)
# -------------------------------------------------
printf "  + Detrending with very slow fluctuation (hp=0.5*1000/TR)\n"
fslmaths ${epiup} -Tmean ${epi_avg}
fslmaths ${epiup} -bptf 226 -1 ${epi_out}_detrend
fslmaths ${epi_out}_detrend -add ${epi_avg} ${epi_out}_detrend

# Mean EPI volume for coregistration to T1
# ----------------------------------------
printf "  + Mean EPI volume for coregistration to T1\n"
fslmaths ${epi_out}_detrend -Tmean ${epi_avg}

# Bias field correction (Average EPI)
# -----------------------------------
printf "  + Bias field correction for referencing\n"
N4BiasFieldCorrection -i ${epi_avg} -o [${tp}/${sbj}/epi_avg_bc1.nii.gz,${tp}/${sbj}/epi_avg_bf1.nii.gz]
N4BiasFieldCorrection -i ${tp}/${sbj}/epi_avg_bc1.nii.gz -o [${tp}/${sbj}/epi_avg_bc2.nii.gz,${tp}/${sbj}/epi_avg_bf2.nii.gz]
epi_ref=${tp}/${sbj}/epi_avg_bc2.nii.gz

# Coregistration from T1 (1mm freesurfered) to EPI (upsampled)
# ------------------------------------------------------------
# t1_ctx=${ppsc}/${sbj}/temp/fs_t1_ctx_mask.nii.gz
# t1_subctx=${ppsc}/${sbj}/temp/fs_t1_subctx_mask.nii.gz
# t1_wm=${ppsc}/${sbj}/temp/fs_t1_wm_mask.nii.gz
# t1_csf=${ppsc}/${sbj}/temp/fs_t1_csf_mask.nii.gz

# Co-registration between T1-weighted image and EPI (rs-fMRI)
# -----------------------------------------------------------
printf "  + Co-registration between T1-weighted image and EPI (rs-fMRI)\n"
if [[ -f ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat ]]; then
    printf "  + ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat has been checked! Skip co-registration.\n"
else
    flirt -in ${epi_ref} -ref ${ppsc}/${sbj}/fs_t1_brain.nii.gz -out ${tp}/${sbj}/epi_to_fs_t1_affine.nii.gz -omat ${tp}/${sbj}/epi_to_fs_t1_affine.mat -dof 6 -cost mutualinfo
    convert_xfm -omat ${tp}/${sbj}/epi_to_fs_t1_invaffine.mat -inverse ${tp}/${sbj}/epi_to_fs_t1_affine.mat
    applywarp -i ${ppsc}/${sbj}/fs_t1.nii.gz -r ${epi_ref} -o ${tp}/${sbj}/fs_t1_to_epi.nii.gz --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat
    applywarp -i ${ppsc}/${sbj}/fs_t1_brain.nii.gz -r ${epi_ref} -o ${tp}/${sbj}/fs_t1_brain_to_epi.nii.gz --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat
fi

# Transform tissue masks in T1 to the upsampled EPI
# -------------------------------------------------
printf "  + Transform tissue masks in T1 to the upsampled EPI\n"
for tissue in ctx subctx wm csf; do
	applywarp -i ${ppsc}/${sbj}/temp/fs_t1_${tissue}_mask.nii.gz -r ${epi_ref} -o ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample --premat=${tp}/${sbj}/epi_to_fs_t1_invaffine.mat
	fslmaths ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample -thr 0.5 -bin ${tp}/${sbj}/fs_t1_${tissue}_mask_to_epi_upsample
done
fslmaths ${tp}/${sbj}/fs_t1_wm_mask_to_epi_upsample -add ${tp}/${sbj}/fs_t1_csf_mask_to_epi_upsample -add ${tp}/${sbj}/fs_t1_ctx_mask_to_epi_upsample -add ${tp}/${sbj}/fs_t1_subctx_mask_to_epi_upsample -bin ${tp}/${sbj}/fs_t1_global_mask_to_epi_upsample

# Prepare regressors
# ------------------
printf "  + Prepare regressors\n"
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

# paste ${tp}/${sbj}/regressor_wm.txt ${tp}/${sbj}/regressor_csf.txt ${tp}/${sbj}/regressor_global.txt ${tp}/${sbj}/Friston-24.txt >> ${tp}/${sbj}/regressors.txt
paste ${tp}/${sbj}/regressor_wm.txt ${tp}/${sbj}/regressor_csf.txt ${tp}/${sbj}/regressor_ctx.txt ${tp}/${sbj}/regressor_subctx.txt ${tp}/${sbj}/Friston-24.txt >> ${tp}/${sbj}/regressors.txt

# Nuisance regression
# -------------------
printf "  + Nuisance regression (WM, CSF, CTX, SubCTX, and Friston-24)\n"
fsl_glm -i ${epi_out}_detrend -d ${tp}/${sbj}/regressors.txt --des_norm --out_res=${epi_out}_glm
fslmaths ${epi_out}_glm -add ${epi_avg} ${epi_out}_glm
wait
mv ${epi_out}_glm.nii.gz ${tp}/${sbj}/prefiltered_func_data.nii.gz
epi_out=${tp}/${sbj}/prefiltered_func_data
printf "  + ${tp}/${sbj}/prefiltered_func_data.nii.gz has been saved.\n"

# Band-pass filtering
# -------------------
printf "  + Band-pass filtering [${highbands},${lowbands}]\n"
hp=`echo "1 / ( ${highbands} * ${TR} * 2 )" | bc -l`
lp=`echo "1 / ( ${lowbands} * ${TR} * 2)" | bc -l`
printf "  + Highpass sigma = ${hp}, lowpass sigma = ${lp}\n"
fslmaths ${epi_out} -Tmean ${epi_out}_avg
epi_glm_avg=${epi_out}_avg
fslmaths ${epi_out} -bptf ${hp} ${lp} ${epi_out}_bptf
epi_out=${epi_out}_bptf
fslmaths ${epi_out} -add ${epi_glm_avg} ${tp}/${sbj}/filtered_func_data
printf "  + ${tp}/${sbj}/filtered_func_data.nii.gz has been saved.\n"

# Smoothing
# ---------
# printf "  + Smoothing with 6FWFM\n"
# epi_out=${epi_out}_6fwhm
# fslmaths ${epi_out} -add ${epi_glm_avg} ${tp}/${sbj}/filtered_func_data
# epi_out=${tp}/${sbj}/filtered_func_data

# Atlas transformation and extract mean BOLD signals
# --------------------------------------------------
for atlname in Schaefer2018_100Parcels_17Networks DesikanKilliany_68Parcels Smith_88Parcels Kleist_98Parcels HarvardOxford_96Parcels
do
	atlt1w=${ppsc}/${sbj}/${atlname}_to_fs_t1_native+subctx.nii.gz
	atlepi=${tp}/${sbj}/${atlname}_to_epi_upsample_native+subctx.nii.gz

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

	# BOLD extraction (prefiltered)
	# -----------------------------
	epi_out=${tp}/${sbj}/prefiltered_func_data
	printf "  + BOLD extraction (prefiltered)\n"
	fslmeants -i ${epi_out} --label=${atlepi} -o ${tp}/${sbj}/temp_BOLD.txt
	cat ${tp}/${sbj}/temp_BOLD.txt | tr -s " " >> ${tp}/${sbj}/temp.txt
	cat ${tp}/${sbj}/temp.txt | tr ' ' ',' >> ${tp}/${sbj}/temp2.txt
	cat ${tp}/${sbj}/temp2.txt | sed 's/.$//' > ${tp}/${sbj}/temp3.txt
	mv ${tp}/${sbj}/temp3.txt ${epi_out}_${atlname}_native_subctx_BOLD.csv
	wait
	rm -f ${tp}/${sbj}/temp*.txt
	printf "  + ${epi_out}_${atlname}_native_subctx_BOLD.csv has been saved.\n"

	# Extract the first eigenvariate of BOLD (prefiltered)
	# ----------------------------------------------------
	printf "  + Eigenvariate (1st) BOLD extraction (prefiltered)\n"
	nThr=0
	for (( i = 1; i < num + 1; i++ ))
	do
	    ExtractEigenvariateBOLD ${i} &
	    (( nThr++ ))
	    printf "[+] Running thread ${nThr} - index ${i}\n"
	    if [[ ${nThr} -eq ${threads} ]]; then
	        wait
	        nThr=0
	    fi
	done
	wait
	cmd=""
	for (( i = 1; i < num + 1; i++ ))
	do
		cmd="${cmd} ${tmp}/${atlname}_${i}_eig.txt"
	done
	paste -d " " ${cmd} >> ${tmp}/temp_BOLD.txt

	ConvertCSV
	wait

	rm -rf ${tmp}/${atlname}*eig.txt
	rm -rf ${tmp}/temp_${atlname}_label*.nii.gz
	wait

	# BOLD extraction (filtered)
	# --------------------------
	epi_out=${tp}/${sbj}/filtered_func_data
	printf "  + BOLD extraction (filtered)\n"
	fslmeants -i ${epi_out} --label=${atlepi} -o ${tp}/${sbj}/temp_BOLD.txt
	cat ${tp}/${sbj}/temp_BOLD.txt | tr -s " " >> ${tp}/${sbj}/temp.txt
	cat ${tp}/${sbj}/temp.txt | tr ' ' ',' >> ${tp}/${sbj}/temp2.txt
	cat ${tp}/${sbj}/temp2.txt | sed 's/.$//' > ${tp}/${sbj}/temp3.txt
	mv ${tp}/${sbj}/temp3.txt ${epi_out}_${atlname}_native_subctx_BOLD.csv
	wait
	rm -f ${tp}/${sbj}/temp*.txt
	printf "  + ${epi_out}_${atlname}_native_subctx_BOLD.csv has been saved.\n"

	# Extract the first eigenvariate of BOLD (filtered)
	# -------------------------------------------------
	printf "  + Eigenvariate (1st) BOLD extraction (filtered)\n"
	nThr=0
	for (( i = 1; i < num + 1; i++ ))
	do
	    ExtractEigenvariateBOLD ${i} &
	    (( nThr++ ))
	    printf "[+] Running thread ${nThr} - index ${i}\n"
	    if [[ ${nThr} -eq ${threads} ]]; then
	        wait
	        nThr=0
	    fi
	done
	wait
	cmd=""
	for (( i = 1; i < num + 1; i++ ))
	do
		cmd="${cmd} ${tmp}/${atlname}_${i}_eig.txt"
	done
	paste -d " " ${cmd} >> ${tmp}/temp_BOLD.txt

	ConvertCSV
	wait

	rm -rf ${tmp}/${atlname}*eig.txt
	rm -rf ${tmp}/temp_${atlname}_label*.nii.gz
	wait
done

# Delete files
# ------------
printf "  + Delete files\n"
rm -rf ${tp}/${sbj}/temp.nii.gz
rm -rf ${tp}/${sbj}/temp_mean_reg.nii.gz
rm -rf ${tp}/${sbj}/epi_s.nii.gz
rm -rf ${tp}/${sbj}/mc*.1D
rm -rf ${tp}/${sbj}/epi_sm_upsample*.nii.gz
rm -rf ${tp}/${sbj}/prefiltered_func_data_bptf.nii.gz
rm -rf ${tp}/${sbj}/prefiltered_func_data_avg.nii.gz
# rm -rf ${epi_out}
# rm -rf ${tp}/${sbj}/epi_sm_upsample_detrend.nii.gz
# rm -rf ${tp}/${sbj}/epi_sm_upsample_glm.nii.gz
# rm -rf ${tp}/${sbj}/epi_sm_upsample.nii.gz
rm -rf ${tp}/${sbj}/epi_sm.nii.gz
rm -rf ${tp}/${sbj}/epi_sm_mean.nii.gz
rm -rf ${tp}/${sbj}/epi_sm.mat
# rm -rf ${tp}/${sbj}/HMlist.1D
