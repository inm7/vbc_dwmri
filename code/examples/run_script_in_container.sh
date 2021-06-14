#!/bin/bash
startNum=${1}
totalNum=${2}

VBC_DWMRI='/data/project/SC_pipeline/01_MRI_pipelines/Container/Singularity/Container_SC_pipeline.simg'
DATA_DIR='/data/project/SC_pipeline/02_MRI_data'
ATLAS_DIR='/data/project/SC_pipeline/02_MRI_data/Atlases'
OUTPUT_DIR='/data/project/SC_pipeline/03_Structural_Connectivity'
FREESURFER_OUTPUT='/data/project/SC_pipeline/Neuroimage/Tools/freesurfer/subjects'
FREESURFER_LICENSE='/opt/freesurfer/6.0/license.txt'
RUN_SHELLSCRIPT='/data/project/SC_pipeline/02_MRI_data/multiple_reconstruct.sh'
SUBJECTS_LIST='/data/project/SC_pipeline/02_MRI_data/list_PD_HHU_QC_N73.txt'

# Condition 1
# -----------
INPUT_PARAMETERS=$(pwd)/input_PD_HHU_10M_Schaefer100P17N_MNI152.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 2
# -----------
INPUT_PARAMETERS=$(pwd)/input_PD_HHU_2M_Schaefer100P17N_MNI152.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 3
# -----------
INPUT_PARAMETERS=$(pwd)/input_PD_HHU_500K_Schaefer100P17N_MNI152.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 4
# -----------
INPUT_PARAMETERS=$(pwd)/input_PD_HHU_100K_Schaefer100P17N_MNI152.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 5
# -----------
INPUT_PARAMETERS=$(pwd)/input_PD_HHU_50K_Schaefer100P17N_MNI152.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}

# Condition 6
# -----------
INPUT_PARAMETERS=$(pwd)/input_PD_HHU_10K_Schaefer100P17N_MNI152.txt
singularity exec --cleanenv -B ${DATA_DIR}:/mnt_sp,${OUTPUT_DIR}:/mnt_tp,${FREESURFER_OUTPUT}:/mnt_fp,${ATLAS_DIR}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${INPUT_PARAMETERS}:/opt/input.txt,${RUN_SHELLSCRIPT}:/opt/script.sh,${SUBJECTS_LIST}:/opt/list.txt ${VBC_DWMRI} /opt/script.sh /opt/list.txt /opt/input.txt ${startNum} ${totalNum}
