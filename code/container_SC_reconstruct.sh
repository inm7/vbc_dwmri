#!/bin/bash

input=${1}
totalNum=$(grep -c $ ${input})
for (( i = 1; i < totalNum + 1 ; i++ )); do
	cmd=$(sed -n ${i}p ${input})
	eval "${cmd}"
done
threads=${threads4}
atl=${tp}/${grp}/${sbj}/${atlname}_to_dwi.nii.gz

# Colors
# ------
RED='\033[1;31m'
GRN='\033[1;32m'
NCR='\033[0m' # No Color

# Call container_SC_dependencies
# ------------------------------
source /usr/local/bin/container_SC_dependencies.sh
export SUBJECTS_DIR=/opt/freesurfer/subjects

# Freesurfer license
# ------------------
if [[ -f /opt/freesurfer/license.txt ]]; then
	printf "Freesurfer license has been checked.\n"
else
	echo "${email}" >> $FREESURFER_HOME/license.txt
	echo "${digit}" >> $FREESURFER_HOME/license.txt
	echo "${line1}" >> $FREESURFER_HOME/license.txt
	echo "${line2}" >> $FREESURFER_HOME/license.txt
	printf "Freesurfer license has been updated.\n"
fi

if [[ ${tract} -gt 999999 ]]; then
	tractM=$((${tract}/1000000))M
else
	tractM=$((${tract}/1000))K
fi

startingtime=$(date +%s)
et=${tp}/${grp}/${sbj}/SC_pipeline_elapsedtime.txt
echo "[+] SC reconstruct for ${tractM} - $(date)" >> ${et}
echo "    Starting time in seconds ${startingtime}" >> ${et}

tck=${tp}/${grp}/${sbj}/WBT_${tractM}_ctx.tck
counts=${tp}/${grp}/${sbj}/${atlname}_${tractM}_ctx_count.csv
lengths=${tp}/${grp}/${sbj}/${atlname}_${tractM}_ctx_length.csv

# Over-write code
# ---------------
printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Reconstruct structural connectivity (counts).\n"
tck2connectome -symmetric -force -nthreads ${threads} -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${counts}
printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Reconstruct structural connectivity (lengths).\n"
tck2connectome -symmetric -force -nthreads ${threads} -scale_length -stat_edge mean -assignment_radial_search ${tck2connectome_assignment_radial_search} ${tck} ${atl} ${lengths}

# Elapsed time
# ------------
elapsedtime=$(($(date +%s) - ${startingtime}))
printf "${GRN}[MRtrix]${RED} ID: ${grp}${sbj}${NCR} - Elapsed time = ${elapsedtime} seconds.\n"
echo "    ${elapsedtime} tck2connectome" >> ${et}
