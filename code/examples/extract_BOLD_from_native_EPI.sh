#!/bin/bash
grp=${1}
sbj=${2}
threads=${3}
atlname=Schaefer2018_100Parcels_17Networks
num=114

sp=/data/project/SC_pipeline/03_Functional_Connectivity
tp=/data/project/SC_pipeline/03_Structural_Connectivity
tmp=${tp}/${grp}/${sbj}/temp

atl=${tp}/${grp}/${sbj}/${atlname}_to_epi_native+subctx.nii.gz
atlt1w=${tp}/${grp}/${sbj}/${atlname}_to_fs_t1_native+subctx.nii.gz
gmneck=${tp}/${grp}/${sbj}/fs_t1_neck_gm_mask_to_dwi.nii.gz
epi=${sp}/${grp}/Derivatives/vbc_fmri/rfMRI/${sbj}/fMRI1/filtered_func_data.nii.gz
epiup=${sp}/${grp}/Derivatives/vbc_fmri/rfMRI/${sbj}/fMRI1/filtered_func_data_upsample.nii.gz
epi_avg=${tp}/${grp}/${sbj}/filtered_func_data_avg_upsample.nii.gz
bold=${sp}/${grp}/Derivatives/vbc_fmri/rfMRI/${sbj}/fMRI1/Atlas/filtered_func_data_upsample_${atlname}_native_subctx_BOLD.csv

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
	applywarp -i ${mask1} -r ${epi_avg} -o ${mask3} --premat=${tp}/${grp}/${sbj}/epi_to_fs_t1_invaffine.mat
	fslmaths ${mask3} -thr 0.5 -uthr 0.5 ${mask4}
	fslmaths ${mask3} -sub ${mask4} -thr 0.5 -bin -mul ${idx} ${mask3}
}

# BOLD extraction
# ---------------
BOLD_Extraction()
{
    fp=${sp}/${grp}/Derivatives/vbc_fmri/rfMRI/${sbj}/fMRI1/Atlas
    fslmeants -i ${epiup} --label=${atl} -o ${fp}/temp_BOLD.txt
    cat ${fp}/temp_BOLD.txt | tr -s " " >> ${fp}/temp.txt
    cat ${fp}/temp.txt | tr ' ' ',' >> ${fp}/temp2.txt
    cat ${fp}/temp2.txt | sed 's/.$//' > ${fp}/temp3.txt
    mv ${fp}/temp3.txt ${bold}
    rm -f ${fp}/temp*.txt
}

source /etc/fsl/fsl.sh

# Call container_SC_dependencies
# ------------------------------
# source /usr/local/bin/container_SC_dependencies.sh
# export SUBJECTS_DIR=/opt/freesurfer/subjects

# Freesurfer license
# ------------------
# if [[ -f /opt/freesurfer/license.txt ]]; then
# 	printf "Freesurfer license has been checked.\n"
# else
# 	echo "${email}" >> $FREESURFER_HOME/license.txt
# 	echo "${digit}" >> $FREESURFER_HOME/license.txt
# 	echo "${line1}" >> $FREESURFER_HOME/license.txt
# 	echo "${line2}" >> $FREESURFER_HOME/license.txt
# 	printf "Freesurfer license has been updated.\n"
# fi

cd ${tmp}
fslsplit ${epi} temp_epi_ -t
cmd="fslmerge -t ${tmp}/merged_upsampled_epi.nii.gz"
for i in {0..299}; do
	epinum=$(printf "%04d" ${i})
	flirt -in ${tmp}/temp_epi_${epinum}.nii.gz -ref ${tmp}/temp_epi_${epinum}.nii.gz -applyisoxfm 1.0 -out ${tmp}/temp_epi_${epinum}_upsample.nii.gz
	cmd+=" ${tmp}/temp_epi_${epinum}_upsample.nii.gz"
done
eval "${cmd}"
rm -rf ${tmp}/temp_epi_*.nii.gz
mv ${tmp}/merged_upsampled_epi.nii.gz ${epiup}

# Co-registration between T1-weighted image and EPI (rs-fMRI)
# -----------------------------------------------------------
fslmaths ${epiup} -Tmean ${epi_avg}
flirt -in ${epi_avg} -ref ${tp}/${grp}/${sbj}/fs_t1_brain.nii.gz -out ${tp}/${grp}/${sbj}/epi_to_fs_t1_affine.nii.gz -omat ${tp}/${grp}/${sbj}/epi_to_fs_t1_affine.mat -dof 6 -cost corratio
convert_xfm -omat ${tp}/${grp}/${sbj}/epi_to_fs_t1_invaffine.mat -inverse ${tp}/${grp}/${sbj}/epi_to_fs_t1_affine.mat
applywarp -i ${tp}/${grp}/${sbj}/fs_t1.nii.gz -r ${epi_avg} -o ${tp}/${grp}/${sbj}/fs_t1_to_epi.nii.gz --premat=${tp}/${grp}/${sbj}/epi_to_fs_t1_invaffine.mat
applywarp -i ${tp}/${grp}/${sbj}/fs_t1_brain.nii.gz -r ${epi_avg} -o ${tp}/${grp}/${sbj}/fs_t1_brain_to_epi.nii.gz --premat=${tp}/${grp}/${sbj}/epi_to_fs_t1_invaffine.mat

# Transform native parcellations to the EPI space
# -----------------------------------------------
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

fslmaths ${epi_avg} -mul 0 ${tmp}/temp_mask.nii.gz
for (( i = 1; i < num + 1; i++ ))
do
    fslmaths ${tmp}/temp_mask.nii.gz -add ${tmp}/temp_label${i}_mask3.nii.gz ${tmp}/temp_mask.nii.gz
done
mv ${tmp}/temp_mask.nii.gz ${atl}
rm -f ${tmp}/temp*.nii.gz

BOLD_Extraction
