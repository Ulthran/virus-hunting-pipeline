# virus-hunting-pipeline

HPC pipeline for identifying viral contigs in existing sequence data

NB: This is configured to run on AWS but should be translatable to other cloud platforms

# Pipeline overview

### fastq download -> sunbeam -> megahit -> cenote-taker2 -> cleanup & output

 - fastq download
    - Downloading sequencing data
 - sunbeam
    - 
 - megahit
    - 
 - cenote-taker2
    - 
 - cleanup & output
    - 

# Install process

## Setting up install

You will need to clone a GitHub repository which now requires at least an SSH connection. You can create and link an SSH key following [this guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh). You will also need to have GitHub Large File Storage installed to get the sratools tarball. You can install LFS by first following the instructions from [this](https://packagecloud.io/github/git-lfs/install) site for your machine type (should just be one command) and then installing it using your standard package manager (something like `apt install git-lfs`).

## On an EBS volume (best for single runs of the pipeline)



## On an EFS volume (best for many parallel runs)

Create an EC2 instance and an EFS volume then [mount the EFS volume](https://docs.aws.amazon.com/efs/latest/ug/wt1-test.html) to a location of your choosing. Once it is mounted, `cd` into the volume root and clone this repo:

```
git clone git@github.com:Ulthran/virus-hunting-pipeline.git
```

Make sure that the `$root_dir` variable defined in `virus-hunting-pipeline/install/setup_pipeline.sh` and `virus-hunting-pipeline/run/pipeline.sh` point to the directory you just cloned into and also check the paths hard-coded into `virus-hunting-pipeline/run/default_config.yml`. Then run the install script:

```
cd virus-hunting-pipeline/install
source ./setup_pipeline.sh
```



# Running the pipeline

## Single jobs



## Through Batch

```
cd /efs/virus-hunting-pipeline/run && source ./job0_download.sh SRR123456789 0 0
```
