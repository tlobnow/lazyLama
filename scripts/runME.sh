#!/usr/bin/env bash

module load parallel

source ./00_source.inc

LIST=${LOC_LISTS}/${FOLDER}_inds

### SET UP A LIST OF INDIVIDUALS IN LISTS FOLDER
# = if you cannot find the list for the folder specified above, then create a list with the basenames in that folder.
[ -f $LIST ] || for i in ${LOC_FASTA}/${FOLDER}/*.fasta; do echo $(basename -a -s .fasta $i); done > ${LOC_LISTS}/${FOLDER}_inds

### COPY THE TEMPLATE SCRIPT TO CREATE FOLDER PER INDIVIDUAL
# = read the list file - if you cannot find a folder that carries the same name as the line you are currently reading (list) -> create a folder with 
#   that name by copying the template folder. Once all folders are created, also copy the fasta files into the main fasta_files folder (could also 
#   move, but I retain them in the original folder as a backup)

while read -r LIST
do
	FOUND="$(find . -name "$LIST" -print -quit)"
	if [ "x$FOUND" != "x" ]
	then
		echo "Working on $LIST"
	else
		if [ $STOICH = 'simple' ]
			then
			for i in ${LOC_FASTA}/${FOLDER}/*.fasta; do 
				cp -r ${LOC_SCRIPTS}/template ${LOC_SCRIPTS}/myRuns/$(basename -a -s .fasta $i); done
		else
			for i in ${LOC_FASTA}/${FOLDER}/*.fasta; do
				#cp -r ${LOC_SCRIPTS}/template ${LOC_SCRIPTS}/myRuns/$(basename -a -s .fasta $i)_COMPLEX ; done
				cp -r ${LOC_SCRIPTS}/template ${LOC_SCRIPTS}/myRuns/IL1R_x1+IL1AP_x1_$(basename -a -s .fasta $i)_x${N} ; done
		fi
		cp ${LOC_FASTA}/${FOLDER}/*.fasta $LOC_FASTA
	fi
done <$LIST


#### MODEL PARAMETER CAN BE CHANGED IN SOURCE.INC ####

if [ $MODEL = 'yes' ]; then

	if [ $STOICH = 'simple' ]; then
		echo "running 01_MODEL_simple.sh based on ${LOC_LISTS}/${FOLDER}_inds"
		parallel 'sh 01_MODEL_simple.sh {}' :::: ${LOC_LISTS}/${FOLDER}_inds

	elif [  $STOICH = 'advanced' ]; then
		echo "running 01_MODEL_complex.sh based on ${LOC_LISTS}/${FOLDER}_inds"
		parallel 'sh 01_MODEL_complex.sh {}' :::: ${LOC_LISTS}/${FOLDER}_inds
	else 
		echo "Please adjust 'source.inc' to your needs and set 'MODEL=yes' to start the pipeline."
	fi
fi	
