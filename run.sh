#!/bin/bash
echo "STARTING"
paramLoc=${0%/*}
if [ -e "./parameters.sh" ]; then
	echo "Getting parameters from $paramLoc/parameters.sh"
	source /Users/jordanhoffmann/Dropbox/Jordan_and_Seth/Odyssey/parameters.sh
else
	echo "ERROR: CANNOT FIND PARAMETERS.SH"
	echo "parameters.sh (containing your settings) must be in the same directory as this script."
	exit
fi
echo "File path is: $filepath"

#####PRINTING OUT THE PARAMETERS
echo "Dataset is: $dataset"
echo "Iteration is: $iter"
echo "T_Start is: $t_start"
echo "T_End is: $t_end"
echo "Number of angles: $no_angles"
echo "Number of channels: $no_channels"

if [ $createlogfile=$True ];
	then
		echo "Making log file"
		#####PRINTING EVERYTHING TO A LOG FILE
		echo "Log of dataset $run_name">"LOG"
		echo "Dataset is: $dataset">>"LOG"
		echo "Iteration is: $iter">>"LOG"
		echo "T_Start is: $t_start">>"LOG"
		echo "T_End is: $t_end">>"LOG"
		echo "Number of angles: $no_angles">>"LOG"
		echo "Number of channels: $no_channels">>"LOG"
fi

#make quit file
echo "run("Quit")"';'>"quit.ijm"
#####MAKE CZI TO TIF CONVERSION
if [ $czi2tifQ=$True ];
	then
		echo "MAKING CZI TO TIF FILE"
		echo 'run("Z1 CZI to TIF for Timelapse and Multiview 07012015 SD JH", "experiment=full_coal_2 number=2 angles/views?='"$no_angles timepoints=$t_end illuminations=$no_illuminations"" bin=1 bin=1 bin=1 original=$filepath$firstczi choose=$filepath"");" > "$run_name""1.ijm"
		echo "#!/bin/bash">"submit_1"
		echo "#SBATCH -J CZI_2_TIF">>"submit_1"
		echo "#SBATCH -N 1">>"submit_1"
		echo "#SBATCH -n $no_processors1">>"submit_1"
		echo "#SBATCH -t $time_1">>"submit_1"
		echo "#SBATCH -p general,serial_requeue">>"submit_1"
		echo "#SBATCH --mem=$RAM1">>"submit_1"
		echo "#SBATCH -o step_1.out">>"submit_1"
		echo "#SBATCH -e step_1.err">>"submit_1"
		echo "export DISPLAY=:11">>"submit_1"
		echo "Xvfb "'$DISPLAY'" -auth /dev/null &">>"submit_1"
		if [ $createlogfile=$True ];
			then		
				echo "echo "'"STARTING CZI CONVERSION"'">>"'"LOG"'>>"submit_1"
		fi
		echo "$FIJIPATH --memory=$RAM1""m -macro ""./$run_name""1.ijm">>"submit_1"
		echo "$FIJIPATH --memory=$RAM1""m -macro ./quit.ijm">>"submit_1"
		if [ $createlogfile=$True ];
			then
				echo "echo "'"FINISHED CZI CONVERSION"'">>"'"LOG"'>>"submit_1"
		fi
		echo "FINISHED CZI TO TIF PROCESS"
fi
#####DEFINE MULTIVIEW DATASET
if [ $defineQ=$True ];
	then
		echo "DEFINING MULTIVIEW DATASET"
		echo 'run("Define Multi-View Dataset", "type_of_dataset=[Image Stacks (LOCI Bioformats)] xml_filename='"$dataset multiple_timepoints=[YES (one file per time-point)] multiple_channels=[YES (one file per channel)] _____multiple_illumination_directions=[YES (one file per illumination direction)] multiple_angles=[YES (one file per angle)] image_file_directory=$filepath image_file_pattern=$run_name""_TP{ttt}_AN{a}_CH{c}_IL{i}.tif timepoints_=1-$t_end channels_=1,2 illumination_directions_=1,2 acquisition_angles_=1-4 calibration_type=[Same voxel-size for all views] calibration_definition=[Load voxel-size(s) from file(s)] imglib2_data_container=[ArrayImg (faster)]"");">"$run_name""2.ijm"
		echo "#!/bin/bash">"submit_2"
		echo "#SBATCH -J DEF_MULTIVIEW">>"submit_2"
		echo "#SBATCH -N 1">>"submit_2"
		echo "#SBATCH -n $no_processors2">>"submit_2"
		echo "#SBATCH -t $time_2">>"submit_2"
		echo "#SBATCH -p general,serial_requeue">>"submit_2"
		echo "#SBATCH --mem=$RAM2">>"submit_2"
		echo "#SBATCH -o step_2.out">>"submit_2"
		echo "#SBATCH -e step_2.err">>"submit_2"
		echo "export DISPLAY=:33">>"submit_2"
		echo "Xvfb "'$DISPLAY'" -auth /dev/null &">>"submit_2"
		if [ $createlogfile=$True ];
			then
				echo "echo "'"DEFINE DATASET"'">>"'"LOG"'>>"submit_2"
		fi
		echo "$FIJIPATH --memory=$RAM2""m -macro ""./$run_name""2.ijm">>"submit_2"
		echo "$FIJIPATH --memory=$RAM2""m -macro ./quit.ijm">>"submit_2"
		if [ $createlogfile=$True ];
			then
				echo "echo "'"DONE WITH DEFINE DATASET"'">>"'"LOG"'>>"submit_2"
		fi
fi

####Detect AND REGISTER DATASET BASED ON INTEREST POITNS
if [ $detectregQ=$True ];
	then
		echo "DETECT AND REGISTER DATASET"
		echo 'run("Detect Interest Points for Registration", "select_xml'"=$filepath""$dataset process_angle=[All angles] process_channel=[Single channel (Select from List)] process_illumination=[All illuminations] process_timepoint=[All Timepoints] processing_channel=[channel 2] type_of_interest_point_detection=Difference-of-Gaussian label_interest_points=beads downsample_images subpixel_localization=[3-dimensional quadratic fit] interest_point_specification=[Weak & small (beads)] downsample_xy=1x downsample_z=1x compute_on=[CPU (Java)]"');'>"$run_name""3.ijm"
		echo 'run("Register Dataset based on Interest Points", "select_xml'"=$filepath""$dataset process_angle=[All angles] process_illumination=[All illuminations] process_timepoint=[All Timepoints] registration_algorithm=[Fast 3d geometric hashing (rotation invariant)] type_of_registration=[Register timepoints individually] interest_points_channel_1=[(DO NOT register this channel)] interest_points_channel_2=beads fix_tiles=[Fix first tile] map_back_tiles=[Do not map back (use this if tiles are fixed)] transformation=Affine regularize_model model_to_regularize_with=Rigid lamba=0.10 allowed_error_for_ransac=5 significance=10"');'>>"$run_name""3.ijm"
		echo "#!/bin/bash">"submit_3"
		echo "#SBATCH -J DEF_MULTIVIEW">>"submit_3"
		echo "#SBATCH -N 1">>"submit_3"
		echo "#SBATCH -n $no_processors3">>"submit_3"
		echo "#SBATCH -t $time_3">>"submit_3"
		echo "#SBATCH -p general,serial_requeue">>"submit_3"
		echo "#SBATCH --mem=$RAM3">>"submit_3"
		echo "#SBATCH -o step_3.out">>"submit_3"
		echo "#SBATCH -e step_3.err">>"submit_3"
		echo "export DISPLAY=:13">>"submit_3"
		echo "Xvfb "'$DISPLAY'" -auth /dev/null &">>"submit_3"
		if [ $createlogfile=$True ];
			then
				echo "echo "'"DETECTING AND REGISTERING"'">>"'"LOG"'>>"submit_3"
		fi
		echo "$FIJIPATH --memory=$RAM3""m -macro ""./$run_name""3.ijm">>"submit_3"
		echo "$FIJIPATH --memory=$RAM3""m -macro ./quit.ijm">>"submit_3"
		if [ $createlogfile=$True ];
			then
				echo "echo "'"DONE WITH DETECT AND REGISTER"'">>"'"LOG"'>>"submit_3"
		fi
fi
