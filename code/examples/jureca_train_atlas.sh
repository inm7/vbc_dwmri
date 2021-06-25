#!/bin/bash
#SBATCH -J DWMRI
#SBATCH -o slurm_logs/DWMRI-out.%j
#SBATCH -e slurm_logs/DWMRI-err.%j
#SBATCH -A jinm71
#SBATCH -N 1
#SBATCH --time=1:00:00
#SBATCH --mail-user=k.jung@fz-juelich.de
#SBATCH --mail-type=ALL
#SBATCH --partition=dc-cpu

VBC_DWMRI='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri_v1.3.simg'
FREESURFER_LICENSE='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/license.txt'

SET_FP='/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects'
SET_TP='/p/scratch/cjinm71/jung3/03_Structural_Connectivity'
SET_AP='/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas'

fn=${1}
grp=${2}
startNum=${3}
endNum=${4}
threads=${5}

num=60
SCRIPT='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri/code/examples/train_HarvOxf_96R_gcs.sh'

wp=$(pwd)

# Set the number of threads per node
# ----------------------------------
# max_threads=256        # JUREDA-DC
# ----------------------------------
max_threads=$(( threads * ( endNum - startNum + 1 ) ))

for (( j = 1; j < threads + 1; j++ )); do
    if [[ ${j} -eq 1 ]]; then
        run_threads="1"
        null_threads="0"
    else
        run_threads+="1"
        null_threads+="0"
    fi
done
printf "run_threads  = ${run_threads}\n"
printf "null_threads = ${null_threads}\n"

nSbj=${startNum}
nThr=0
for (( i = threads; i < max_threads + 1; i+= threads )); do
    (( nThr++ ))
    printf "\n[+] Running thread ${nThr} - index ${i}\n"

    # Set binary number
    # -----------------
    if [[ ${nThr} -eq 1 ]]; then
        bind_bin=${run_threads}
        zero_bin=${null_threads}
    else
        bind_bin=${run_threads}${zero_bin}
        zero_bin+=${null_threads}
    fi
    
    # Check the loop for individual running
    # -------------------------------------
    if [[ ${i} -gt ${max_threads} ]]; then
        printf "Exceeded ${i} out of ${max_threads}\n"
    else
        # Convert binary to hexadecimal
        # -----------------------------
        bind_hex=$(echo "obase=16;ibase=2;${bind_bin}" | bc )
        printf "[cpu-bind] Binary = ${bind_bin}, Hexadecimal = ${bind_hex} (Thread index = ${i})\n"

        # Perform srun
        # ------------
        sbj=$(sed -n $((nSbj))p ${wp}/${fn})
        if [[ ${nSbj} -gt ${endNum} ]]; then
            printf "Subject number (${nSbj}) exceeded the end number (${endNum}). \n"
        else
            printf "srun --exclusive --cpu-bind=mask_cpu:0x${bind_hex} -n 1 -N 1 singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${grp} ${sbj} &\n"
            srun --exclusive --cpu-bind=mask_cpu:0x${bind_hex} -n 1 -N 1 singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${grp} ${sbj} &
        fi
        (( nSbj++ ))
    fi
    if [[ ${nThr} -eq ${num} ]]; then
        wait
        nThr=0
    fi
done
wait

# export FS=/Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/subjects
# export SUBJECTS_DIR=/Applications/freesurfer/7.1.1/subjects
# cd ${FS}
# grp=HCP
# LUT=/Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HarvardOxford_96R_LUT.txt
# for sbj in 101309 102311 103111 108525 110411 111009 111413 112920 126628 131217; do
# 	mris_sample_parc -ct ${LUT} -sdir ${FS} ${grp}_${sbj} lh HarvardOxford_96R.mgz lh.HarvardOxford_96R_v3.annot
# 	mris_sample_parc -ct ${LUT} -sdir ${FS} ${grp}_${sbj} rh HarvardOxford_96R.mgz rh.HarvardOxford_96R_v3.annot
# done
# mris_ca_train -sdir ${FS} -t ${LUT} -n 10 lh lh.sphere.reg HarvardOxford_96R_v3 HCP_101309 HCP_102311 HCP_103111 HCP_108525 HCP_110411 HCP_111009 HCP_111413 HCP_112920 HCP_126628 HCP_131217 lh.HarvardOxford_96R_HCP_N10.gcs
# mris_ca_train -sdir ${FS} -t ${LUT} -n 10 rh rh.sphere.reg HarvardOxford_96R_v3 HCP_101309 HCP_102311 HCP_103111 HCP_108525 HCP_110411 HCP_111009 HCP_111413 HCP_112920 HCP_126628 HCP_131217 rh.HarvardOxford_96R_HCP_N10.gcs
# mv ${FS}/lh.HarvardOxford_96R_HCP_N10.gcs /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/lh.HarvardOxford_96R_HCP_N10_v3.gcs
# mv ${FS}/rh.HarvardOxford_96R_HCP_N10.gcs /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/rh.HarvardOxford_96R_HCP_N10_v3.gcs

# # Project to individuals
# # ----------------------
# export FS=/Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/subjects
# grp=PD_HHU
# # for sbj in PD_020130429 PD_20111212 PD_20120126 PD_20120315; do
# for sbj in PD_20111212 PD_20120126 PD_20120315; do
# 	mris_ca_label -sdir ${FS} -l ${FS}/${grp}_${sbj}/label/lh.cortex.label ${grp}_${sbj} lh ${FS}/${grp}_${sbj}/surf/lh.sphere.reg /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/lh.HarvardOxford_96R_HCP_N10_v3.gcs ${FS}/${grp}_${sbj}/label/lh.HarvardOxford_96R_HCP_N10_v3.annot
# 	mris_ca_label -sdir ${FS} -l ${FS}/${grp}_${sbj}/label/rh.cortex.label ${grp}_${sbj} rh ${FS}/${grp}_${sbj}/surf/rh.sphere.reg /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/rh.HarvardOxford_96R_HCP_N10_v3.gcs ${FS}/${grp}_${sbj}/label/rh.HarvardOxford_96R_HCP_N10_v3.annot
# 	export SUBJECTS_DIR=${FS}
# 	mri_aparc2aseg --s ${grp}_${sbj} --o ${FS}/${grp}_${sbj}_HarvardOxford_96R_HCP_N10_v3.nii.gz --annot HarvardOxford_96R_HCP_N10_v3
# 	mri_convert ${FS}/${grp}_${sbj}_HarvardOxford_96R_HCP_N10_v3.nii.gz ${FS}/${grp}_${sbj}/mri/aparc.HarvardOxford_96R.mgz
# 	export SUBJECTS_DIR=/Applications/freesurfer/7.1.1/subjects
# done