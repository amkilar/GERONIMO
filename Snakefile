# snakemake -j1 -p results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/extended/GCA_022817605.1_ASM2281760v1_genomic_bombus_extended_region.txt --use-conda

# to obtain dag:
# snakemake -j1 -f -p --dag results/BLAST/GCA_022817605.1_ASM2281760v1_genomic/GCA_022817605.1_ASM2281760v1_genomic_bombus3_filtered.txt --use-conda | dot -Tpng > dag.png

configfile: "config.yaml"
#print("Config is: ", config)

MODEL_TO_BUILD=config["models_to_build"]
MODELS=config["models"]
DATABASE = config["database"]
REGION_LENGTH = config["extract_genomic_region-length"]


rule create_genome_list:
    output: list = "list_of_genomes.txt",
            dir = directory("temp")

    conda:  "entrez_env.yaml"
    
    shell:
        r"""
        mkdir -p {output.dir}

        esearch -db assembly -query '{DATABASE}' \
        | esummary \
        | xtract -pattern DocumentSummary -element FtpPath_GenBank \
        | while read -r line ; 
        do
            fname=$(echo $line | grep -o 'GCA_.*' | sed 's/$/_genomic.fna.gz/');
            wildcard=$(echo $fname | sed -e 's!.fna.gz!!');

            echo "$line/$fname" > temp/$wildcard;
            echo $wildcard >> {output.list}

        done
        """

rule stk_to_model:
    output: "models/cov_model_{model}"
    
    input: "model_to_build/{model}.stk"

    threads: 8
    conda: "infernal_env.yaml"
    shell:
        r"""
            cmbuild {output} {input}

            cmcalibrate {output} 
         """



checkpoint check_genome_list:
    output: touch(".create_genome_list.touch")

    input: "list_of_genomes.txt"

# checkpoint code to read the genome list and specify all wildcards for genomes
class Checkpoint_MakePattern:
    def __init__(self, pattern):
        self.pattern = pattern

    def get_names(self):
        with open('list_of_genomes.txt', 'rt') as fp:
            names = [ x.rstrip() for x in fp ]
        return names

    def __call__(self, w):
        global checkpoints

        # wait for the results of 'list_of_genomes.txt'; this will trigger an
        # exception until that rule has been run.
        checkpoints.check_genome_list.get(**w)

        # information used to expand the pattern, using arbitrary Python code
        names = self.get_names()

        pattern = expand(self.pattern, name=names, model=MODELS, **w)

        return pattern


rule download_genome:
    output: touch("database/{genome}/{genome}.fna.gz")
    
    input:  "temp/{genome}"

    shell:
        r"""
        GENOME_LINK=$(cat {input})
        GENOME="${{GENOME_LINK##*/}}"
        wget -P ./database/{wildcards.genome}/ $GENOME_LINK 
        """


# Whet if the .fna.gz is corrupted? 
# Make it being removed from further steps
# And skipped somehow to not ruin the whole run
rule unzip_genome:
    output: "database/{genome}/{genome}.fna"

    input:  "database/{genome}/{genome}.fna.gz"
    
    shell:
        r"""
        gunzip {input}
        """        

    # tutaj pierwszy checkup żeby sprawdzić ile tych plików się ściągnęło (i poprawnie rozpakowało)
    # można dodać jakiś extra output na te, które się nie rozpakowały do manualnego ściągnięcia i wrzucenia w pipeline


rule infernal_search:
    output: result = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}",
            alingment = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}-alignment",
            table = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}.csv",

    input:  genome = "database/{genome}/{genome}.fna",
            model = "models/cov_model_{model}"

    conda:  "infernal_env.yaml"
    message: "Run Infernal search"
    
    shell:  "cmsearch --notextw -A {output.alingment} -o {output.result} --tblout {output.table} {input.model} {input.genome}"      


rule search_taxonomy:
    output: "taxonomy/{genome}.taxonomy.row.csv"

    input:  script = "scripts/search_taxonomy.r",
            genome = "database/{genome}/{genome}.fna"

    conda:  "search_taxonomy_r_env.yaml"        

    shell:  "Rscript {input.script} {input.genome} {output}"



rule read_infernal_results:
    output: "results/infernal/{genome}/{genome}_{model}.csv"

    input:  script = "scripts/read_results_infernal.R",
            file = "results/raw_infernal/{model}/{genome}/result_{model}_vs_{genome}.csv",
            taxonomy = "taxonomy/{genome}.taxonomy.row.csv"

    conda:  "r_tidyverse_env.yaml"      

    shell:  "Rscript {input.script} {input.file} {input.taxonomy} {output}"



rule prepare_for_genomic_region_extraction:
    output: "results/BLAST/{genome}/filtered/{genome}_{model}_filtered.txt"

    input:  script = "scripts/create_input_for_cmdBLAST.R",
            infernal_result = "results/infernal/{genome}/{genome}_{model}.csv"

    conda:  "r_tidyverse_env.yaml"      

    shell:  "Rscript {input.script} {input.infernal_result} {REGION_LENGTH} {output}"
 

rule makeblastdb:
    output: touch("database/{genome}/{genome}.fna.nhr")

    input:  genome = "database/{genome}/{genome}.fna"

    conda:  "blast_env.yaml"

    shell:  "makeblastdb -in {input} -dbtype nucl -parse_seqids"


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
        rm {input.blastcmd_result}
        """      


rule prepare_part_results:
    output: touch("results/summary/{genome}/{genome}_{model}_summary.csv")

    input:  script = "scripts/join_infernal_and_BLASTcmd_results.R",
            infernal = "results/infernal/{genome}/{genome}_{model}.csv",
            blastcmd = "results/BLAST/{genome}/extended/{genome}_{model}_extended_region.csv"
    
    conda:  "r_tidyverse_env.yaml" 

    shell:  "Rscript {input.script} {input.infernal} {input.blastcmd} {output}"


rule make_summary_table:
    output: "results/part_summary_table.csv"

    input:  Checkpoint_MakePattern("results/summary/{name}/{name}_{model}_summary.csv")
    #here wildcard has to be named "name", as it must match checkpoint

    shell:   
        """
        cat {input} >> {output}
        """

rule produce_results:
  output:   table = touch("results/summary_table.xlsx")

    input:  script = "scripts/make_table_plots.R",
            raw_table = "results/part_summary_table.csv"

    conda:  "r_tidyverse_env.yaml"        

    shell:  "mkdir results/plots; Rscript {input.script} {input.raw_table}"