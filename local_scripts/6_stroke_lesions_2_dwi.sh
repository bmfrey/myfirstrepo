#/bin/bash
set -e
export BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS ###### CHECK BIDS_dir
[ ! -f $BIDS_dir ] && export BIDS_dir
export BASE_dir=$BIDS_dir/derivatives/FS_base
export LOG_dir=$BIDS_dir/log
export QA_dir=$LOG_dir/qa

i=0

#for sub in $(cat $BIDS_dir/participants.tsv); do
for sub in $(cat $BIDS_dir/all_participants_single.tsv); do
#for sub in pa_019; do
#for sub in $(cat $BIDS_dir/control_participants); do
echo $sub

if [ "$sub" == "pa_019" ]; then

##### Waiting Block #####
	time=0
	while [ ! -e /mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS/sub-pa_019_1/anat/sub-pa_019_1_FLAIR_BrainExtractionBrain.nii.gz ]; do
		sleep 30
		time=$((time+30))
		minutes=$((time/60))
		echo "Waiting since " $minutes "minutes now..."
	done
	#########################


fi


	export SUB_dir=$BIDS_dir/sub-$sub
	export ANAT_dir=$SUB_dir/anat
	export DWI_dir=$SUB_dir/dwi
	export SUB_LOG_dir=$SUB_dir/log
	
	for sequence in data dwi anat t1 flair; do          
			for LOG in $(cat $LOG_dir/qa/no_${sequence}); do
				case $LOG in *"${sub}_1"*) echo "Known missing ${sequence} data for Subject Nr. ${sub}"; continue 4 ;; esac
			done
			
			for LOG in $(cat $LOG_dir/qa/bad_${sequence}); do
				case $LOG in *"${subject}_1"*) echo "Known bad ${sequence} data for Subject Nr. ${sub}"; continue 4 ;; esac
			done
	done
	
	
	for time in 1; do 
		subject=${sub}_${time}

		for sequence in data dwi anat t1 flair; do          
			for LOG in $(cat $LOG_dir/qa/no_${sequence}); do
				case $LOG in *"${subject}"*) echo "Known missing ${sequence} data for Subject Nr. ${subject}"; continue 4 ;; esac
			done
			
			for LOG in $(cat $LOG_dir/qa/bad_${sequence}); do
				case $LOG in *"${subject}"*) echo "Known bad ${sequence} data for Subject Nr. ${subject}"; continue 4 ;; esac
			done
		done
		
		export SUBJECT_dir=$BIDS_dir/sub-$subject
			[ ! -e $SUBJECT_dir ] && continue
		export TRANSFORM_dir=$SUBJECT_dir/dwi/transform_base
		
		#[ -e $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI_bin.nii.gz ] && continue
		
		mkdir -p $SUBJECT_dir/anat/transform
		
		flair_file=$SUBJECT_dir/anat/sub-${subject}_FLAIR.nii.gz
		flair_brain=$SUBJECT_dir/anat/sub-${subject}_FLAIR_BrainExtractionBrain.nii.gz
		flair_brain_mask=$SUBJECT_dir/anat/sub-${subject}_FLAIR_BrainExtractionMask.nii.gz
		
		lesion_file=$SUBJECT_dir/anat/sub-${subject}_FLAIR_lesion_mask.nii.gz
		
		t1_file=$SUBJECT_dir/anat/sub-${subject}_DC_T1w_in_base.nii.gz
		t1_brain_mask=$SUBJECT_dir/anat/sub-${subject}_DC_T1w_in_base_BrainExtractionMask.nii.gz
		t1_brain=$SUBJECT_dir/anat/sub-${subject}_DC_T1w_in_base_BrainExtractionBrain.nii.gz
		
		transform_t1_2_dwi=$TRANSFORM_dir/rigid_T1_to_DWI.txt
		transform_flair_2_t1=$SUBJECT_dir/anat/transform/rigid_FLAIR_to_T1.txt
		transform_flair_2dwi=$SUBJECT_dir/anat/transform/rigid_FLAIR_to_DWI.txt

		#mrregister -force ${flair_brain} ${t1_brain} -type rigid -rigid ${transform_flair_2_t1}
		flirt -in ${flair_brain} -ref ${t1_brain} -omat $SUBJECT_dir/anat/transform/flair_2_t1_fsl.mat
		
		flirt -in ${flair_file} -out $SUBJECT_dir/anat/transform/sub-${subject}_FLAIR_in_T1.nii.gz -applyxfm -init $SUBJECT_dir/anat/transform/flair_2_t1_fsl.mat -ref ${t1_file}
		flirt -in ${lesion_file} -out $SUBJECT_dir/anat/transform/sub-${subject}_lesion_in_T1.nii.gz -applyxfm -init $SUBJECT_dir/anat/transform/flair_2_t1_fsl.mat -ref ${t1_file}
		
		#mrtransform -force ${flair_file} $SUBJECT_dir/anat/transform/sub-${subject}_FLAIR_in_T1.nii.gz -linear ${transform_flair_2_t1} -template ${t1_file}
		#mrtransform -force $SUBJECT_dir/anat/transform/sub-${subject}_FLAIR_in_T1.nii.gz $TRANSFORM_dir/sub-${subject}_FLAIR_rigid_DWI.nii.gz -linear $transform_t1_2_dwi -template $TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz
		flirt -in $SUBJECT_dir/anat/transform/sub-${subject}_FLAIR_in_T1.nii.gz -ref $TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz -applyxfm -init $transform_t1_2_dwi -out $TRANSFORM_dir/sub-${subject}_FLAIR_rigid_DWI.nii.gz

		 		
		#mrtransform -force ${lesion_file} $SUBJECT_dir/anat/transform/sub-${subject}_lesion_in_T1.nii.gz -linear ${transform_flair_2_t1} -template ${t1_file}
		#mrtransform -force $SUBJECT_dir/anat/transform/sub-${subject}_lesion_in_T1.nii.gz $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI.nii.gz -linear $transform_t1_2_dwi -template $TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz
		flirt -in $SUBJECT_dir/anat/transform/sub-${subject}_lesion_in_T1.nii.gz -ref $TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz -applyxfm -init $transform_t1_2_dwi -out $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI.nii.gz


		fslmaths $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI.nii.gz -thr 0.5 -bin $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI_bin.nii.gz

		#[ -e $TRANSFORM_dir/sub-${sub}_FLAIR_rigid_DWI.nii.gz ] && rm $TRANSFORM_dir/sub-${sub}_FLAIR_rigid_DWI.nii.gz
		#[ -e $TRANSFORM_dir/sub-${sub}_lesion_rigid_DWI.nii.gz ] && rm $TRANSFORM_dir/sub-${sub}_lesion_rigid_DWI.nii.gz
		#[ -e $TRANSFORM_dir/sub-${sub}_lesion_rigid_DWI_bin.nii.gz ] && rm $TRANSFORM_dir/sub-${sub}_lesion_rigid_DWI_bin.nii.gz

	done

	
	for time in 2 3 4; do 
		subject=${sub}_${time}

		for sequence in flair; do          
			for LOG in $(cat $LOG_dir/qa/no_${sequence}); do
				case $LOG in *"${sub}"*) echo "Known missing ${sequence} data for Subject Nr. ${sub}"; continue 3 ;; esac
			done
			
			for LOG in $(cat $LOG_dir/qa/bad_${sequence}); do
				case $LOG in *"${sub}"*) echo "Known bad ${sequence} data for Subject Nr. ${sub}"; continue 3 ;; esac
			done
		done
		
		
		for sequence in data dwi anat t1; do          
			for LOG in $(cat $LOG_dir/qa/no_${sequence}); do
				case $LOG in *"${subject}"*) echo "Known missing ${sequence} data for Subject Nr. ${subject}"; continue 3 ;; esac
			done
			
			for LOG in $(cat $LOG_dir/qa/bad_${sequence}); do
				case $LOG in *"${subject}"*) echo "Known bad ${sequence} data for Subject Nr. ${subject}"; continue 3 ;; esac
			done
		done
		
		
		export SUBJECT_dir=$BIDS_dir/sub-$subject
			[ ! -e $SUBJECT_dir ] && continue
		export TRANSFORM_dir=$SUBJECT_dir/dwi/transform_base

		[ -e $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI_bin.nii.gz ] && continue
		#mrtransform -force $BIDS_dir/sub-${sub}_1/anat/transform/sub-${sub}_1_lesion_in_T1.nii.gz $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI.nii.gz -linear $TRANSFORM_dir/rigid_T1_to_DWI.txt -template $TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz
		flirt -in $BIDS_dir/sub-${sub}_1/anat/transform/sub-${sub}_1_lesion_in_T1.nii.gz -ref $TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz -applyxfm -init $TRANSFORM_dir/rigid_T1_to_DWI.txt -out $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI.nii.gz && fslmaths $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI.nii.gz -thr 0.5 -bin $TRANSFORM_dir/sub-${subject}_lesion_rigid_DWI_bin.nii.gz &

	done
	wait	
done
