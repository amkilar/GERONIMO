#!/bin/bash


cd /storage/brno1-cerit/home/agata/infernal_insects/database/Pucciniomycotina

module add edirect

####################################################### DOWNLOADING GENOMES ACC. TO QUERY ###############################################################################################################
esearch -db assembly -query '"Pucciniomycotina"[Organism] AND (latest[filter] AND "representative genome"[filter] AND all[filter] NOT anomalous[filter])' \
    | esummary \
    | xtract -pattern DocumentSummary -element FtpPath_GenBank \
    | while read -r line ; 
    do
        fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;
        wget "$line/$fname" ;
    done

####################################################### EXTRACTING FILES #################################################################################################################################
for plik in *gz
do
 gunzip $plik
done

####################################################### DOWNLOADING FTP LINK ACC. TO QUERY ###############################################################################################################
esearch -db assembly -query '"Hymenoptera"[Organism] AND (latest[filter] AND all[filter] NOT anomalous[filter])' \
    | esummary \
    | xtract -pattern DocumentSummary -element FtpPath_GenBank >> ftp_GCA_list.txt

####################################################### EXTRACTING GCA NUMBER FROM FTP LIST ###############################################################################################################

for ftp in `cat ./ftp_GCA_list.txt`; 
  do
  GCA=$(echo $ftp | grep -oP 'GCA_[0-9]{9}.[0-9]')
  echo $GCA >> GCA_list.txt
done

####################################################### FROM LIST OF GCAs TAKE AssemblyAccession,Organism,Taxid ############################################################################################

#cat GCA_list.txt | epost -db assembly -format acc | esummary | xtract -pattern DocumentSummary \
#-sep ", " -tab "\n" -element AssemblyAccession,Organism,Taxid >> name_acc_org.txt

#for i in ./GCA_list.txt`; do echo ${i} >> name_acc_org.txt ; epost -db assembly -query ${i} | esummary | xtract -pattern DocumentSummary -element AssemblyAccession,Organism,Taxid,Genome Coverage >> name_acc_org.txt; done

####################################################### FROM LIST OF GCAs TAKE ScientificName ##############################################################################################################

#for i in `cat ./GCA_list.txt`; do echo ${i} >> output.txt ; esearch -db assembly -query ${i} | elink -target taxonomy | efetch -format native -mode xml | xtract -pattern Taxon -block "*/Taxon" -if Rank -equals "family" -element ScientificName >> output_old.txt; done


for i in `cat ./GCA_list.txt`; do echo ${i} >> tax.txt ; esearch -db assembly -query ${i} | elink -target taxonomy |  efetch -format native -mode xml | xtract -pattern Taxon \
                -tab '\n' -sep '|' \
                -element ScientificName \
                -division LineageEx \
                -group Taxon \
                -if Rank -equals superkingdom \
                -or Rank -equals kingdom \
                -or Rank -equals phylum \
                -or Rank -equals class \
                -or Rank -equals order \
                -or Rank -equals family \
                -or Rank -equals genus \
                -tab '\n' -sep '|' \
                -element Rank,ScientificName >> tax.txt; done


                	 
 

