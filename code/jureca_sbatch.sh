#!/bin/bash
#SBATCH -J DWMRI
#SBATCH -o slurm_logs/DWMRI-out.%j
#SBATCH -e slurm_logs/DWMRI-err.%j
#SBATCH -A jinm71
#SBATCH -N 1
#SBATCH --time=20:00:00
#SBATCH --mail-user=k.jung@fz-juelich.de
#SBATCH --mail-type=ALL
#SBATCH --partition=dc-cpu

DATA_DIR=/p/scratch/cjinm71/jung3/02_MRI_data
ATLAS_DIR=/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
OUTPUT_DIR=/p/scratch/cjinm71/jung3/03_Structural_Connectivity
FREESURFER_OUTPUT=/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
FREESURFER_LICENSE=/p/project/cjinm71/Jung/01_MRI_pipelines/Container/fs_license.txt

VBC_DWMRI=/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri_v1.1.simg

INPUT_PARAMETERS=/p/scratch/cjinm71/jung3/02_MRI_data/input_MOUS_500K_Schaefer100P17N.txt
PROCESS_MODULE=/usr/local/bin/container_SC_preprocess.sh

cpu1=1
cpu2=2
cpu3=4
cpu4=8
cpu5=16
cpu6=32
cpu7=64

sbj1=sub-0001
sbj2=sub-0002
sbj3=sub-0003
sbj4=sub-0004
sbj5=sub-0005
sbj6=sub-0006
sbj7=sub-0007

# Condition 1 : 1 CPU
# -------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x1 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu1} ${sbj1} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x1 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu1} ${sbj1} &

# Condition 2 : 2 CPUs
# --------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x6 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu2} ${sbj2} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x6 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu2} ${sbj2} &

# Condition 3 : 4 CPUs
# --------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x78 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu3} ${sbj3} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x78 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu3} ${sbj3} &

# Condition 4 : 8 CPUs
# --------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x7F80 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu4} ${sbj4} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x7F80 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu4} ${sbj4} &

# Condition 5 : 16 CPUs
# --------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x7FFF8000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu5} ${sbj5} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x7FFF8000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu5} ${sbj5} &

# Condition 6 : 32 CPUs
# --------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x7FFFFFFF80000000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu6} ${sbj6} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x7FFFFFFF80000000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu6} ${sbj6} &

# Condition 7 : 64 CPUs
# --------------------
printf "srun --exclusive --cpu-bind=mask_cpu:0x7FFFFFFFFFFFFFFF8000000000000000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu7} ${sbj7} &\n"
srun --exclusive --cpu-bind=mask_cpu:0x7FFFFFFFFFFFFFFF8000000000000000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu7} ${sbj7} &

wait

# Condition 1 : 128 CPUs
# ----------------------
# printf "srun --exclusive --cpu-bind=mask_cpu:0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu1} ${sbj1} &\n"
# srun --exclusive --cpu-bind=mask_cpu:0x -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu1} ${sbj1} &

# Condition 2 : 128 CPUs
# ----------------------
# printf "srun --exclusive --cpu-bind=mask_cpu:0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu2} ${sbj2} &\n"
# srun --exclusive --cpu-bind=mask_cpu:0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 -n 1 -N 1 singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt ${VBC_DWMRI} ${PROCESS_MODULE} /opt/input.txt ${cpu2} ${sbj2} &
