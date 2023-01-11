<img src="https://github.com/amkilar/GERONIMO/blob/main/Geronimo_logo.png" width=40% align="right">

# GERONIMO

## Introduction
GERONIMO is a bioinformatics pipeline designed to conduct high-throughput homology searches of structural genes using covariance models. These models are based on the alignment of sequences and the consensus of secondary structures. The pipeline is built using Snakemake, a workflow management tool that allows for the reproducible execution of analyses on various computational platforms.  

The idea for developing GERONIMO emerged from a comprehensive search for [Telomerase RNA in lower plants] and was subsequently refined through an [expanded search of Telomerase RNA across Insecta]. GERONIMO can test hundreds of genomes and ensures the stability and reproducibility of the analyses performed.


[Telomerase RNA in lower plants]: https://doi.org/10.1093/nar/gkab545
[expanded search of Telomerase RNA across Insecta]: https://doi.org/10.1093/nar/gkac1202

## Scope
The GERONIMO tool utilises covariance models (CMs) to conduct homology searches of RNA sequences across a wide range of gene families in a broad evolutionary context. Specifically, it can be utilised to:

* Detect RNA sequences that share a common evolutionary ancestor
* Identify and align orthologous RNA sequences among closely related species, as well as paralogous sequences within a single species
* Identify conserved non-coding RNAs in a genome, and extract upstream genomic regions to characterise potential promoter regions.  
It is important to note that GERONIMO is a computational tool, and as such, it is intended to be run on a computer with a small amount of data. Appropriate computational infrastructure is necessary for analysing hundreds of genomes.

Although GERONIMO was primarily designed for Telomerase RNA identification, its functionality extends to include the detection and alignment of other RNA gene families, including **rRNA**, **tRNA**, **snRNA**, **miRNA**, and **lncRNA**. This can aid in identifying paralogs and orthologs across different species that may carry specific functions, making it useful for phylogenetic analyses.  

It is crucial to remember that some gene families may exhibit similar characteristics but different functions. Therefore, analysing the data and functional annotation after conducting the search is essential to characterise the sequences properly.

## Pipeline overview

<img src="https://github.com/amkilar/GERONIMO/blob/main/Geronimo_workflow.png" width=30% align="right">

By default, the GERONIMO pipeline conducts high-throughput searches of homology sequences in downloaded genomes utilizing covariance models. If a significant similarity is detected between the model and genome sequence, the pipeline extracts the upstream region, making it convenient to identify the promoter of the discovered gene. In brief, the pipeline:
- Compiles a list of genomes using the NCBI's [Entrez] database based on a specified query, *e.g. "Rhodophyta"[Organism]*
- Downloads and decompresses the requested genomes using *rsync* and *gunzip*, respectively
- *Optionally*, generates a covariance model based on a provided alignment using [Infernal]
- Conducts searches among the genomes using the covariance model [Infernal]
- Supplements genome information with taxonomy data using [rentrez]
- Expands the significant hits sequence by extracting upstream genomic regions using [*blastcmd*]
- Compiles the results and organizes them into a tabular format and generates a visual summary of the performed analysis.


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
```
Then restart the machine and follow the instructions for setting up the Linux environment.

[instructions]: https://learn.microsoft.com/en-us/windows/wsl/install

### Linux:
#### 1) Install `miniconda`
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
In case of complications please follow the [official documentation].

[official documentation]: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html

### Clone the GERONIMO repository
Go to the path in which you want to run the analysis and clone the repository:
```shell
cd <PATH>
git clone https://github.com/amkilar/GERONIMO.git
```

## Setup the inputs

### 1) Prepare the `covariance models`:

#### Browse the collection of available `covariance models` at [Rfam] (*You can find the covariance model in a tab `Curation`.*)  
Paste the covariance model to the folder `GERONIMO/models` and ensure it's name follows the convention: `cov_model_<NAME>`

[Rfam]: https://rfam.org/

#### **OR**

#### Prepare your own `covariance model` using [RNAalifold]
1. Paste or upload your sequences to the web server and download `.stk` file with the result of alignment.  
  
    > *Please note, the `.stk` file format is crucial for the analysis, as it cointains sequence alignment and secondary structure consensus.*  
  
2. Paste the `.stk` alignemnt file to the folder `GERONIMO/model_to_build` and ensure it's name follows the convention: `<NAME>.stk`

[RNAalifold]: http://rna.tbi.univie.ac.at/cgi-bin/RNAWebSuite/RNAalifold.cgi


### 2) Adjust `config.yaml` file
Please adjust the analysis specifications, as on the following example:

> - CPU: <number> (specify the number of available CPUs (half of them will be used for covariance model building)
> - database: '<DATABASE_QUERY> [Organism]' (in case of difficulities with defining the database query please follow instructions below)
> - models_to_build: ["<NAME>"] (here specify the names of alignment/s in `.stk` format that you want to build)
> - models: ["<NAME>", "<NAME>"] (here specify the names of models that should be used to perform analysis)
> - extract_genomic_region-length:  <number> (here you can specify how long the upstream genomic region should be extracted; tested for 200)

  > *Keep in mind, that the covariance models and alignments must be present in the respective GERONIMO folders.*  
  
### 3) **Please ensure you have enough storage capacity to download all the requested genomes (in `GERONIMO/` directory)**

### 4) Run GERONIMO
```shell
mamba activate env_snakemake
cd ~/GERONIMO
snakemake -s GERONIMO.sm --cores <declare number of CPUs> --use-conda results/summary_table.xlsx
```

## Questions & ansewrs

#### How to specify the database query?
- Visit the [NCBI Assemblies] website.  
- Follow the instruction on the graphic below:
<img src="https://github.com/amkilar/GERONIMO/blob/main/database_query.png" width=100%>

[NCBI Assemblies]: https://www.ncbi.nlm.nih.gov/assembly/?term=


## License
The GERONIMO is freerly available for academic users. Usage for commercial purposes is not allowed.

## Contact
mgr inż. Agata Magdalena Kilar (agata.kilar@ceitec.muni.cz)

