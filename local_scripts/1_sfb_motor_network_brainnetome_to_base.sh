#! /bin/bash
#set -e # EXIT ON ERROR

project=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS
SUBJECTS_DIR=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS/derivatives/FREESURFER_T1_DC
export BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS ###### CHECK BIDS_dir

i=0

participants_list=$BIDS_dir/control_participants_single.tsv


#number=$(cat /home/users/frey/sfb_motor_network/subject_list_split | wc -w)
number=$(cat $participants_list | wc -w)

#for sub in $(cat /home/users/frey/sfb_motor_network/subject_list_split); do
#for sub in $(cat $project/participants_single.tsv); do
for sub in $(cat $participants_list); do

Subject=${sub}_base

let i=i+1

echo "======================================================================> $Subject $i / $number <=======================================================================" 


### mapping BN_atlas cortex to subjects Freesurfer space

if [ -e $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -a -e $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz ]; then echo "$Subject: Check"; else
	#if [ ! -e $SUBJECTS_DIR/$Subject/fs_orig.nii.gz ]; then echo $Subject >> $project/no_base; continue; fi
	
	mris_ca_label -l $SUBJECTS_DIR/$Subject/label/lh.cortex.label $Subject lh $SUBJECTS_DIR/$Subject/surf/lh.sphere.reg $SUBJECTS_DIR/lh.BN_Atlas.gcs $SUBJECTS_DIR/$Subject/label/lh.BN_Atlas.annot
	mris_ca_label -l $SUBJECTS_DIR/$Subject/label/rh.cortex.label $Subject rh $SUBJECTS_DIR/$Subject/surf/rh.sphere.reg $SUBJECTS_DIR/rh.BN_Atlas.gcs $SUBJECTS_DIR/$Subject/label/rh.BN_Atlas.annot

	mri_label2vol --annot $SUBJECTS_DIR/$Subject/label/lh.BN_Atlas.annot --identity --proj frac 0 0.5 0.1 --subject $Subject --hemi lh --surf white --o $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.mgz --temp $SUBJECTS_DIR/$Subject/mri/brainmask.mgz
	mri_label2vol --annot $SUBJECTS_DIR/$Subject/label/rh.BN_Atlas.annot --identity --proj frac 0 0.5 0.1 --subject $Subject --hemi rh --surf white --o $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.mgz --temp $SUBJECTS_DIR/$Subject/mri/brainmask.mgz

	mri_convert $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.mgz $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz --out_orientation RAS
	mri_convert $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.mgz $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz --out_orientation RAS

fi

###  generating map with only sulcal structures

min=-0.125
min_name=-0125

	if [ -e $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.nii.gz -a -e $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh_sulc_${min_name}.nii.gz ]; then echo "$Subject: Check"; else		
		if [ -e $SUBJECTS_DIR/$Subject/surf/lh.curv -a -e $SUBJECTS_DIR/$Subject/surf/rh.curv ]; then
			
			# Binarize Curvature file with minimum concave (i.e. max convex) of min
			mri_binarize --i $SUBJECTS_DIR/$Subject/surf/lh.curv --min ${min} --o $SUBJECTS_DIR/$Subject/surf/LH_sulc_${min_name}.mgz
			mri_binarize --i $SUBJECTS_DIR/$Subject/surf/rh.curv --min ${min} --o $SUBJECTS_DIR/$Subject/surf/RH_sulc_${min_name}.mgz

			# Transform this surface to a volume within certrain boundaries (projfrac)
			mri_surf2vol --surfval $SUBJECTS_DIR/$Subject/surf/LH_sulc_${min_name}.mgz --hemi lh --fill-projfrac -1 1.5 0.1 --identity $Subject --template $SUBJECTS_DIR/$Subject/mri/brainmask.mgz --o $SUBJECTS_DIR/$Subject/surf/LH_sulc_${min_name}_vol.mgz
			mri_surf2vol --surfval $SUBJECTS_DIR/$Subject/surf/RH_sulc_${min_name}.mgz --hemi rh --fill-projfrac -1 1.5 0.1 --identity $Subject --template $SUBJECTS_DIR/$Subject/mri/brainmask.mgz --o $SUBJECTS_DIR/$Subject/surf/RH_sulc_${min_name}_vol.mgz
			
			# Mask the BN-Atlas Volume with the volume file of the sulci
			mri_mask $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.mgz $SUBJECTS_DIR/$Subject/surf/LH_sulc_${min_name}_vol.mgz $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.mgz
			mri_mask $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.mgz $SUBJECTS_DIR/$Subject/surf/RH_sulc_${min_name}_vol.mgz $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh_sulc_${min_name}.mgz

			# Convert to FSL-format to check
			#mriconvert $SUBJECTS_DIR/$Subject/surf/LH_sulc_${min_name}_vol.mgz $SUBJECTS_DIR/$Subject/surf/LH_sulc_${min_name}_vol.nii.gz
			#mriconvert $SUBJECTS_DIR/$Subject/surf/RH_sulc_${min_name}_vol.mgz $SUBJECTS_DIR/$Subject/surf/RH_sulc_${min_name}_vol.nii.gz
						
			# Convert to FSL-format
			mri_convert $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh_sulc_${min_name}.mgz $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh_sulc_${min_name}.nii.gz --out_orientation RAS
			mri_convert $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.mgz $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.nii.gz --out_orientation RAS
		
		else echo $Subject >> $project/no_curve 
		fi
	fi

done
