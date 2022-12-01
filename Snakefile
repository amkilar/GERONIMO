# snakemake -j1 -p taxonomy/GCA_022817605.1_ASM2281760v1_genomic.taxonomy.row.csv --use-conda


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
    output: touch("database/{genome}/{genome}.fna.gz")
    
    input:  "temp/{genome}.fna.gz.temp"

    message: "Downloading genomes..."
    
    shell:
        r"""
        GENOME_LINK=$(cat {input})

        GENOME="${{GENOME_LINK##*/}}"

        wget -P ./database/{wildcards.genome}/ $GENOME_LINK 
        """


rule unzip_genome:
# Whet if the .fna.gz is corrupted? 
# Make it being removed from further steps
# And skipped somehow to not ruin the whole run
    output: touch("database/{genome}/{genome}.fna")

    input:  "database/{genome}/{genome}.fna.gz"

    message: "Unzipping genomes..."
    
    shell:
        r"""
        gunzip {input}

        """        


rule infernal_search:
    output: result = "results/raw_infernal/{model}/result_{model}_vs_{genome}",
            alingment = "results/raw_infernal/{model}/result_{model}_vs_{genome}-alignment",
            table = "results/raw_infernal/{model}/result_{model}_vs_{genome}.csv",

    input:  genome = "database/{genome}/{genome}.fna",
            model = "models_calibrated/cov_model_{model}"

    conda:  "infernal_env.yaml"
    message: "Run Infernal search"
    
    shell:
        r"""
       cmsearch --notextw -A {output.alingment} -o {output.result} --tblout {output.table} {input.model} {input.genome}

        """      

rule makeblastdb:
    output: touch("database/{genome}/{genome}.fna.nhr")

    input:  genome = "database/{genome}/{genome}.fna"

    conda:  "blast_env.yaml"
    message: "Preparing database..."

    shell:
        r"""
        makeblastdb -in {input} -dbtype nucl -parse_seqids
        """

rule search_taxonomy:
    output: "taxonomy/{genome}.taxonomy.row.csv"

    input:  script = "scripts/search_taxonomy.r",
            genome = "database/{genome}/{genome}.fna"

    conda:  "search_taxonomy_r_env.yaml"        

    shell:
        "Rscript {input.script} {input.genome} {output}"
