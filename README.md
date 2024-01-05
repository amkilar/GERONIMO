<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/Geronimo_logo.png" width=42% align="right">


# GERONIMO 

[![DOI](https://img.shields.io/badge/DOI-GigaScience-yellow)](https://doi.org/10.1093/gigascience/giad080) [![DOI](https://img.shields.io/badge/DOI-WorkflowHub-blue)](https://doi.org/10.48546/workflowhub.workflow.547.1) [![DOI](https://img.shields.io/badge/DOI-bio.tools-blue)](https://bio.tools/GERONIMO) [![ExampleAnalysis](https://img.shields.io/badge/ExampleAnalysis-FigShare-red)](https://doi.org/10.6084/m9.figshare.22266430.v2)

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

## Citation
Data from [example analysis] might be found on Figshare.

GERONIMO is registered on:
- [WorkflowHub]
- [bio.tools]

GERONIMO is published in Giga Science as [GERONIMO: A tool for systematic retrieval of structural RNAs in a broad evolutionary context]

[GERONIMO: A tool for systematic retrieval of structural RNAs in a broad evolutionary context]: https://doi.org/10.1093/gigascience/giad080
[example analysis]: https://doi.org/10.6084/m9.figshare.22266430.v2
[WorkflowHub]: https://doi.org/10.48546/workflowhub.workflow.547.1
[bio.tools]: https://bio.tools/GERONIMO

## Quick start
The GERONIMO is available as a `snakemake pipeline` running on Linux and Windows operating systems.

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
> GERONIMO was tested on conda 23.3.1
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

### Run sample analysis to ensure GERONIMO installation was successful
All files are prepared for the sample analysis as a default. Please execute the line below:
```shell
snakemake -s GERONIMO.sm --cores 1 --use-conda results/summary_table.xlsx
```

This will prompt GERONIMO to quickly scan all modules, verifying the correct setup of the pipeline without executing any analysis.
You should see the message `Building DAG of jobs...`, followed by `Nothing to be done (all requested files are present and up to date).`, when successfully completed.

If you want to run the sample analysis fully, please remove the folder `results` from the GERONIMO directory and execute GERONIMO again with:

`snakemake -s GERONIMO.sm --cores 1 --use-conda results/summary_table.xlsx`

> You might consider allowing more cores to speed up the analysis, which might take up to several hours.

#### You might want to clean `GERONIMO/` directory from the files produced by the example analysis. You can safely remove the following:
- `GERONIMO/results`
- `GERONIMO/database`
- `GERONIMO/taxonomy`
- `GERONIMO/temp`
- `.create_genome_list.touch`
- `list_of_genomes.txt`

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

   > Please check the example `heterotrichea.stk` format in `GERONIMO/models_to_built` for reference
   

[LocARNA]: http://rna.informatik.uni-freiburg.de/LocARNA/Input.jsp
[here]: http://www.bioinf.uni-freiburg.de/Software/LocARNA/


### 2) Adjust the `config.yaml` file
Please adjust the analysis specifications, as in the following example:

> - database: '<DATABASE_QUERY> [Organism]' (in case of difficulties with defining the database query, please follow the instructions below)
> - extract_genomic_region-length:  <number> (here you can determine how long the upstream genomic region should be extracted; tested for 200)
> - models: ["<NAME>", "<NAME>"] (here specify the names of models that should be used to perform analysis)
>   
>   *Here you can also insert the name of the covariance model you want to build with GERONIMO - just be sure you placed `<NAME>.stk` file in `GERONIMO/models_to_build` before starting analysis*
> - CPU_for_model_building: <number> (specify the number of available CPUs devoted to the process of building model (cannot exceed the CPU number allowed to snakemake with `--cores`)
>
>   *You might ignore this parameter when you do not need to create a new covariance model*


Keep in mind that the covariance models and alignments must be present in the respective GERONIMO folders.
 
### 3) Remove folder `results`, which contains example analysis output
### 4) **Please ensure you have enough storage capacity to download all the requested genomes (in the `GERONIMO/` directory)**

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

<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/table.png" width=100% align="center">

#### B) Significant Hits Distribution Across Taxonomy Families
The plot provides an overview of the number of genomes in which at least one significant hit was identified, grouped by family. The bold black line corresponds to the number of genomes present in each family, helping to minimize bias regarding unequal data representation across the taxonomy.

<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/plot_A.png" width=100% align="center">

#### C) Hits Distribution in Genomes Across Families
The heatmap provides information about the most significant hits from the genome, identified by a specific covariance model. Genomes are grouped by families (on the right). Hits are classified into three categories based on their e-values. Generally, these categories correspond to hit classifications ("HIT," "MAYBE," "NO HIT"). The "HIT" category is further divided to distinguish between highly significant hits and moderately significant ones.

<img src="https://github.com/amkilar/pictures/blob/main/GERONIMO/plot_B.png" width=100% align="center">


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

## GERONIMO applicability

### Expanding the evolutionary context
To add new genomes or database queries to an existing analysis, please follow the instructions:
1) Rename the `list_of_genomes.txt` file to `previous_list_of_genomes.txt` or any other preferred name.
2) Modify the `config.yaml` file by replacing the previous database query with the new one.
3) Delete:
   - `summary_table.xlsx`, `part_summary_table.csv`, `summary_table_models.xlsx` files located in the `GERONIMO\results` directory
   - `.create_genome_list.touch` file
