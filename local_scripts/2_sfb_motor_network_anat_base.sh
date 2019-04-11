#! /bin/bash
#set -e # EXIT ON ERROR

BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS
SUBJECTS_DIR=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS/derivatives/FREESURFER_T1_DC
i=0

participants_list=$BIDS_dir/control_participants_single.tsv




number=$(cat $participants_list | wc -w)

for sub in $(cat $participants_list); do
#for sub in pa_026; do
Subject=${sub}_base

let i=i+1

echo "======================================================================> $Subject $i / $number <=======================================================================" 
		
	SUB_dir=$BIDS_dir/derivatives/FS_base/$sub
	
	mkdir -p $SUB_dir
	
	mri_convert $SUBJECTS_DIR/$Subject/mri/orig.mgz -o $SUB_dir/sub-${sub}_fs_orig.nii.gz --out_orientation RAS
	
	fsl_anat -i $SUB_dir/sub-${sub}_fs_orig.nii.gz --nocrop 
	
done
