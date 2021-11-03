#!/bin/bash

SRA=$1
WD="/data/virus_scanning"

./init.sh $SRA $WD
./sunbeam_megahit.sh $SRA $WD
./cenote_cleanup.sh $SRA $WD
