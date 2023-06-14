<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/Geronimo_logo.png" width=40% align="right">


# GERONIMO

## Introduction
GERONIMO is a bioinformatics pipeline designed to conduct high-throughput homology searches of structural genes using covariance models. These models are based on the alignment of sequences and the consensus of secondary structures. The pipeline is built using Snakemake, a workflow management tool that allows for the reproducible execution of analyses on various computational platforms.  

The idea for developing GERONIMO emerged from a comprehensive search for [telomerase RNA in lower plants] and was subsequently refined through an [expanded search of telomerase RNA across Insecta]. GERONIMO can test hundreds of genomes and ensures the stability and reproducibility of the analyses performed.


[telomerase RNA in lower plants]: https://doi.org/10.1093/nar/gkab545
[expanded search of telomerase RNA across Insecta]: https://doi.org/10.1093/nar/gkac1202

## Scope
The GERONIMO tool utilises covariance models (CMs) to conduct homology searches of RNA sequences across a wide range of gene families in a broad evolutionary context. Specifically, it can be utilised to:

* Detect RNA sequences that share a common evolutionary ancestor
* Identify and align orthologous RNA sequences among closely related species, as well as paralogous sequences within a single species
* Identify conserved non-coding RNAs in a genome, and extract upstream genomic regions to characterise potential promoter regions.  
It is important to note that GERONIMO is a computational tool, and as such, it is intended to be run on a computer with a small amount of data. Appropriate computational infrastructure is necessary for analysing hundreds of genomes.

Although GERONIMO was primarily designed for Telomerase RNA identification, its functionality extends to include the detection and alignment of other RNA gene families, including **rRNA**, **tRNA**, **snRNA**, **miRNA**, and **lncRNA**. This can aid in identifying paralogs and orthologs across different species that may carry specific functions, making it useful for phylogenetic analyses.  

It is crucial to remember that some gene families may exhibit similar characteristics but different functions. Therefore, analysing the data and functional annotation after conducting the search is essential to characterise the sequences properly.

## Pipeline overview

<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/Geronimo_workflow.png" width=30% align="right">

By default, the GERONIMO pipeline conducts high-throughput searches of homology sequences in downloaded genomes utilizing covariance models. If a significant similarity is detected between the model and genome sequence, the pipeline extracts the upstream region, making it convenient to identify the promoter of the discovered gene. In brief, the pipeline:
- Compiles a list of genomes using the NCBI's [Entrez] database based on a specified query, *e.g. "Rhodophyta"[Organism]*
- Downloads and decompresses the requested genomes using *rsync* and *gunzip*, respectively
- *Optionally*, generates a covariance model based on a provided alignment using [Infernal]
- Conducts searches among the genomes using the covariance model [Infernal]
- Supplements genome information with taxonomy data using [rentrez]
- Expands the significant hits sequence by extracting upstream genomic regions using [*blastcmd*]
- Compiles the results, organizes them into a tabular format, and generates a visual summary of the performed analysis.

[Entrez]: https://www.ncbi.nlm.nih.gov/books/NBK179288/
[Infernal]: http://eddylab.org/infernal/
[rentrez]: https://github.com/ropensci/rentrez
[*blastcmd*]: https://www.ncbi.nlm.nih.gov/books/NBK569853/

## Quick start
The Geronimo is available as a `snakemake pipeline` running on Linux and Windows operating systems.

### Windows 10
Instal Linux on Windows 10 (WSL) according to [instructions], which bottling down to opening PowerShell or Windows Command Prompt in *administrator mode* and pasting the following:
```shell
wsl --install
wsl.exe --install UBUNTU
```
Then restart the machine and follow the instructions for setting up the Linux environment.

[instructions]: https://learn.microsoft.com/en-us/windows/wsl/install

### Linux:
#### Check whether the conda is installed:
```shell
conda -V
```
> Geronimo was tested on conda 23.3.1
#### 1) If you do not have installed `conda`, please install `miniconda`
Please follow the instructions for installing [miniconda]

[miniconda]: https://conda.io/projects/conda/en/stable/user-guide/install/linux.html

#### 2) Continue with installing `mamba` (recommended but optional)
```shell
conda install -n base -c conda-forge mamba
```
#### 3) Install `snakemake`
```shell
conda activate base
mamba create -p env_snakemake -c conda-forge -c bioconda snakemake
mamba activate env_snakemake
snakemake --help
```
In case of complications, please check the section `Questions & Answers` below or follow the [official documentation] for troubleshooting.

[official documentation]: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html

### Clone the GERONIMO repository
Go to the path in which you want to run the analysis and clone the repository:
```shell
cd <PATH>
git clone https://github.com/amkilar/GERONIMO.git
```

