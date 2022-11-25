
configfile: "config.yaml"
print("Config is: ", config)

DATABASE = config["database"]
print(DATABASE)


rule downloading_genomes:
#    input:  config["database"]
    output: "database/list_of_genomes.txt"
    conda:  "entrez_env.yaml"
    
    shell:
        r"""
        esearch -db assembly -query '{DATABASE}' \
        | esummary \
        | xtract -pattern DocumentSummary -element FtpPath_GenBank \
        | while read -r line ; 
        do
            fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/') ;
            wget "$line/$fname" ;
        done


        ls *gz > list_of_genomes.txt

        """    


#rule unzip_genome:
#    input: "database/{GENOME}.fna.gz"
#    output: "database/{GENOME}.fna"
#    shell:
#        r"""
#        guzip {input}
#        """
