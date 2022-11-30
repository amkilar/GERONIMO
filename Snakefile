# snakemake -j1 -F -p database/*.fna.gz --use-conda


configfile: "config.yaml"
#print("Config is: ", config)

DATABASE = config["database"]
#print(DATABASE)

#GENOMES = glob_wildcards("database/{genome}.fna").genome


rule create_genome_list:
    output: touch("temp/{genome}.fna.gz.temp")

    conda:  "entrez_env.yaml"
    message: "Creating the genomes list..."
    
    shell:
        r"""
        esearch -db assembly -query '{DATABASE}' \
        | esummary \
        | xtract -pattern DocumentSummary -element FtpPath_GenBank \
        | while read -r line ; 
        do
            fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;
            echo "$line/$fname" > temp/$fname.temp;
        done
       
        """   


rule download_genome:
    output: touch("database/{genome}.fna.gz")
    input:  "temp/{genome}.fna.gz.temp"

    message: "Downloading genomes..."
    
    shell:
        r"""
        GENOME_LINK=$(cat {input})

        GENOME="${{GENOME_LINK##*/}}"

        wget -P ./database $GENOME_LINK 
        """

#
#rule unzip_genome:
#    output: "{database}/{GENOME}.fna",
#            "{database}/list_of_downloaded_genomes.txt"
#
#    input:  "{database}/{GENOME}.fna.gz"
#
#    message: "Unzipping genomes..."
#    
#    shell:
#        r"""
#        gunzip {input}
#
#        ls {input} > {output[1]}
#
#        """        


#rule make_list_downloaded_genomes:
#    output: 
#    input:  "database/{GENOME}.fna"
#
#    shell:
#        r"""
#        ls {input} > {output}
#        """        


