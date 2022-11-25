#!/bin/bash
#
# ssh agata@skirit.metacentrum.cz
#
# cd /storage/plzen1/home/agata/infernal/
#
# qsub -l walltime=6:0:0 -q default -l select=1:ncpus=12:mem=12gb:cgroups=12gb:scratch_local=3gb -N spiro_physco_march pip_everythig_onemodel.sh


################ VARIABLES ################
# input files: 
	# calibrated models
	# database (reference) in fasta format


################ MODEL FOR ################

MODEL=cov_model_29

################ DATABASE ################
DIR_DATABASE=/storage/brno1-cerit/home/agata/infernal_insects/database/Pucciniomycotina

THREADS=$PBS_NUM_PPN

################ PREPARATION ################
#preparation of envirnment for infernal
echo "Preparing environment"
module add conda-modules-py37
conda activate infernal 

#access
chmod 744 $DIR_DATABASE

################ COPY INPUTS ################

cd $DIR_DATABASE/

echo "Leaving COPY INPUTS"

################ LOOP OVER ALL MODELS PER EACH .FNA IN ./Database ################

for model in $MODEL
do
 echo "${model} entering the loop"
 SPECIES=${model#"cov_model_"} #drop prefix
 echo "making directory for ${SPECIES}"
 mkdir ./$SPECIES

 for ref in *.fna
 do
  echo "${ref} entering the loop"
  REF=${ref%".fna"} #drop suffix
  RESULT="result_${SPECIES}_vs_${REF}"
  ALIN="result_${SPECIES}_vs_${REF}-alignment"
  TAB="result_${SPECIES}_vs_${REF}.csv"
  
  ################ SEARCH ################
  #search a sequence database with cmsearch
 
  cmsearch --cpu $THREADS --notextw -A ./$SPECIES/$ALIN -o ./$SPECIES/$RESULT --tblout ./$SPECIES/$TAB $model $ref 

 done

 ################ COPY RESULTS ################
 #cp -r ./$SPECIES $DIR_RES
done


################ CLEAN-UP ################
echo "Cleaning-up".

conda deactivate

