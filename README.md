<img src="https://github.com/amkilar/GERONIMO/blob/main/Geronimo_logo.png" width=40% align="right">

# GERONIMO

## Introduction
GERONIMO is a bioinformatics pipeline for high-throughput searching unknown genetic sequences using covariance models, which are calculated based on the alignment sequence and secondary structure consensus. The pipeline is built using Snakemake, a workflow management tool to run analyses in a reproducible manner on a variety of computational platforms.

The idea of Geronimo development emerged during an extensive search of [Telomerase RNA in lower plants] and was further polished in an [expanded search of Telomerase RNA across Insecta]. GERONIMO tests over thousands of genomes and ensures the stability and reproducibility of performed analyses.

[Telomerase RNA in lower plants]: https://doi.org/10.1093/nar/gkab545
[expanded search of Telomerase RNA across Insecta]: https://doi.org/10.1093/nar/gkac1202


## Pipeline overview
By default, the pipeline performs high-throughput genetic sequence searches on downloaded genomes using covariance models. If a significant similarity between the model and genome sequence is found, the GERONIMO extracts the upstream region, which makes it easy to identify the promoter of the discovered gene. In short, the pipeline:
- creates the list of genomes using [Entrez] (NCBI) based on the specified query, *i.e. "Chlorophyta"[Organism]*
- downloads and unzips the requested genomes with *rsync* and *gunzip*, respectively
- *optionally*, builds the covariance model based on provided alignment with [Infernal] 
- performs the search among the genomes using the covariance model ([Infernal])
- supplements the taxonomy information about the genome with [rentrez]
- extends the significant hits with upstream genomic region using [*blastcmd*]
- collects the results and arranges them into table format and produces a visual summary of the performed analysis

**PUT THE GRAPHIC WITH OVERVIEW**


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
#### Install `miniconda`
Please follow the instructions for installing [miniconda]

[miniconda]: https://conda.io/projects/conda/en/stable/user-guide/install/linux.html

#### Continue with installing `mamba` (recommended but optional)
```shell
conda install -n base -c conda-forge mamba
```
#### Install `snakemake`
```shell
conda activate base
mamba create -c conda-forge -c bioconda -n snakemake snakemake
conda activate snakemake
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

#### **Before running the analysis please ensure you have enough storage capacity to download all the requested genomes**

## Setup the inputs

### Prepare the `covariance models`:

#### Browse the collection of available `covariance models` at [Rfam] (*You can find the covariance model in a tab `Curation`.*)  
Paste the covariance model to the folder `GERONIMO/models` and ensure it's name follows the convention: `cov_model_<NAME>`

[Rfam]: https://rfam.org/

#### **OR**

#### Prepare your own `covariance model` using [RNAalifold]
1. Paste or upload your sequences to the web server and download `.stk` file with the result of alignment.  
  
*Please note, the `.stk` file format is crucial for the analysis, as it cointains sequence alignment and secondary structure consensus.*  
  
2. Paste the `.stk` alignemnt file to the folder `GERONIMO/model_to_build` and ensure it's name follows the convention: `<NAME>.stk`

[RNAalifold]: http://rna.tbi.univie.ac.at/cgi-bin/RNAWebSuite/RNAalifold.cgi


### Adjust `config.yaml` file
Please adjust the analysis specifications, as on the following example:

> - CPU: 8 (specify the number of available CPUs (half of them will be used for covariance model building)
> - database: '<DATABASE_QUERY> [Organism]' (in case of difficulities with defining the database query please follow instructions below)
> - models_to_build: ["<NAME>"] (here specify the names of alignment/s in `.stk` format that you want to build)
> - models: ["<NAME>", "<NAME>"] (here specify the names of models that should be used to perform analysis)
> - extract_genomic_region-length:  "200" (here you can specify how long the upstream genomic region should be extracted)

*Keep in mind, that the covariance models and alignments must be present in the respective GERONIMO folders.*  
  
#### Database query


#### 2. Create and activate an conda environment:
```shell
conda create -n trfireader_env -c conda-forge -c bioconda -c r -c anaconda -c defaults r-tidyverse r-devtools r-rentrez r-openxlsx r-rvest
conda activate trfireader_env
```
#### 3. Install the TRFiReader:
a) using the channel `amkilar`
```shell
(trfireader_env) conda install --channel amkilar trfireader
```
b) using locally downloaded package:
```shell
(trfireader_env) conda install --use-local trfireader
```

#### Obtain NCBI API Key

An API key is necessary if you are downloading a large number of genomes from NCBI.
To get an API key, register for an NCBI account here. Go to the "Settings" page in your account, then click "Create an API Key" under "API Key Management".

put to config? NCBI_API_KEY={your key}

## Usage
#### After sucessfull instalation of `trfireader` conda package:
Stay in already created environment (here `trfireader_env`) and simply execute:
```shell
(trfireader_env) TRFiReader <list of TRF outputs>
```

#### It is also possible to run TRFiReader as a stand-alone R script: 
Execute directly from the shell command line:
```shell
Rscript --vanilla TRFiReader.R list_of_files.txt
```


### Tutorial on test data:

#### 1. Download `test_data` from this repository containing an example outputs of TRF tool. (will work after publication)
```shell
git clone https://github.com/amkilar/TRFiReader.git/
```

#### 2. Navigate to the `test_data` folder:
```shell
cd <your path>/TRFiReader/test_data
```


#### 3. Run the TRFiReader:
```shell
(trfireader_env) TRFiReader list_of_inputs.txt
```

#### 4. Find results for individual files processed in `/results` subfolder and summary tables in `/results/tables`.


## Tool overview

#### 1. The TRFiReader transform a single Tandem Repeat Finder output (tab-delimited .txt file) to excel table format. It automatically adds taxonomy information from the NCBI database based on the file's name, which contains the genome id and sorts results in descending order.
<img src="https://github.com/amkilar/TRFiReader/blob/main/images/Image.jpeg">

#### 2. The tool can accept more files simultaneously, providing a table with summarised results per taxonomic family.
<img src="https://github.com/amkilar/TRFiReader/blob/main/images/Image%20(2).jpeg">

#### 3. It also produces separate tables per taxonomic families or one table with summarised results divided into spreadsheets.
<img src="https://github.com/amkilar/TRFiReader/blob/main/images/Image%20(1).jpeg">


