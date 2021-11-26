## Parameters
## 1 - SRA accession
## 2 - CPU thread count to be used
## 3 - Memory to be used (in GB)
SRA=$1
THREADS=$2
MEM=$3
root_dir="/efs/virus-hunting-pipeline"
WD="$root_dir/virus_scanning"
DIR="$WD"/raw/"$SRA"

### SET UP ENVIRONMENT ###

export PATH=$PATH:$root_dir/install/miniconda3/condabin
export PATH=$PATH:$root_dir/install/miniconda3/bin

cd $root_dir/run
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
#source $root_dir/install/miniconda3/etc/profile.d/conda.sh 
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
