# snakemake -j1 -F -p ./database/*fna --use-conda



configfile: "config.yaml"
print("Config is: ", config)

DATABASE = config["database"]
print(DATABASE)



rule download_genome:
    input:  "./temp/{LOCAL}.txt"
    output: "./database/{GENOME}"
    
    shell:
        r"""

        GENOME_LINK=$(cat {input})

        GENOME="${GENOME_LINK##*/}"

        wget -P ./database $GENOME_LINK 

        gunzip ./database/$GENOME

        #mv ./database/$GENOME {output}

        """

rule split_genomes_from_list:
    input: "list_of_genomes.txt"
    output: temp("./temp/{LOCAL}.txt")

    shell:
        r"""

        i=0

        while read line
        do

            i=$(($i+1))

            echo $line > ./temp/$i.txt

        done < {input}
            
        """


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
