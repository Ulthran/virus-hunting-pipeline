# virus-hunting-pipeline

HPC pipeline for identifying viral contigs in existing sequence data

NB: This is configured to run on AWS EC2 instances but should be translatable to other cloud platforms

# Pipeline specs

 - Fastq download -> sunbeam -> megahit -> cenote-taker2 -> cleanup & output
 - Bottlenecks:
 - BW                CPU        CPU, RAM   CPU, RAM, IOPS   N/A

# Install process

As written, everything works best if the pipeline and it's dependencies are installed onto an EBS volume and that volume is then mounted to the instance running the pipeline. Start by creating an EBS volume (gp3, ~200GiB, default IOPS & throughput of 3000 & 125) and attaching it to an EC2 instance (simplest to use something in the c5a class with Amazon Linux x86\_64 AMI). SSH into the instance with something like:

```$ sudo ssh -i *my_key_file.pem* ec2-user@ec2-*instance-id*.compute-1.amazonaws.com```

replacing *my_key_file.pem* with the key you created when you made the instance and *instance-id* with the instance's public IP. You can also find this command through the AWS Console, navigate to your instance then click **Connnect** and select the SSH option. Once you're into the instance, you need to find the EBS volume you mounted:

```$ lsblk

Output:
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT                                                                       nvme1n1       259:0    0  200G  0 disk                                                                                  nvme0n1       259:1    0    8G  0 disk                                                                                  ├─nvme0n1p1   259:2    0    8G  0 part /                                                                                └─nvme0n1p128 259:3    0    1M  0 part ```

Find the 200G disk and then:

```$ sudo mount /dev/nvme1n1 /data```

replacing *nvme1n1* with the result from the previous command and making sure that */data* exists (`$ mkdir /data`) and you want to mount it there.
