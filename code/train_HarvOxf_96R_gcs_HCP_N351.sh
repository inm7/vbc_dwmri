#!/bin/bash

# train_HarvOxf_96R_gcs_HCP_N351
# ------------------------------
# sbj=101309
grp=HCP
sbj=${1}
fp=/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Tools/freesurfer/subjects
ap=/p/project/cjinm71/SC_Pipe_jung3/Neuroimage/Atlas
tp=/p/scratch/cjinm71/jung3/03_Structural_Connectivity
atl=HarvardOxford/HarvardOxford-cortl-maxprob-thr0-1mm.nii.gz
tmp=${tp}/${grp}/${sbj}/temp

mri_convert ${fp}/${grp}_${sbj}/mri/brain.mgz ${tmp}/fs_t1_brain.nii.gz

flirt -ref ${mni_brain} -in ${tmp}/fs_t1_brain.nii.gz -omat ${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat -dof 6
fnirt --in=${tmp}/fs_t1_brain.nii.gz --aff=${tp}/${grp}/${sbj}/fs_t1_to_mni_affine.mat --cout=${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --config=T1_2_MNI152_2mm
invwarp --ref=${tmp}/fs_t1_brain.nii.gz --warp=${tp}/${grp}/${sbj}/fs_t1_to_mni_warp_struct.nii.gz --out=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz
applywarp --ref=${tmp}/fs_t1_brain.nii.gz --in=${ap}/${atl} --warp=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --out=${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz --interp=nn
# applywarp --ref=${tp}/${grp}/${sbj}/fs_t1_brain.nii.gz --in=${ap}/${atl} --out=${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz --warp=${tp}/${grp}/${sbj}/mni_to_fs_t1_warp_struct.nii.gz --interp=nn

# fslreorient2std -m reori_fs_t1.mat ${tmp}/fs_t1_brain.nii.gz
# convert_xfm -omat reori_fs_t1_inv.mat -inverse reori_fs_t1.mat
# applywarp -i HO_to_fs_t1.nii.gz -r temp_ref.nii.gz -o HO_to_fs_t1.nii.gz --premat=reori_fs_t1_inv.mat --interp=nn 

mri_convert ${tp}/${grp}/${sbj}/HO_to_fs_t1.nii.gz ${fp}/${grp}_${sbj}/mri/HarvardOxford_96R.mgz 
mris_sample_parc -ct ${ap}/HO_R96_color_table.txt -sdir ${fp} ${grp}_${sbj} rh HarvardOxford_96R.mgz rh.HarvardOxford_96R.annot
mris_sample_parc -ct ${ap}/HO_R96_color_table.txt -sdir ${fp} ${grp}_${sbj} lh HarvardOxford_96R.mgz lh.HarvardOxford_96R.annot
