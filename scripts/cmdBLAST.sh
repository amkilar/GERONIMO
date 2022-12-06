#!/bin/bash
 
 
 DATABASE=$1
 
 cd $DATABASE 
 
 QUERY=$(echo *_filtered.txt)
 
 ### extracting the hit with neighbouring region blastdbcmd and writing to multi-fasta
  while read line; do
    arr=($line)
    
    #blastdcmd
    seq=$(blastdbcmd -db *.fna \
    -entry "${arr[2]}" \
    -strand "${arr[3]}" \
    -range "${arr[4]}" \
    -outfmt %s )
    
    #extended file
    echo ">""${arr[0]}""_""${arr[1]}" >> out_ext.txt
    echo $seq >> out_ext.txt

 
  done < $QUERY 
  
  rm $QUERY
 
