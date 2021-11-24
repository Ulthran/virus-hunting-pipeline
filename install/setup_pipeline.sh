#!/bin/bash

root_dir="/mnt/efs/virus-hunting-pipeline"

## STEP 1: set up conda python manager 
## this step will require some interaction - you need to accept the miniconda 
## agreement and confirm installation location (should be in $root_dir/install)
./Miniconda3-py38_4.10.3-Linux-x86_64.sh

# Install sratools for downloading SRA sequences from S3 public DBs
tar -vxzf pipeline_installation_files/sratoolkit.tar.gz
export PATH=$PATH:$root_dir/install/sratoolkit.2.11.3-ubuntu64/bin
which fastq-dump # this step should output the path just added to PATH, if it errors the installation should be fixed

vdb-config -i # this step requires interaction - follow instructions here
              # https://github.com/ncbi/sra-tools/wiki/03.-Quick-Toolkit-Configuration
	          # and set the "Location of user-repository" by creating the directory (Create Dir option): $root_dir/virus_scanning/raw/dump

## STEP 2: Install sunbeam conda environment
conda env create -f pipeline_installation_files/sunbeam_conda.yml

source ~/.bashrc

# activate env
conda activate sunbeam

## STEP 3: Install sunbeam
## Sunbeam is normally installed from the repo on git, but to ensure that we all have the same version
## I have a copy locally as a tarball
tar xzf pipeline_installation_files/sunbeam.tgz
cd sunbeam-stable
./install.sh

cd ../
conda deactivate

## STEP 4: Install edirect
## Installs edirect for accessing NCBI dbs, answer N to prompt for auto-updating the path
sh -c "$(wget -q ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh -O -)"
echo PATH\$PATH:`pwd`/edirect >> ~/.bashrc

## STEP 5: Install cenote-taker2
## I had to install a lot of files from source, hopefully this will take care of all of that.
mkdir program_files

### ---- Files to install ------ 
## 1 - MUMMER
tar xzf pipeline_installation_files/mummer-4.0.0rc1.tar.gz
mv mummer-4.0.0rc1 program_files/mummer-4.0.0rc1/
cd program_files/mummer-4.0.0rc1

## install
./configure --prefix=`pwd`
make
make install

echo PATH=\$PATH:`pwd`/bin >> ~/.bashrc
cd ../../

conda env create -f pipeline_installation_files/cenote_taker_conda.yml
conda activate cenote_taker
conda install -c bioconda prodigal krona trnascan-se bbmap bwa samtools blast hmmer bowtie2 bioawk circlator
conda deactivate

## Install cenote-taker2 itself
bash pipeline_installation_files/cenote_install1.sh cenote_taker 2>&1 | tee install_ct2.log





