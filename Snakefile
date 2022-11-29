# snakemake -j1 -F -p ./database/*fna --use-conda
touchfile = '.downloaded_genomes'


GENOMES=glob_wildcards("database/{GENOME}.fna")

configfile: "config.yaml"
print("Config is: ", config)

DATABASE = config["database"]
print(DATABASE)


rule create_genome_list:
    output: touch(touchfile),
            "temp_list.txt"

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

        ls /temp/*.temp > {output[1]}
       
        """   

rule download_genome:
    input:  "temp/{GENOME}.fna.gz.temp"
    output: "database/{GENOME}.fna"
    message: "Downloading genomes..."
    
    shell:
        r"""

        GENOME_LINK=$(cat {input})

        GENOME="${GENOME_LINK##*/}"

        wget -P ./database $GENOME_LINK 

        gunzip ./database/$GENOME

        """


rule make_list_downloaded_genomes:
    input:  expand("database/{GENOME}", GENOME = GENOMES)
    output: "list_of_downloaded_genomes.txt"

    shell:
        r"""
        ls {input} > list_of_downloaded_genomes.txt

        """        


