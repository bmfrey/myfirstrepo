#/bin/bash
set -e
export BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS  ###### CHECK BIDS_dir
export BASE_dir=$BIDS_dir/derivatives/FS_base
export LOG_dir=$BIDS_dir/log
export QA_dir=$LOG_dir/qa

i=0

#for sub in $(cat $BIDS_dir/participants.tsv); do
for sub in $(cat $BIDS_dir/all_participants_single.tsv); do
#for sub in $(cat $BIDS_dir/control_participants); do

echo $sub
	export SUB_dir=$BIDS_dir/sub-$sub
	export ANAT_dir=$SUB_dir/anat
	export DWI_dir=$SUB_dir/dwi
	export SUB_LOG_dir=$SUB_dir/log
	#[ ! -e $SUB_LOG_dir ] && mkdir $SUB_LOG_dir
	
	for time in 1 2 3 4; do 
		subject=${sub}_${time}

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
		export MASK_dir=$BASE_dir/$sub/tracking_masks
		export OUTMASK_dir=$TRANSFORM_dir/tracking_masks
			[ ! -e $OUTMASK_dir ] && mkdir $OUTMASK_dir
		
		transform=$TRANSFORM_dir/rigid_T1_to_DWI.txt
		#template=$TRANSFORM_dir/sub-${subject}_dwi_meanbzero_111.nii.gz ### ODER b0_distcor?
		template=$SUBJECT_dir/dwi/sub-${subject}_dwi_meanbzero.nii.gz


			for startmask in $(cat $BIDS_dir/code/tracking_masks_cort); do
						
				inmask=$MASK_dir/$startmask"_500.nii.gz"
				#echo $inmask
				outmask=$OUTMASK_dir/$startmask"_final.nii.gz"
				thr=0.5

				if [ -e $outmask ]; then continue; fi
				if [ ! -e $inmask ]; then echo "$subject $startmask" >> $LOG_dir/qa/no_startmask; continue; fi
						
				echo "================> Calculating cortical mask $startmask with threshold $thr <========================"
				
				flirt -in $inmask -ref $template -applyxfm -init $transform -out $outmask && fslmaths $outmask -thr $thr -bin $outmask &

				#mrtransform -force -linear $transform $inmask $outmask -template $template
				#fslmaths $outmask -thr $thr -bin $outmask
			
			done	
			wait
			for startmask in $(cat $BIDS_dir/code/tracking_masks_sub); do
				
				inmask=$MASK_dir/$startmask"_temp.nii.gz"
				#echo $inmask
				outmask=$OUTMASK_dir/$startmask"_final.nii.gz"
				thr=0.5

				if [ -e $outmask ]; then continue; fi
				if [ ! -e $inmask ]; then echo "$subject $startmask" >> $LOG_dir/qa/no_startmask; continue; fi
						
				echo "================> Calculating subcortical mask $startmask with threshold $thr <========================"
				
				flirt -in $inmask -ref $template -applyxfm -init $transform -out $outmask && fslmaths $outmask -thr $thr -bin $outmask &
				#mrtransform -force -linear $transform $inmask $outmask -template $template
				#fslmaths $outmask -thr $thr -bin $outmask
					
			done
			wait
			
			
			
			

	done

done
