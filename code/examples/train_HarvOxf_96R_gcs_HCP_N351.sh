#!/bin/bash

# train_HarvOxf_96R_gcs_HCP_N351.sh
# ---------------------------------
# grp=HCP
# sbj=101309

VBC_DWMRI='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/vbc_dwmri_v1.3.simg'
FREESURFER_LICENSE='/p/project/cjinm71/Jung/01_MRI_pipelines/Container/license.txt'

SET_FP='/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects'
SET_TP='/p/scratch/cjinm71/jung3/03_Structural_Connectivity'
SET_AP='/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas'

SCRIPT=''

singularity exec --cleanenv -B ${SET_TP}:/mnt_tp,${SET_FP}:/mnt_fp,${SET_AP}:/mnt_ap,${FREESURFER_LICENSE}:/opt/freesurfer/license.txt,${SCRIPT}:/opt/script.sh ${VBC_DWMRI} /opt/script.sh ${grp} ${sbj}


# SCRIPT
# ------
# mris_ca_train -sdir /mnt_fp -n 351 -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt lh sphere.reg HarvardOxford_96R HCP_101309 HCP_102311 HCP_103111 HCP_108525 HCP_110411 HCP_111009 HCP_111413 HCP_112920 HCP_126628 HCP_131217 lh.HarvardOxford_96R_HCP_N10.gcs
# mris_ca_train -sdir /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/subjects -n 10 -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt rh sphere.reg HarvardOxford_96R HCP_101309 HCP_102311 HCP_103111 HCP_108525 HCP_110411 HCP_111009 HCP_111413 HCP_112920 HCP_126628 HCP_131217 rh.HarvardOxford_96R_HCP_N10.gcs

# mris_ca_label -sdir ${FS} -l ${FS}/PD_HHU_PD_020130429/label/lh.cortex.label -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt PD_HHU_PD_020130429 lh ${FS}/PD_HHU_PD_020130429/surf/lh.sphere.reg /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/lh.HarvardOxford_96R_HCP_N10.gcs ${FS}/PD_HHU_PD_020130429/label/lh.HarvardOxford_96R_HCP_N10.annot
# mris_ca_label -sdir ${FS} -l ${FS}/PD_HHU_PD_020130429/label/rh.cortex.label -t /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/HO_R96_color_table.txt PD_HHU_PD_020130429 rh ${FS}/PD_HHU_PD_020130429/surf/rh.sphere.reg /Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers/rh.HarvardOxford_96R_HCP_N10.gcs ${FS}/PD_HHU_PD_020130429/label/rh.HarvardOxford_96R_HCP_N10.annot

# export SUBJECTS_DIR=${FS}
# mri_aparc2aseg --s PD_HHU_PD_020130429 --o ./temp_atlas.nii.gz --annot HarvardOxford_96R_HCP_N10
# export SUBJECTS_DIR=/Applications/freesurfer/7.1.1/subjects
