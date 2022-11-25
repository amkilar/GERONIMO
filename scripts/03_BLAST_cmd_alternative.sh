#!/bin/bash

### Directories ###
RES_DIR=/storage/brno1-cerit/home/agata/infernal_insects/BLAST/BLAST_221020/
DATABASE_DIR=/storage/brno1-cerit/home/agata/infernal_insects/database/Pucciniomycotina


### Adding modules ###
module add blast+-2.2.29

### Change directory directly to results
cd $RES_DIR

### LOOP ###
while read lines
do
 
 ### Get names
 GCA=${lines}  # GCA id
    
 ### Set operation directory
 cd ./$GCA*

 ### extracting the hit with neighbouring region blastdbcmd and writing to multi-fasta
  while read line; do
    arr=($line)
    
    #blastdcmd
    seq=$(blastdbcmd -db ./database/*.fna \
    -entry "${arr[2]}" \
    -strand "${arr[3]}" \
    -range "${arr[4]}" \
    -outfmt %s )
    
    #extended file
    echo ">""_""${arr[0]}""_""${arr[1]}" >> out_ext.txt
    echo $seq >> out_ext.txt

 
  done < filtered.txt  

  ### Copying to ./GCA_123
  #cp ./out*.txt ../

  ### GO TO ./GCA_123
  #cd ../

  ###  Renaming  
  #mv ./out_short.txt ./${GCA}_short.txt 
  mv ./out_ext.txt ./${GCA}_ext.txt

  ### GO TO ./SCRATCH
  cd $RES_DIR

 
done < all_GCA.txt



### Clean the SCRATCH
rm -r *
