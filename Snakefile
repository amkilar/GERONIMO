# snakemake -j1 -p results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/GCA_022817605.1_ASM2281760v1_genomic_bombus_filtered.txt --use-conda


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



rule read_infernal_results:
    output: "results/infernal/{model}/{genome}.csv"

    input:  script = "scripts/read_results_infernal.R",
            file = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}.csv",
            taxonomy = "taxonomy/{genome}.taxonomy.row.csv"

    conda:  "r_tidyverse_env.yaml"      

    shell:
        "Rscript {input.script} {input.file} {input.taxonomy} {output}"



rule prepare_for_genomic_region_extraction:
    output: "results/BLAST/{genome}/{genome}_{model}_filtered.txt"

    input:  script = "scripts/create_input_for_cmdBLAST.R",
            infernal_result = "results/infernal/{model}/{genome}.csv"

    conda:  "r_tidyverse_env.yaml"      

    shell:
        "Rscript {input.script} {input.infernal_result} {REGION_LENGTH} {output}"
        
































#rule blastcmd:
#    output: "{GCA}_extended_region.txt"
#
#    input:  database = "database/{genome}/{genome}.fna"
#            query = "/BLAST/{GCA}/{GCA}_query.txt"
#
#    conda:  "blast_env.yaml"
#
#    shell:
#        r"""
#
#        while read line; do
#            arr=($line)
#            
#            #blastdcmd
#            seq=$(blastdbcmd -db {input.genome} \
#            -entry "${arr[2]}" \
#            -strand "${arr[3]}" \
#            -range "${arr[4]}" \
#            -outfmt %s )
#            
#            #extended file
#            echo ">""_""${arr[0]}""_""${arr[1]}" >> out_ext.txt
#            echo $seq >> out_ext.txt
#
#            mv ./out_ext.txt ./${GCA}_ext.txt
#        
#        done < {input.query}
#


