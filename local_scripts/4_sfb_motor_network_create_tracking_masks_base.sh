#! /bin/bash
#set -e # EXIT ON ERROR

BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS
SUBJECTS_DIR=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS/derivatives/FREESURFER_T1_DC
LOG_dir=$BIDS_dir/log

i=0
participants_list=$BIDS_dir/control_participants_single.tsv




number=$(cat $participants_list | wc -w)
min_name=-0125 # Binarize Curvature file with minimum concave (i.e. max convex) of min


for sub in $(cat $participants_list); do
Subject=${sub}_base
let i=i+1


echo "======================================================================> $Subject $i / $number <=======================================================================" 
	
	SUBJECT_dir=$BIDS_dir/derivatives/FS_base/$sub
	FIRST_dir=$SUBJECT_dir/sub-${sub}_fs_orig.anat/first_results

	########### Check QA-reports ############
	for sequence in data anat t1 dwi; do           									#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<#         
		for LOG in $(cat $LOG_dir/qa/no_${sequence}); do
			case $LOG in *"${sub}"*) echo "Known missing ${sequence} data for Subject Nr. ${sub}"; continue 3 ;; esac
		done
		
		for LOG in $(cat $LOG_dir/qa/bad_${sequence}); do
			case $LOG in *"${sub}"*) echo "Known bad ${sequence} data for Subject Nr. ${sub}"; continue 3 ;; esac
		done
	done
	#########################################

	if [ ! -e $BIDS_dir/derivatives/FS_base/$sub/sub-${sub}_fs_orig.nii.gz ]; then echo $Subject >> $BIDS_dir/no_base_2; continue; fi

	##### Waiting Block #####
	time=0
	while [ ! -e $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.nii.gz -a ! -e $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz ]; do
		sleep 30
		time=$((time+30))
		minutes=$((time/60))
		echo "Waiting since " $minutes "minutes now..."
		if [ $minutes -gt 120 ]; then echo $Subject >> $BIDS_dir/waiting_to_long; continue 2; fi
	done
	#########################
		
	echo "Ready for Generating Tracking Masks"
	mkdir -p $SUBJECT_dir/tracking_masks
	
	if [ -e $SUBJECT_dir/tracking_masks/RH_pre_SMA_temp.nii.gz -a -e $SUBJECT_dir/tracking_masks/RH_M1_temp.nii.gz ]; then echo "Ready for 500"; else
		
		# LH_PMV
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 63 -uthr 64 $SUBJECT_dir/tracking_masks/LH_PMV_temp.nii.gz

		# RH_PMV
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 64 -uthr 65 $SUBJECT_dir/tracking_masks/RH_PMV_temp.nii.gz
		
		
		# LH_SMA
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 9 -uthr 10 -bin $SUBJECT_dir/tracking_masks/LH_SMA_temp.nii.gz
	
		# RH_SMA
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 10 -uthr 11 -bin $SUBJECT_dir/tracking_masks/RH_SMA_temp.nii.gz
		
		
		# LH_dPMC
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 55 -uthr 56 $SUBJECT_dir/tracking_masks/LH_dPMC_temp.nii.gz
		
		# RH_dPMC
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 56 -uthr 57 $SUBJECT_dir/tracking_masks/RH_dPMC_temp.nii.gz
	
		
		# LH_S1
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 155 -uthr 156 -bin $SUBJECT_dir/tracking_masks/LH_S1_temp.nii.gz
		
		# RH_S1
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 156 -uthr 157 -bin $SUBJECT_dir/tracking_masks/RH_S1_temp.nii.gz

		
		# LH_pre_SMA
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 1 -uthr 2 $SUBJECT_dir/tracking_masks/LH_pre_SMA_temp.nii.gz
					
		# RH_pre_SMA
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 2 -uthr 3 $SUBJECT_dir/tracking_masks/RH_pre_SMA_temp.nii.gz

		
		# LH_M1
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 53 -uthr 54 $SUBJECT_dir/tracking_masks/LH_M1_temp_1.nii.gz
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh.nii.gz -thr 57 -uthr 58 $SUBJECT_dir/tracking_masks/LH_M1_temp_2.nii.gz
		fslmaths $SUBJECT_dir/tracking_masks/LH_M1_temp_1.nii.gz -add $SUBJECT_dir/tracking_masks/LH_M1_temp_2.nii.gz -bin $SUBJECT_dir/tracking_masks/LH_M1_temp.nii.gz

		# RH_M1
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 54 -uthr 55 $SUBJECT_dir/tracking_masks/RH_M1_temp_1.nii.gz
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh.nii.gz -thr 58 -uthr 59 $SUBJECT_dir/tracking_masks/RH_M1_temp_2.nii.gz
		fslmaths $SUBJECT_dir/tracking_masks/RH_M1_temp_1.nii.gz -add $SUBJECT_dir/tracking_masks/RH_M1_temp_2.nii.gz -bin $SUBJECT_dir/tracking_masks/RH_M1_temp.nii.gz
	fi
	if [ -e $SUBJECT_dir/tracking_masks/RH_cIPS_temp.nii.gz -a -e $SUBJECT_dir/tracking_masks/LH_cIPS_temp.nii.gz ]; then echo "Ready for 500 II"; else
				
		# LH_aIPS
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.nii.gz -bin $SUBJECT_dir/tracking_masks/LH_aIPS_temp.nii.gz
	
		# RH_aIPS
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh_sulc_${min_name}.nii.gz -bin $SUBJECT_dir/tracking_masks/RH_aIPS_temp.nii.gz

		
		# LH_cIPS
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_lh_sulc_${min_name}.nii.gz -bin $SUBJECT_dir/tracking_masks/LH_cIPS_temp.nii.gz

		# RH_cIPS
		fslmaths $SUBJECTS_DIR/$Subject/mri/BN_atlas_rh_sulc_${min_name}.nii.gz -bin $SUBJECT_dir/tracking_masks/RH_cIPS_temp.nii.gz
	
	fi

	for coord in LH_aIPS LH_cIPS LH_M1 LH_PMV LH_SMA RH_aIPS RH_cIPS RH_M1 RH_PMV RH_SMA LH_dPMC LH_S1 LH_pre_SMA RH_dPMC RH_S1 RH_pre_SMA; do
		
		if [ -e $SUBJECT_dir/tracking_masks/${coord}_500.nii.gz ]; then
			
			volume_temp=$(fslstats $SUBJECT_dir/tracking_masks/${coord}_500.nii.gz -V)
			volume=${volume_temp:0:3}
			echo "${coord} is ready for Tracking, size is $volume voxels"
			
			if [ "$volume" -ne "500" ]; then echo "$Subject	$coord	$volume" >> $BIDS_dir/not_500;	fi
			
		else
			if [ ! -e $SUBJECT_dir/tracking_masks/${coord}_temp.nii.gz ]; then echo $coord >> $BIDS_dir/missing_temp; fi
			
			inate=$(cat $SUBJECT_dir/coord/$coord)
			matlab -nodesktop -nosplash -r "NearestVoxelsMask('$SUBJECT_dir/tracking_masks/${coord}_temp.nii.gz',[$inate]',0.1,500,'$SUBJECT_dir/tracking_masks/${coord}_500.nii.gz');exit;"
		
			volume_temp=$(fslstats $SUBJECT_dir/tracking_masks/${coord}_500.nii.gz -V)
			volume=${volume_temp:0:3}
			echo "${coord} is ready for Tracking, size is $volume voxels"
			
			if [ "$volume" -ne "500" ]; then echo "$Subject	$coord	$volume" >> $BIDS_dir/not_500;	fi
				
		fi
	done 

	if [ ! -e $FIRST_dir/T1_first_all_fast_firstseg.nii.gz ]; then echo "$Subject" >> $BIDS_dir/no_first; else
	
		LH_Caud=11
		LH_Thal=10
		LH_Pall=13
		LH_Puta=12
		RH_Caud=50
		RH_Thal=49
		RH_Pall=52
		RH_Puta=51
		
		for mask in LH_Caud LH_Thal LH_Pall LH_Puta RH_Caud RH_Thal RH_Pall RH_Puta; do
			if [ -e $SUBJECT_dir/tracking_masks/${mask}_temp.nii.gz ]; then continue; fi
			fslmaths $FIRST_dir/T1_first_all_fast_firstseg.nii.gz -thr ${!mask} -uthr ${!mask} -bin $SUBJECT_dir/tracking_masks/${mask}_temp.nii.gz
			echo "${mask} is ready for Tracking"
		done	
	
		for hemi in L R; do 
			if [ -e $SUBJECT_dir/tracking_masks/${hemi}H_Lenti_temp.nii.gz ]; then continue; fi

			fslmaths $SUBJECT_dir/tracking_masks/${hemi}H_Puta_temp.nii.gz -add $SUBJECT_dir/tracking_masks/${hemi}H_Pall_temp.nii.gz -bin $SUBJECT_dir/tracking_masks/${hemi}H_Lenti_temp.nii.gz
		done
		
		if [ ! -e $SUBJECT_dir/tracking_masks/Brainstem_temp.nii.gz ]; then fslmaths $FIRST_dir/T1_first_all_fast_firstseg.nii.gz -thr 16 -uthr 16 -bin $SUBJECT_dir/tracking_masks/Brainstem_temp.nii.gz; fi
		
	fi

done
