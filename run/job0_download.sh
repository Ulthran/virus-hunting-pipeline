## Parameters
## 1 - SRA accession
## 2 - CPU thread count to be used
## 3 - Memory to be used (in GB)
SRA=$1
THREADS=$2
MEM=$3
root_dir="/efs/virus_hunting_pipeline"
WD="$root_dir/virus_scanning"
DIR="$WD"/raw/"$SRA"

### SET UP ENVIRONMENT ###

export PATH=$PATH:$root_dir/install/sratoolkit.2.11.3-ubuntu64/bin
which fastq-dump # this step should output the path just added to PATH, if it errors the installation should be fixed

echo Begin sample $SRA
##  ------------------ Download fastq using wget  -------------------------
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