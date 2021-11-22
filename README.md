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

## On an EBS volume (best for single runs of the pipeline)



## On an EFS volume (best for many parallel runs)

Create an EC2 instance and an EFS volume then [mount the EFS volume](https://docs.aws.amazon.com/efs/latest/ug/wt1-test.html) to a location of your choosing. Once it is mounted, `cd` into the volume root and clone this repo (you will have to [create an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) for GitHub access) and run the install script:

```
git clone git@github.com:Ulthran/virus-hunting-pipeline.git
cd virus-hunting-pipeline/install
source ./setup_pipeline.sh
```



# Running the pipeline

## Single jobs



## Through Batch


