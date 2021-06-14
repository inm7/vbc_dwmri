#!/bin/bash
SC_module=${1}
sbj01=${2}
sbj02=${3}
sbj03=${4}
sbj04=${5}
sbj05=${6}
sbj06=${7}
sbj07=${8}
sbj08=${9}

simg_path=/path/to/container/Container_dwMRI.simg
wp=/mnt_sc/path/to/scripts
mnt=/local/path/to/mount

case ${SC_module} in
	Preprocess )
		# Part 1: Preprocessing
		# ---------------------
		simg_arg1=/usr/local/bin/container_SC_preprocess.sh

		simg_arg2=${wp}/input_${sbj01}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj02}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj03}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj04}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj05}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj06}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj07}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F000000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj08}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0000000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &
		wait
		;;

	Tractography )
		# Part 2: Tractography
		# --------------------
		simg_arg1=/usr/local/bin/container_SC_tractography.sh

		simg_arg2=${wp}/input_${sbj01}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj02}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj03}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj04}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj05}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj06}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj07}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj08}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait
		;;

	Atlas_transformation)
		# Part 3: Atlas transformation
		# ----------------------------
		simg_arg1=/usr/local/bin/container_SC_atlas_transformation.sh

		simg_arg2=${wp}/input_${sbj01}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj02}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj03}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj04}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj05}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj06}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj07}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0x3F000000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &

		simg_arg2=${wp}/input_${sbj08}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFC0000000000 singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2} &
		wait
		;;

	Reconstruction )
		# Part 4: Reconstruct
		# -------------------
		simg_arg1=/usr/local/bin/container_SC_reconstruct.sh

		simg_arg2=${wp}/input_${sbj01}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj02}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj03}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj04}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj05}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj06}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj07}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait

		simg_arg2=${wp}/input_${sbj08}.txt
		printf "${SC_module}: ${simg_path} ${simg_arg1} ${simg_arg2}\n"
		srun --exclusive -N 1 -n 1 --cpu-bind=mask_cpu:0xFFFFFFFFFFFF singularity exec --bind ${mnt}:/mnt_sc ${simg_path} ${simg_arg1} ${simg_arg2}
		wait
		;;
esac
