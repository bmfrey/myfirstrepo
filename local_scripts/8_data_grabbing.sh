#/bin/bash
set -e
export BIDS_dir=/mnt/Storage/bene/EXTERN/UHHWORK/data/SFB_BIDS ###### CHECK BIDS_dir
export BASE_dir=$BIDS_dir/derivatives/FS_base
export LOG_dir=$BIDS_dir/log
export QA_dir=$LOG_dir/qa

i=0


export_file=$BIDS_dir/log/motor_network_BH

[ -e $export_file ] && rm $export_file



for sub in $(cat $BIDS_dir/all_participants_single.tsv); do
#for sub in ca_001_1; do
echo $sub

	group=$(echo $sub | head -c 2)
	
	
	
	for time in 1 2 3 4; do 
		subject=${sub}_${time}
		
		for sequence in data dwi anat t1; do          
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

		echo $time

		graph_array=( $(cat $TRANSFORM_dir/temp/Cc_B_Ef_B_LoEf_B_Cc_Ef_LoEf_Q_As_De_Ew_max_Ew_median_Ew_mean_St_mean_St_median_St_sum_Cc_rand_std_Ef_rand_std_LoEf_rand_std.csv) )
		Cc_B=${graph_array[0]}
		Ef_B=${graph_array[1]}
		LoEf_B=${graph_array[2]}
		Cc=${graph_array[3]}
		Ef=${graph_array[4]}
		LoEf=${graph_array[5]}
		Q=${graph_array[6]}
		As=${graph_array[7]}
		De=${graph_array[8]}
		Ew_max=${graph_array[9]}
		Ew_median=${graph_array[10]}
		Ew_mean=${graph_array[11]}
		St_mean=${graph_array[12]}
		St_median=${graph_array[13]}
		St_sum=${graph_array[14]}
		Cc_rand_std=${graph_array[15]}
		Ef_rand_std=${graph_array[16]}
		LoEf_rand_std=${graph_array[17]}
		
		graph_array_LH=( $(cat $TRANSFORM_dir/temp/Cc_B_Ef_B_LoEf_B_Cc_Ef_LoEf_Q_As_De_Ew_max_Ew_median_Ew_mean_St_mean_St_median_St_sum_Cc_rand_std_Ef_rand_std_LoEf_rand_std_LH.csv) )
		Cc_B_LH=${graph_array_LH[0]}
		Ef_B_LH=${graph_array_LH[1]}
		LoEf_B_LH=${graph_array_LH[2]}
		Cc_LH=${graph_array_LH[3]}
		Ef_LH=${graph_array_LH[4]}
		LoEf_LH=${graph_array_LH[5]}
		Q_LH=${graph_array_LH[6]}
		As_LH=${graph_array_LH[7]}
		De_LH=${graph_array_LH[8]}
		Ew_max_LH=${graph_array_LH[9]}
		Ew_median_LH=${graph_array_LH[10]}
		Ew_mean_LH=${graph_array_LH[11]}
		St_mean_LH=${graph_array_LH[12]}
		St_median_LH=${graph_array_LH[13]}
		St_sum_LH=${graph_array_LH[14]}
		Cc_rand_std_LH=${graph_array_LH[15]}
		Ef_rand_std_LH=${graph_array_LH[16]}
		LoEf_rand_std_LH=${graph_array_LH[17]}
		
		graph_array_RH=( $(cat $TRANSFORM_dir/temp/Cc_B_Ef_B_LoEf_B_Cc_Ef_LoEf_Q_As_De_Ew_max_Ew_median_Ew_mean_St_mean_St_median_St_sum_Cc_rand_std_Ef_rand_std_LoEf_rand_std_RH.csv) )
		Cc_B_RH=${graph_array_RH[0]}
		Ef_B_RH=${graph_array_RH[1]}
		LoEf_B_RH=${graph_array_RH[2]}
		Cc_RH=${graph_array_RH[3]}
		Ef_RH=${graph_array_RH[4]}
		LoEf_RH=${graph_array_RH[5]}
		Q_RH=${graph_array_RH[6]}
		As_RH=${graph_array_RH[7]}
		De_RH=${graph_array_RH[8]}
		Ew_max_RH=${graph_array_RH[9]}
		Ew_median_RH=${graph_array_RH[10]}
		Ew_mean_RH=${graph_array_RH[11]}
		St_mean_RH=${graph_array_RH[12]}
		St_median_RH=${graph_array_RH[13]}
		St_sum_RH=${graph_array_RH[14]}
		Cc_rand_std_RH=${graph_array_RH[15]}
		Ef_rand_std_RH=${graph_array_RH[16]}
		LoEf_rand_std_RH=${graph_array_RH[17]}
		
		#clinical_data_file=
		#clinical_data_array=( $(grep -a $sub_num $clinical_data_file) )
		#age=${clinical_data_array[1]}
		#sex=${clinical_data_array[2]}
		
		
		
		
		#### EXPORT
	
		[ ! -e $export_file ] && echo -n \
			"sub timepoint age sex group Cc_B Ef_B LoEf_B Cc Ef LoEf Q As De Ew_max Ew_median Ew_mean St_mean St_median St_sum Cc_rand_std Ef_rand_std LoEf_rand_std \
			Cc_B_RH Ef_B_RH LoEf_B_RH Cc_RH Ef_RH LoEf_RH Q_RH As_RH De_RH Ew_max_RH Ew_median_RH Ew_mean_RH St_mean_RH St_median_RH St_sum_RH Cc_rand_std_RH Ef_rand_std_RH LoEf_rand_std_RH \
			Cc_B_LH Ef_B_LH LoEf_B_LH Cc_LH Ef_LH LoEf_LH Q_LH As_LH De_LH Ew_max_LH Ew_median_LH Ew_mean_LH St_mean_LH St_median_LH St_sum_LH Cc_rand_std_LH Ef_rand_std_LH LoEf_rand_std_LH \
			dummy" \
			> $export_file \
			&& echo "" >> $export_file

		#echo -n "$subject " >> $export_file
		echo -n "$subject " >> $export_file
		echo -n "$sub " >> $export_file
		echo -n "$time " >> $export_file
		echo -n "$age " >> $export_file
		echo -n "$sex " >> $export_file
		echo -n "$group " >> $export_file
		
		echo -n "$Cc_B " >> $export_file
		echo -n "$Ef_B " >> $export_file
		echo -n "$LoEf_B " >> $export_file
		echo -n "$Cc " >> $export_file
		echo -n "$Ef " >> $export_file
		echo -n "$LoEf " >> $export_file
		echo -n "$Q " >> $export_file
		echo -n "$As " >> $export_file
		echo -n "$De " >> $export_file
		echo -n "$Ew_max " >> $export_file
		echo -n "$Ew_median " >> $export_file
		echo -n "$Ew_mean " >> $export_file
		echo -n "$St_mean " >> $export_file
		echo -n "$St_median " >> $export_file
		echo -n "$St_sum " >> $export_file
		echo -n "$Cc_rand_std " >> $export_file
		echo -n "$Ef_rand_std " >> $export_file
		echo -n "$LoEf_rand_std " >> $export_file
		
		echo -n "$Cc_B_RH " >> $export_file
		echo -n "$Ef_B_RH " >> $export_file
		echo -n "$LoEf_B_RH " >> $export_file
		echo -n "$Cc_RH " >> $export_file
		echo -n "$Ef_RH " >> $export_file
		echo -n "$LoEf_RH " >> $export_file
		echo -n "$Q_RH " >> $export_file
		echo -n "$As_RH " >> $export_file
		echo -n "$De_RH " >> $export_file
		echo -n "$Ew_max_RH " >> $export_file
		echo -n "$Ew_median_RH " >> $export_file
		echo -n "$Ew_mean_RH " >> $export_file
		echo -n "$St_mean_RH " >> $export_file
		echo -n "$St_median_RH " >> $export_file
		echo -n "$St_sum_RH " >> $export_file
		echo -n "$Cc_rand_std_RH " >> $export_file
		echo -n "$Ef_rand_std_RH " >> $export_file
		echo -n "$LoEf_rand_std_RH " >> $export_file

		echo -n "$Cc_B_LH " >> $export_file
		echo -n "$Ef_B_LH " >> $export_file
		echo -n "$LoEf_B_LH " >> $export_file
		echo -n "$Cc_LH " >> $export_file
		echo -n "$Ef_LH " >> $export_file
		echo -n "$LoEf_LH " >> $export_file
		echo -n "$Q_LH " >> $export_file
		echo -n "$As_LH " >> $export_file
		echo -n "$De_LH " >> $export_file
		echo -n "$Ew_max_LH " >> $export_file
		echo -n "$Ew_median_LH " >> $export_file
		echo -n "$Ew_mean_LH " >> $export_file
		echo -n "$St_mean_LH " >> $export_file
		echo -n "$St_median_LH " >> $export_file
		echo -n "$St_sum_LH " >> $export_file
		echo -n "$Cc_rand_std_LH " >> $export_file
		echo -n "$Ef_rand_std_LH " >> $export_file
		echo -n "$LoEf_rand_std_LH " >> $export_file
		
		echo "" >> $export_file
	done
done
