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

# Set file paths
# --------------
ppsc=/mnt_sc
sliceorder=${sp}/PD_HHU_sliceorder.txt
epiup=${tp}/${sbj}/epi_sm_upsample.nii.gz
epi_avg=${tp}/${sbj}/epi_sm_upsample_avg.nii.gz
epi_out=${tp}/${sbj}/epi_sm_upsample
tmp=/tmp/${grp}_${sbj}
mc=${tp}/${sbj}/mc.1D
mcdt=${tp}/${sbj}/mcdt.1D
epi_ref=${tp}/${sbj}/epi_avg_bc2.nii.gz

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

# Start the FC atlas transformation
# ---------------------------------
startingtime=$(date +%s)
et=${tp}/${sbj}/FC_atlas_transformation_elapsedtime.txt
echo "[+] Atlas transformation with ${threads} thread(s) - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

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
done

# Elapsed time
# ------------
elapsedtime=$(($(date +%s) - ${startingtime}))
printf "\n  - Elapsed time = ${elapsedtime} seconds.\n"
echo "    ${elapsedtime} Atlas transformation" >> ${et}