## Setup the inputs

### 1) Prepare the `covariance models`:

#### Browse the collection of available `covariance models` at [Rfam] (*You can find the covariance model in the tab `Curation`.*)  
Paste the covariance model to the folder `GERONIMO/models` and ensure its name follows the convention: `cov_model_<NAME>`

[Rfam]: https://rfam.org/

#### **OR**

#### Prepare your own `covariance model` using [LocARNA]
1. Paste or upload your sequences to the web server and download the `.stk` file with the alignment result.  
  
    > *Please note that the `.stk` file format is crucial for the analysis, containing sequence alignment and secondary structure consensus.*
    
    > The LocARNA web service allows you to align 30 sequences at once - if you need to align more sequences, please use the standalone version available [here]  
    > After installation run: 
    ```shell
    mlocarna my_fasta_sequences.fasta
    ```
  
2. Paste the `.stk` alignment file to the folder `GERONIMO/model_to_build` and ensure its name follows the convention: `<NAME>.stk`

[RNAalifold]: http://rna.informatik.uni-freiburg.de/LocARNA/Input.jsp
[here]: http://www.bioinf.uni-freiburg.de/Software/LocARNA/


### 2) Adjust the `config.yaml` file
Please adjust the analysis specifications, as in the following example:

> - CPU: <number> (specify the number of available CPUs (half of them will be used for covariance model building)
> - database: '<DATABASE_QUERY> [Organism]' (in case of difficulties with defining the database query, please follow the instructions below)
> - models_to_build: ["<NAME>"] (here specify the names of alignment/s in the `.stk` format that you want to build)
> - models: ["<NAME>", "<NAME>"] (here specify the names of models that should be used to perform analysis)
> - extract_genomic_region-length:  <number> (here you can determine how long the upstream genomic region should be extracted; tested for 200)

  > *Keep in mind that the covariance models and alignments must be present in the respective GERONIMO folders.*  
 
  
### 3) **Please ensure you have enough storage capacity to download all the requested genomes (in the `GERONIMO/` directory)**

## Run GERONIMO
```shell
mamba activate env_snakemake
cd ~/GERONIMO
snakemake -s GERONIMO.sm --cores <declare number of CPUs> --use-conda results/summary_table.xlsx
```
  
## Example results

### Outputs characterisation

#### A) Summary table
The Excel table contains the results arranged by taxonomy information and hit significance. The specific columns include:
* family, organism_name, class, order, phylum (taxonomy context)
* GCA_id - corresponds to the genome assembly in the *NCBI database*
* model - describes which covariance model identified the result
* label - follows the *Infernal* convention of categorizing hits
* number - the counter of the result
* e_value - indicates the significance level of the hit
* HIT_sequence - the exact HIT sequence found by *Infernal*, which corresponds to the covariance model
* HIT_ID - describes in which part of the genome assembly the hit was found, which may help publish novel sequences
* extended_genomic_region - upstream sequence, which may contain a possible promoter sequence
* secondary_structure - the secondary structure consensus of the covariance model

#### B) Significant Hits Distribution Across Taxonomy Families
The plot provides an overview of the number of genomes in which at least one significant hit was identified, grouped by family. The bold black line corresponds to the number of genomes present in each family, helping to minimize bias regarding unequal data representation across the taxonomy.

#### C) Hits Distribution in Genomes Across Families
The heatmap informs about the most significant hit from the genome found by a particular covariance model. Genomes are grouped by families (on the right). The darkest colour of the tile represents the most significant hit. If grey, it means that no hit was identified.

<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/Output_results.png" width=100% align="center">


### GERONIMO directory structure

The GERONIMO directory structure is designed to produce files in a highly structured manner, ensuring clear insight and facilitating the analysis of results. During a successful run, GERONIMO produces the following folders:
* `/database` - which contains genome assemblies that were downloaded from the *NCBI database* and grouped in subfolders
* `/taxonomy` - where taxonomy information is gathered and stored in the form of tables
* `/results` - the main folder containing all produced results:
  * `/infernal_raw` - contains the raw results produced by *Infernal*
  * `/infernal` - contains restructured results of *Infernal* in table format
  * `/cmdBLAST` - contains results of *cmdblast*, which extracts the extended genomic region
  * `/summary` - contains summary files that join results from *Infernal*, *cmdblast*, and attach taxonomy context
  * `/plots` - contains two types of summary plots
* `/temp` - folder contains the information necessary to download genome assemblies from *NCBI database*

* `/env` - stores instructions for dependency installation
* `/models` - where calibrated covariance models can be pasted, *for example, from the Rfam database*
* `/modes_to_built` - where multiple alignments in *.stk* format can be pasted
* `/scripts` - contains developed scripts that perform results structurization

#### The example GERONIMO directory structure:

```shell
GERONIMO
├── database
│   ├── GCA_000091205.1_ASM9120v1_genomic
│   ├── GCA_000341285.1_ASM34128v1_genomic
│   ├── GCA_000350225.2_ASM35022v2_genomic
│   └── ...
├── env
├── models
├── model_to_build
├── results
│   ├── cmdBLAST
│   │   ├── MRP
│   │   │   ├── GCA_000091205.1_ASM9120v1_genomic
│   │   │   │   ├── extended
│   │   │   │   └── filtered
│   │   │   ├── GCA_000341285.1_ASM34128v1_genomic
│   │   │   │   ├── extended
│   │   │   │   └── filtered
│   │   │   ├── GCA_000350225.2_ASM35022v2_genomic
│   │   │   │   ├── extended
│   │   │   │   └── filtered
│   │   │   └── ...
│   │   ├── SRP
│   │   │   ├── GCA_000091205.1_ASM9120v1_genomic
│   │   │   │   ├── extended
│   │   │   │   └── filtered
│   │   │   ├── GCA_000341285.1_ASM34128v1_genomic
│   │   │   │   ├── extended
│   │   │   │   └── filtered
│   │   │   ├── GCA_000350225.2_ASM35022v2_genomic
│   │   │   │   ├── extended
│   │   │   │   └── filtered
│   │   │   └── ...
│   │   ├── ...
│   ├── infernal
│   │   ├── MRP
│   │   │   ├── GCA_000091205.1_ASM9120v1_genomic
│   │   │   ├── GCA_000341285.1_ASM34128v1_genomic
│   │   │   ├── GCA_000350225.2_ASM35022v2_genomic
│   │   │   ├── ...
│   │   ├── SRP
│   │   │   ├── GCA_000091205.1_ASM9120v1_genomic
│   │   │   ├── GCA_000341285.1_ASM34128v1_genomic
│   │   │   ├── GCA_000350225.2_ASM35022v2_genomic
│   │   │   ├── ...
│   ├── plots
│   ├── raw_infernal
│   │   ├── MRP
│   │   │   ├── GCA_000091205.1_ASM9120v1_genomic
│   │   │   ├── GCA_000341285.1_ASM34128v1_genomic
│   │   │   ├── GCA_000350225.2_ASM35022v2_genomic
│   │   │   ├── ...
│   │   ├── SRP
│   │   │   ├── GCA_000091205.1_ASM9120v1_genomic
│   │   │   ├── GCA_000341285.1_ASM34128v1_genomic
│   │   │   ├── GCA_000350225.2_ASM35022v2_genomic
│   │   │   ├── ...
│   └── summary
│       ├── GCA_000091205.1_ASM9120v1_genomic
│       ├── GCA_000341285.1_ASM34128v1_genomic
│       ├── GCA_000350225.2_ASM35022v2_genomic
│       ├── ...
├── scripts
├── taxonomy
└── temp
```

## Questions & Answers

### How to specify the database query?
- Visit the [NCBI Assemblies] website.  
- Follow the instruction on the graphic below:
<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/database_query.png" width=100%>

[NCBI Assemblies]: https://www.ncbi.nlm.nih.gov/assembly/?term=

### WSL: problem with creating `snakemake_env`
In the case of an error similar to the one below:
> CondaError: Unable to create prefix directory '/mnt/c/Windows/system32/env_snakemake'.
> Check that you have sufficient permissions.  
  
You might try to delete the cache with: `rm -r ~/.cache/` and try again.

### When `snakemake` does not seem to be installed properly
In the case of the following error:
> Command 'snakemake' not found ...
> Check whether the `env_snakemake` is activated
It should result in a change from (base) to (env_snakemake) before your login name in the command line window.
> If you still see `(base)` before your login name, please try to activate the environment with conda:
conda activate env_snakemake
 
Please note that you might need to specify the full path to the `env_snakemake`, like /home/<user>/env_snakemake

### How to browse GERONIMO results obtained in WSL?
You can easily access the results obtained on WSL from your Windows environment by opening `File Explorer` and pasting the following line into the search bar: `\\wsl.localhost\Ubuntu\home\`. This will reveal a folder with your username, as specified during the configuration of your Ubuntu system. To locate the GERONIMO results, simply navigate to the folder with your username and then to the `home` folder. (`\\wsl.localhost\Ubuntu\home\<user>\home\GERONIMO`)

## License
The GERONIMO is freely available for academic users. Usage for commercial purposes is not allowed.

## Contact
mgr inż. Agata Magdalena Kilar (agata.kilar@ceitec.muni.cz)

