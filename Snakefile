# snakemake -j1 -p results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/extended/GCA_022817605.1_ASM2281760v1_genomic_bombus_extended_region.txt --use-conda

# to obtain dag:
# snakemake -j1 -f -p --dag results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/GCA_022817605.1_ASM2281760v1_genomic_bombus3_filtered.txt --use-conda | dot -Tpng > dag.png

configfile: "config.yaml"
#print("Config is: ", config)

DATABASE = config["database"]
REGION_LENGTH = config["extract_genomic_region-length"]
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
    output: result = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}",
            alingment = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}-alignment",
            table = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}.csv",

    input:  genome = "database/{genome}/{genome}.fna",
            model = "models_calibrated/cov_model_{model}"

    conda:  "infernal_env.yaml"
    message: "Run Infernal search"
    
    shell:
        r"""
       cmsearch --notextw -A {output.alingment} -o {output.result} --tblout {output.table} {input.model} {input.genome}

        """      


rule search_taxonomy:
    output: "taxonomy/{genome}.taxonomy.row.csv"

    input:  script = "scripts/search_taxonomy.r",
            genome = "database/{genome}/{genome}.fna"

    conda:  "search_taxonomy_r_env.yaml"        

    shell:
        "Rscript {input.script} {input.genome} {output}"



rule read_infernal_results:
    output: "results/infernal/{model}/{genome}.csv"

    input:  script = "scripts/read_results_infernal.R",
            file = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}.csv",
            taxonomy = "taxonomy/{genome}.taxonomy.row.csv"

    conda:  "r_tidyverse_env.yaml"      

    shell:
        "Rscript {input.script} {input.file} {input.taxonomy} {output}"



rule prepare_for_genomic_region_extraction:
    output: "results/BLAST/{genome}/filtered/{genome}_{model}_filtered.txt"

    input:  script = "scripts/create_input_for_cmdBLAST.R",
            infernal_result = "results/infernal/{model}/{genome}.csv"

    conda:  "r_tidyverse_env.yaml"      

    shell:
        "Rscript {input.script} {input.infernal_result} {REGION_LENGTH} {output}"
 

rule makeblastdb:
    output: touch("database/{genome}/{genome}.fna.nhr")

    input:  genome = "database/{genome}/{genome}.fna"

    conda:  "blast_env.yaml"
    message: "Preparing database..."

    shell:
        r"""
        makeblastdb -in {input} -dbtype nucl -parse_seqids
        """


rule blastcmd:
    output: touch("results/BLAST/{genome}/extended/{genome}_{model}_extended_region.txt")

    input:  database = "database/{genome}/{genome}.fna.nhr",
            query = "results/BLAST/{genome}/filtered/{genome}_{model}_filtered.txt"

    conda:  "blast_env.yaml"

    shell:
        r"""

        VAR=$(echo {input.database})
        DATABASE=$(echo ${{VAR%/*}})

        #if filtered file is empty the empty _extended_region will be created
        if [ -s {input.query} ]
        then
            
            cp {input.query} $DATABASE

            ./scripts/cmdBLAST.sh $DATABASE

            mv $DATABASE/out_ext.txt {output}
                    
        fi 

        """

rule extended_genomic_region_to_table:
    output: touch("results/BLAST/{genome}/extended/{genome}_{model}_extended_region.csv")

    input:  script = "scripts/transform_cmdBLAST_output.R",
            blastcmd_result = "results/BLAST/{genome}/extended/{genome}_{model}_extended_region.txt"

    conda:  "cmdBLAST_to_R_env.yaml"

    shell: 
        r"""       
        if [ -s {input.blastcmd_result} ]
        then

            Rscript {input.script} {input.blastcmd_result} {output}

        fi
        """      



# rule assembe_summary_table:
#     output: "results/summary_table.xlsx"
# 
#     input:  


             



        



