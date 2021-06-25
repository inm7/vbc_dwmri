#!/bin/bash
grp=${1}
sbj=${2}

fp=/mnt_fp # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
ap=/mnt_ap # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
tp=/mnt_tp # /p/scratch/cjinm71/jung3/03_Structural_Connectivity

LUT=${ap}/HarvardOxford_96Parcels_LUT.txt

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

mris_sample_parc -ct ${LUT} -sdir ${fp} ${grp}_${sbj} lh HarvardOxford_96R.mgz lh.HarvardOxford_96Parcels.annot
mris_sample_parc -ct ${LUT} -sdir ${fp} ${grp}_${sbj} rh HarvardOxford_96R.mgz rh.HarvardOxford_96Parcels.annot
printf "${GRN}[Freesurfer]${RED} ID: ${grp}${sbj}${NCR} - Annotation files: lh.HarvardOxford_96Parcels.annot and rh.HarvardOxford_96Parcels.annot have been saved.\n"
