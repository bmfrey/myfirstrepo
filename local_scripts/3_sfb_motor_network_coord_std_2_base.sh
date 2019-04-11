#! /bin/bash
#set -e # EXIT ON ERROR

BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS
SUBJECTS_DIR=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS/derivatives/FREESURFER_T1_DC

i=0
participants_list=$BIDS_dir/control_participants_single.tsv




number=$(cat $participants_list | wc -w)
min_name=-0125 # Binarize Curvature file with minimum concave (i.e. max convex) of min


for sub in $(cat $participants_list); do
#for sub in pa_026; do
Subject=${sub}
let i=i+1



echo "======================================================================> $Subject $i / $number <=======================================================================" 

	SUB_dir=$BIDS_dir/derivatives/FS_base/$sub
	fsl_anat_dir=$SUB_dir/sub-${sub}_fs_orig.anat

	mkdir -p $SUB_dir/coord

	if [ ! -e $SUB_dir/sub-${sub}_fs_orig.nii.gz ]; then echo $Subject >> $BIDS_dir/no_base; continue; fi
		
	##### Waiting Block #####
	time=0
	while [ ! -e $fsl_anat_dir/T1_to_MNI_nonlin.nii.gz -a ! -e $fsl_anat_dir/T1_to_MNI_nonlin_field.nii.gz ]; do
		sleep 30
		time=$((time+30))
		minutes=$((time/60))
		echo "Waiting since " $minutes "minutes now..."
		if [ $minutes -gt 120 ]; then echo $ Subject >> $BIDS_dir/waiting_to_long; continue 2; fi
	done
	#########################
	
	
	#### Koordinaten von Schulz et. al, Stroke 2016
	LH_aIPS="-36 -44 54"
	LH_cIPS="-20 -62 52"
	LH_M1="-36 -20 52"
	LH_PMV="-52 6 30"
	LH_SMA="-2 -4 56"
	RH_aIPS="36 -44 54"
	RH_cIPS="20 -62 52"
	RH_M1="36 -20 52"
	RH_PMV="52 6 30"
	RH_SMA="2 -4 56"
	## Koordinaten aus Rehme 2010
	LH_dPMC="-42 -10 58"
	LH_S1="-36 -30 60"
	LH_pre_SMA="-2 6 54"
	RH_dPMC="42 -6 56"
	RH_S1="40 -28 52"
	RH_pre_SMA="2 2 56"

	for coord in LH_aIPS LH_cIPS LH_M1 LH_PMV LH_SMA RH_aIPS RH_cIPS RH_M1 RH_PMV RH_SMA LH_dPMC LH_S1 LH_pre_SMA RH_dPMC RH_S1 RH_pre_SMA; do ## alle
	#for coord in LH_aIPS LH_cIPS LH_M1 LH_PMV LH_SMA RH_aIPS RH_cIPS RH_M1 RH_PMV RH_SMA; do ## Robert
	#for coord in LH_dPMC LH_S1 LH_pre_SMA RH_dPMC RH_S1 RH_pre_SMA; do ## Rehme
		echo -n $coord 
		echo -n " is "
		echo -n ${!coord}

		echo `echo ${!coord} | std2imgcoord -img $SUB_dir/sub-${sub}_fs_orig.nii.gz -std $fsl_anat_dir/T1_to_MNI_nonlin.nii.gz -warp $fsl_anat_dir/T1_to_MNI_nonlin_field.nii.gz -` > $SUB_dir/coord/$coord
		
		echo -n "; and is transformed to "
		echo $(cat $SUB_dir/coord/$coord)
	done
done
