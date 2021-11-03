#!/bin/bash

## should only take one parameter, the SRA accession
SRA=$1
WD=$2

echo Begin sample $SRA
##  ------------------ Download fastq using wget  -------------------------
DIR="$WD"/raw/"$SRA"
mkdir $DIR

## prefix used by the EBI ftp server
SRA_prefix=${SRA:0:6}

## the suffix needs zero padding and some filenames don't have suffix folder at all
len_sra=${#SRA}
if [ $len_sra -eq 11 ]; then
    suffix=0${SRA:9:11}
    wget_path=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SRA_prefix/$suffix/$SRA/* ## path for 11 character accessions

elif [ $len_sra -eq 10 ]; then
    let "tmp = $len_sra - 1"
    suffix=00${SRA:$tmp:$len_sra}
    wget_path=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SRA_prefix/$suffix/$SRA/* ## path for 10 character accessions

else
    wget_path=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SRA_prefix/$SRA/* ## path has no suffix
fi

wget $wget_path -P $DIR

echo Fastq downloaded

## ------------------- Create sample list file for sunbeam ------------------
## format is SAMPLE,FASTQ_R1,FASTQ_R2
R1="$DIR"/"$SRA"_1.fastq.gz ## add working directory to fastq path and name
R2="$DIR"/"$SRA"_2.fastq.gz

echo "$SRA","$R1","$R2" > $DIR/sample_list.csv

## -------- Create a copy of the config file and edit for this sample --------
config_file="$DIR"\/"$SRA"_config.yml
cp default_config.yml $config_file

sunbeam_dir=${DIR//"/"/"\/"} ## replace / with \/ to escape slash from sed command
sed -i "s/OUTPUT_DIRECTORY/$sunbeam_dir/g" $config_file ## add the output directory to the config file

echo Config file created
