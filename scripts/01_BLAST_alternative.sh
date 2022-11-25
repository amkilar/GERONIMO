#!/bin/bash

### Directories ###
DATABASE_DIR=/storage/brno1-cerit/home/agata/infernal_insects/database/Pucciniomycotina
RES_DIR=/storage/brno1-cerit/home/agata/infernal_insects/BLAST/BLAST_221020/

### Adding modules ###
module add blast+-2.2.29


### Copy list to SCRATCH
cd $RES_DIR


while read lines
do

  GCA=${lines}

  cd $RES_DIR
  
  ### Create folder specific for the GCA
  cd ./$GCA
  
  ### Preparing directory for database
  mkdir ./database
  
  cd ./database
  
  ### Copying reference genome to database
  cp $DATABASE_DIR/$GCA* .
  
  #############Preparing database - makeblastdb#############
  makeblastdb -in ./*.fna -dbtype nucl -parse_seqids 

  
done < all_GCA.txt


### Clean SCRATCH
cd $SCRATCH
rm -r *

