<img src="https://github.com/amkilar/GERONIMO/blob/main/Geronimo_logo.png" width=35% align="right">

# GERONIMO

## Introduction
GERONIMO is a bioinformatics pipeline for high-throughput searching of unknown genetic sequences based on their sequence and secondary structure consensus. The pipeline is built using Snakemake, a workflow managment tool to run analyses in reproducible manner on a variety of computational platforms. 

Examples of performance might be seen in <articles>
Geronimo made possible discovery of hundreds Telomerase RNA sequences across Plant kingdome!

## Background

### Covariance models
The Tandem Repeat Finder aims to recognise a tandem repeat in DNA, which might be two or more adjacent, approximate copies of a pattern of nucleotides. Please visit the official [GitHub repository] or see [reference] to know more.

[GitHub repository]: https://github.com/Benson-Genomics-Lab/TRF
[reference]: https://doi.org/10.1093/nar/27.2.573


### BLAST package
**Fill in!**
taxonomy information filling comes handy in further data analysis


### bla bla



## Installation
The Geronimo is available as a `snakemake pipeline` running on Linux and Windows operating systems.

### Windows 10
#### Instal Linux on Windows 10 (WSL) according to [instructions], which bottling down to opening PowerShell or Windows Command Prompt in *administrator mode*. Paste the following:
```shell
wsl --install
```
Then restart the machine and follow the instructions for setting up the linux environment.

[instructions]: https://learn.microsoft.com/en-us/windows/wsl/install

### Linux:
#### Instal `miniconda`
##### Please follow the instructions here: https://conda.io/projects/conda/en/stable/user-guide/install/linux.html for installing the miniconda. 
##### Continue with installing `mamba` (recommended but optional)
```shell
conda install -n base -c conda-forge mamba
```
##### Install `snakemake` as described: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html



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


