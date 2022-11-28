
configfile: "config.yaml"
print("Config is: ", config)

DATABASE = config["database"]
print(DATABASE)


rule create_genome_list:
    output: "list_of_genomes.txt"
    conda:  "entrez_env.yaml"
    
    shell:
        r"""
        esearch -db assembly -query '{DATABASE}' \
        | esummary \
        | xtract -pattern DocumentSummary -element FtpPath_GenBank \
        | while read -r line ; 
        do
            fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;
            echo "$line/$fname" >> list_of_genomes.txt;
        done
       
        """    

rule download_genome:
    input:  "list_of_genomes.txt"
    output: "database/{GENOME}.fna"

    shell:
        r"""

        GENOME_LINK=$(head -n 1 {input})

        tail -n +2 {input} > "FILE.tmp" && mv "FILE.tmp" {input}

        cd ./database

        wget "$GENOME_LINK"

        GENOME="${GENOME_LINK##*/}"

        #gunzip $GENOME

        gzip -d $GENOME

        cd ../

        #tail -n +2 {input} > "$FILE.tmp" && mv "$FILE.tmp" {input}

        """

#rule downoload_genome:
#    input:  "{GENOME}"
#    output: "database/{GENOME}.fna.gz"
#
#    shell:
#        r"""
#
#        """
#
#
#rule unzip_genome:
#    input:  "database/{GENOME}.fna.gz"
#    output: "database/{GENOME}.fna"
#
#    shell:
#        r"""
#        
#        """
#
#
#rule collect_files:
#    input:  "database/{GENOME}.fna"
#    output: "list.txt"
#
#    shell:
#        r"""
#        ls database/*fna > list.txt
#        """        



#rule downloading_genomes:
##    input:  config["database"]
#    output: "database/list_of_genomes.txt"
#    conda:  "entrez_env.yaml"
#    
#    shell:
#        r"""
#
#        esearch -db assembly -query '{DATABASE}' \
#        | esummary \
#        | xtract -pattern DocumentSummary -element FtpPath_GenBank \
#        | while read -r line ; 
#        do
#            fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;
#            wget -P ./database "$line/$fname" ;
#        done
#
#
#        ls database/*gz > list_of_genomes.txt
#
#        """   







#esearch -db assembly -query '{DATABASE}' \
#        | esummary \
#        | xtract -pattern DocumentSummary -element FtpPath_GenBank \
#        | while read -r line ; 
#        do
#            fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;
#            wget -P ./database "$line/$fname" ;
#        done












#rule unzip_genome:
#    input: "database/*.fna.gz"
#    output: "database/*.fna"b
#    shell:
#        r"""
#        guzip {input}
#        """
