#!/bin/bash

# Call container_SC_dependencies
# ------------------------------
export LC_ALL=C
export ANTSPATH=/usr/lib/ants
export PATH=${PATH}:/usr/lib/ants
source /etc/fsl/fsl.sh
source /etc/afni/afni.sh
export FREESURFER_HOME=/opt/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects
export PATH=${PATH}:/opt/mrtrix3/bin