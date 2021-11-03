#!/bin/bash
### Runs the virus scanning pipeline for all the samples in the text file


while IFS= read -r line
do  
    ## first check if the file is already completed
    summary=final_summaries/"$line""_CONTIG_SUMMARY.tsv"

    if [[ ! -e $summary ]]; then
        echo "$line"
	#source pipeline.sh $line ## run pipeline on this sample
    else
        echo "$summary exists" ## if summary file exists, skip sample
    fi

done < "2_SRA.txt" ## input text file, just one line per SRA accession.
