#/bin/bash
set -e
export BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS ###### CHECK BIDS_dir
export BASE_dir=$BIDS_dir/derivatives/FS_base
export LOG_dir=$BIDS_dir/log
export QA_dir=$LOG_dir/qa

i=0


for sub in $(cat $BIDS_dir/all_participants.tsv); do
#for sub in ca_001_1; do
echo $sub

	for sequence in data dwi anat t1; do          
			for LOG in $(cat $LOG_dir/qa/no_${sequence}); do
				case $LOG in *"${sub}"*) echo "Known missing ${sequence} data for Subject Nr. ${sub}"; continue 4 ;; esac
			done
			
			for LOG in $(cat $LOG_dir/qa/bad_${sequence}); do
				case $LOG in *"${subject}"*) echo "Known bad ${sequence} data for Subject Nr. ${sub}"; continue 4 ;; esac
			done
	done
	
	export SUB_dir=$BIDS_dir/sub-$sub
	export ANAT_dir=$SUB_dir/anat
	export DWI_dir=$SUB_dir/dwi
	export SUB_LOG_dir=$SUB_dir/log
	export TRANSFORM_dir=$SUB_dir/dwi/transform_base

	[ ! -e $TRANSFORM_dir/tracking_masks ] && echo ALARM && continue
	
	i=0
	
	cd $TRANSFORM_dir/tracking_masks
	for mask in *final.nii.gz;do

		[ "$mask" == "LH_Lenti_final.nii.gz" ] && continue
		[ "$mask" == "RH_Lenti_final.nii.gz" ] && continue

		let i=i+1
		echo "$i $mask" >> $TRANSFORM_dir/assignments.tsv
		 
		[ ! -e nodes.nii.gz ] && fslmaths $mask -mul 0 nodes.nii.gz
		fslmaths nodes.nii.gz -bin -mul $mask intersec.nii.gz
		fslmaths $mask -sub intersec.nii.gz mask_temp.nii.gz
		fslmaths mask_temp.nii.gz -mul $i temp.nii.gz
		fslmaths nodes.nii.gz -add temp.nii.gz nodes.nii.gz
		
	done

	[ -e intersec.nii.gz ] && rm intersec.nii.gz
	[ -e mask_temp.nii.gz ] && rm mask_temp.nii.gz
	[ -e temp.nii.gz ] && rm temp.nii.gz
	
	tck2connectome $TRANSFORM_dir/tractogram.tck nodes.nii.gz $TRANSFORM_dir/connectome.csv -force -tck_weights_in $TRANSFORM_dir/weights.csv -zero_diagonal -symmetric
	
		
		
done
