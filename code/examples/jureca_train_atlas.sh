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

SCRIPT='train_HarvOxf_96R_gcs.sh'

wp=$(pwd)

# Set the number of threads per node
# ----------------------------------
# max_threads=256        # JUREDA-DC
# ----------------------------------
max_threads=256

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
for (( i = threads; i < max_threads + 1; i+= threads )); do
    
    # Set binary number
    # -----------------
    if [[ ${i} -eq 1 ]]; then
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
        printf "\n[cpu-bind] Binary = ${bind_bin}, Hexadecimal = ${bind_hex} (Thread index = ${i})\n"

        # Perform srun
        # ------------
        sbj=$(sed -n $((nSbj))p ${wp}/${fn})
        if [[ ${nSbj} -gt ${endNum} ]]; then
            printf "Subject number (${nSbj}) exceeded the end number (${endNum}). \n"
        else
            printf "srun --exclusive --cpu-bind=mask_cpu:0x${bind_hex} -n 1 -N 1 singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${grp} ${sbj} &\n"
            # srun --exclusive --cpu-bind=mask_cpu:0x${bind_hex} -n 1 -N 1 singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${grp} ${sbj} &
        fi
        (( nSbj++ ))
    fi
done

wait