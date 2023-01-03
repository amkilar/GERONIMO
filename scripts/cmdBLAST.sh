#!/bin/bash
 
 
 DATABASE=$1
 QUERY=$2
 OUTPUT=$3
 
 
 ### extracting the hit with neighbouring region blastdbcmd and writing to multi-fasta
  while read line; do
      
    arr=($line)
    
    #blastdcmd
    seq=$(blastdbcmd -db $DATABASE/*.fna \
    -entry "${arr[2]}" \
    -strand "${arr[3]}" \
    -range "${arr[4]}" \
    -outfmt %s )
    
    #extended file
    echo ">""${arr[0]}""_""${arr[1]}" >> $OUTPUT
    echo $seq >> $OUTPUT

 
  done < $QUERY 
  
 
