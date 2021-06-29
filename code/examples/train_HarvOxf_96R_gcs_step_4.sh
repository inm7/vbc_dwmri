#!/bin/bash
fp=/mnt_fp # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
ap=/mnt_ap # /p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
tp=/mnt_tp # /p/scratch/cjinm71/jung3/03_Structural_Connectivity

atl=HarvardOxford_96Parcels

avg=fsaverage
LUT=${ap}/${atl}_LUT.txt

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Colors
# ------
RED='\033[1;31m'	# Red
GRN='\033[1;32m' 	# Green
NCR='\033[0m' 		# No Color

mris_ca_train -sdir ${fp} -t ${LUT} -n 1 lh lh.sphere.reg HarvardOxford_96Parcels ${avg} ${fp}/lh.HarvardOxford_96Parcels.gcs
mris_ca_train -sdir ${fp} -t ${LUT} -n 1 rh rh.sphere.reg HarvardOxford_96Parcels ${avg} ${fp}/rh.HarvardOxford_96Parcels.gcs
mv ${fp}/lh.HarvardOxford_96Parcels.gcs ${ap}/lh.HarvardOxford_96Parcels.gcs
mv ${fp}/rh.HarvardOxford_96Parcels.gcs ${ap}/rh.HarvardOxford_96Parcels.gcs
printf "${GRN}[Freesurfer]${RED} Classifier ${ap}/xh.HarvardOxford_96Parcels.gcs have been saved.\n"
