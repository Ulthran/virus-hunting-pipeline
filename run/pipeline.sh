#!/bin/bash

################ PIPELINE STEPS ######################
#   1. Download fastq file from NCBI 
#   2. Trim and clean reads using sunbeam
#   3. Build contigs using megahit
#   4. Identify viral contigs using Cenote Taker 2
######################################################

## Parameters
## 1 - SRA accession
## 2 - CPU thread count to be used
## 3 - Memory to be used (in GB)
SRA=$1
THREADS=$2
MEM=$3
root_dir="/efs/virus-hunting-pipeline"
WD="$root_dir/virus_scanning"

echo Begin sample $SRA
##  ------------------ Download fastq using wget  -------------------------
DIR="$WD"/raw/"$SRA"
mkdir $DIR

### Using NCBI FTP server ###
## prefix used by the EBI ftp server
#SRA_prefix=${SRA:0:6}
#
## the suffix needs zero padding and some filenames don't have suffix folder at all
#len_sra=${#SRA}
#if [ $len_sra -eq 11 ]; then
#    suffix=0${SRA:9:11}
#    wget_path=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SRA_prefix/$suffix/$SRA/* ## path for 11 character accessions
#
#elif [ $len_sra -eq 10 ]; then
#    let "tmp = $len_sra - 1"
#    suffix=00${SRA:$tmp:$len_sra}
#    wget_path=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SRA_prefix/$suffix/$SRA/* ## path for 10 character accessions
#
#else
#    wget_path=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SRA_prefix/$SRA/* ## path has no suffix
#fi
#
#wget $wget_path -P $DIR

### Using NCBI public S3 bucket ###
export PATH=$PATH:$root_dir/install/sratoolkit.2.11.3-ubuntu64/bin
source ~/.bashrc

prefetch $SRA
cd "$WD"/raw/dump/sra/
fasterq-dump $SRA --outdir $DIR
cd $DIR
gzip -1 "$SRA"_1.fastq && gzip -1 "$SRA"_2.fastq
cd $root_dir/run

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

## ---------------- Run sunbeam for quality control ---------------------------
source $root_dir/install/miniconda3/etc/profile.d/conda.sh 
conda activate sunbeam

sunbeam run --cores $THREADS --configfile $config_file all_qc

echo Sunbeam finished

## --------------- Build contigs using megahit -------------------------------
sunbeam_cleaned=$DIR/sunbeam/qc/cleaned
clean_R1="$sunbeam_cleaned"/"$SRA"_1.fastq.gz
clean_R2="$sunbeam_cleaned"/"$SRA"_2.fastq.gz

contig_dir="$DIR"/contigs

megahit -1 $clean_R1 -2 $clean_R2 -t $THREADS --min-contig-len 1000 -o $contig_dir -m .95

conda deactivate

echo Contigs built

## ------------- Cenote-Taker2 for detecting viral contigs -------------------
conda activate $root_dir/install/Cenote-Taker2/cenote_taker/cenote-taker2_env/

if [ -d "cenote_output" ] ; then
	echo "cenote_output already exists"
else
	mkdir cenote_output
fi
cd cenote_output
mkdir $SRA
cd $SRA
cenote_output=`pwd`

## some required programs are loaded in the conda environemnt, others need to be added to the path
PATH=$PATH:$root_dir/install/program_files/Prodigal/
PATH=$PATH:$root_dir/install/program_files/mummer-4.0.0rc1/bin/
PATH=$PATH:$root_dir/install/program_files/Krona/KronaTools/bin/
PATH=$PATH:$root_dir/install/program_files/tRNAscan-SE-2.0/bin
PATH=$PATH:$root_dir/install/program_files/
PATH=$PATH:$root_dir/install/program_files/bbmap/
PATH=$PATH:/home/ec2-user/edirect/   # Change this to whatever user you want to use, ec2-user is the default on amazonlinux images

CONTIGS="$contig_dir"/final.contigs.fa

before=$(date +"%T")
echo "Start cenote: $before"
python $root_dir/install/Cenote-Taker2/run_cenote-taker2.py -c $CONTIGS -r $SRA  -p True -m $MEM -t $THREADS >> $root_dir/run/logs/out_"$SRA".log 2> $root_dir/run/logs/err_"$SRA".log
after=$(date +"%T")
echo "End cenote: $after"

conda deactivate

cd $WD

echo Cenote Taker Finished
## ------ Move the summary table from Cenote-Taker2 to permanent dir ---------
cp "$cenote_output"/$SRA/*CONTIG_SUMMARY.tsv final_summaries/
cp "$cenote_output"/$SRA/final_combined_virus_sequences_*.fna final_contigs/

## ------ Clean up everything, remove all files other than the contigs and summary -----------
rm -r $DIR
rm -r $cenote_output 
rm -r fasterq.tmp.microb120*
rm "$WD"/raw/dump/sra/*.sra













