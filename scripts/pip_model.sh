#!/bin/bash
#
# ssh agata@skirit.metacentrum.cz
#
# cd /storage/plzen1/home/agata/infernal/
#
#qsub -l walltime=6:0:0 -q default -l select=1:ncpus=16:mem=18gb:scratch_local=1gb -N VESP pip_model.sh

################ ALIGNMENT ################
# Alignment need to be done in STOCKHOLM format.
# Prepare fasta sequences that you want to align.
# Go to http://rna.informatik.uni-freiburg.de/LocARNA/Input.jsp
# Align sequences using dc-megablast 
# and extract them in .sto format

################ VARIABLES ################
# input files: 
	# multiple sequence alignment in Stockholm format with secondary structure consensus

SPECIES=29
DIR_MODEL=/storage/brno1-cerit/home/agata/infernal_insects/model/221019/

THREADS=$PBS_NUM_PPN
MODEL="cov_model_29"

#preparation of envirnment for infernal
echo "Preparing environment"
module add conda-modules-py37
conda activate infernal 

cd $DIR_MODEL
################ STEP 1 ################
# build a covariance model with cmbuild
echo "Preparing model"

cmbuild $MODEL ./$SPECIES.stk

echo "Model created!"
################ STEP 2 ################
# calibrate the model with cmcalibrate
echo "Attempt to model calibration"

cmcalibrate --cpu $THREADS $MODEL

echo "Model calibrated!"


################ CLEAN-UP ################
echo "Cleaning-up".

conda deactivate

################ MODELS ARE CALIBRATED ##############
# WHEN LINES:

# ECMGC, ECMLI, and ECMGI

# ARE PRESENT IN THE MODEL FILE

################ DOWNLOADING DATA ################
#
#	1. Find raw reads on NCBI
#	2. Go to "Runs" -> directed to Sequence Read Archive
#	3. Copy Experiment number
#	4. Paste it to Download/FASTAorFASTQ
#	5. Choose right format and click Download (downloading to desktop)
#	 
#	5. If directly to server, then go to ebi.ac.uk/ena  and search Experiment number in search box
#	6. Choose Run or Experiment
#	7. Choose file that you want and copy link to it
#	8. Use wget <where> <link>

# FASTQ to FASTA conversion
# cat test.fastq | paste - - - - | sed 's/^@/>/g'| cut -f1-2 | tr '\t' '\n'

# Parsing several files into one
# cat *.fna >> ../../Database/$DATABASE.fasta
