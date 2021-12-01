## Parameters
## 1 - SRA accession
## 2 - CPU thread count to be used
## 3 - Memory to be used (in GB)
SRA=$1
THREADS=$2
MEM=$3
root_dir="/virus-hunting-pipeline"
root_efs="/efs/virus-hunting-pipeline"
WD="$root_dir/virus_scanning"
DIR="$WD"/raw/"$SRA"
contig_dir="$DIR"/contigs

### SET UP ENVIRONMENT ###

export PATH=$PATH:$root_dir/install/miniconda3/condabin
conda init bash
source /root/.bashrc

cd $root_dir/run
## ------------- Cenote-Taker2 for detecting viral contigs -------------------
source $root_dir/install/miniconda3/etc/profile.d/conda.sh
#conda activate /virus-hunting-pipeline/install/miniconda3/envs/cenote-taker2_env/
conda activate $root_dir/install/miniconda3/envs/cenote-taker2_env/

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
PATH=$PATH:/root/edirect/   # Change this to match where edirect is installed

CONTIGS="$contig_dir"/final.contigs.fa

before=$(date +"%T")
echo "Start cenote: $before"
python $root_efs/install/Cenote-Taker2/run_cenote-taker2.py -c $CONTIGS -r $SRA  -p True -m $MEM -t $THREADS >> $root_efs/run/logs/out_"$SRA".log 2> $root_efs/run/logs/err_"$SRA".log
after=$(date +"%T")
echo "End cenote: $after"

conda deactivate

cd $WD

echo Cenote Taker Finished
## ------ Move the summary table from Cenote-Taker2 to permanent dir ---------
cp "$cenote_output"/$SRA/*CONTIG_SUMMARY.tsv $root_efs/virus_scanning/final_summaries/
cp "$cenote_output"/$SRA/final_combined_virus_sequences_*.fna $root_efs/virus_scanning/final_contigs/

## ------ Clean up everything, remove all files other than the contigs and summary -----------
#rm -r $DIR
#rm -r $cenote_output 
#rm -r fasterq.tmp.microb120*
#rm "$WD"/raw/dump/sra/*.sra