5) Run GERONIMO to calculate new results using the command:
     ```shell
     snakemake -s GERONIMO.sm --cores <declare number of CPUs> --use-conda results/summary_table.xlsx
     ```
7) Once the new results are generated, reviewing them before merging them with the original results is recommended.
8) Copy the contents of the `previous_list_of_genomes.txt` file and paste them into the current `list_of_genomes.txt`.
9) Delete:
   - `summary_table.xlsx` located in the `GERONIMO\results` directory
   - `.create_genome_list.touch` file
10) Run GERONIMO to merge the results from both analyses using the command:
    ```shell
      snakemake -s GERONIMO.sm --cores 1 --use-conda results/summary_table.xlsx
    ```

### Incorporating new covariance models into existing analysis
1) Copy the new covariance model to `GERONIMO/models`
2) Modify the `config.yaml` file by adding the name of the new model to the line `models: [...]`
3) Run GERONIMO to see the updated analysis outcome

### Building a new covariance model
With GERONIMO, building a new covariance model from multiple sequence alignment in the `.stk` format is possible. 

To do so, simply paste `<NAME>.stk` file to `GERONIMO/models_to_build` and paste the name of the new covariance  model to `config.yaml` file to the line `models: ["<NAME>"]`

and run GERONIMO.


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

Check whether the `env_snakemake` is activated.
> It should result in a change from (base) to (env_snakemake) before your login name in the command line window.

If you still see `(base)` before your login name, please try to activate the environment with conda:
`conda activate env_snakemake`


Please note that you might need to specify the full path to the `env_snakemake`, like /home/your user name/env_snakemake

### How to browse GERONIMO results obtained in WSL?
You can easily access the results obtained on WSL from your Windows environment by opening `File Explorer` and pasting the following line into the search bar: `\\wsl.localhost\Ubuntu\home\`. This will reveal a folder with your username, as specified during the configuration of your Ubuntu system. To locate the GERONIMO results, simply navigate to the folder with your username and then to the `home` folder. (`\\wsl.localhost\Ubuntu\home\<user>\home\GERONIMO`)

### GERONIMO occupies a lot of storage space
Through genome downloads, GERONIMO can potentially consume storage space, rapidly leading to a shortage. Currently, downloading genomes is an essential step for optimal GERONIMO performance.

Regrettably, if the analysis is rerun without the `/database` folder, it will result in the need to redownload genomes, which is a highly time-consuming process.

Nevertheless, if you do not intend to repeat the analysis and have no requirement for additional genomes or models, you are welcome to retain your results tables and plots while removing the remaining files.

It is strongly advised against using local machines for extensive analyses. If you lack access to external storage space, it is recommended to divide the analysis into smaller segments, which can be later merged, as explained in the section titled `Expanding the evolutionary context`.

Considering this limitation, I am currently working on implementing a solution that will help circumvent the need for redundant genome downloads without compromising GERONIMO performance in the future.

You might consider deleting the `.snakemake` folder to free up storage space. However, please note that deleting this folder will require the reinstallation of GERONIMO dependencies when the analysis is rerun.

## License
Copyright (c) 2023 Agata M. Kilar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Contact
mgr inż. Agata Magdalena Kilar, PhD (agata.kilar@ceitec.muni.cz)

