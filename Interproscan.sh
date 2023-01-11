#!/bin/bash

#SBATCH --job-name='Interproscan'
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mail-user=gngtam001@myuct.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=ipr-stdout.log
#SBATCH --error=ipr-stderr.log
#SBATCH --time=1-00:00:00

echo "Submitting SLURM job"

cd /cbio/users/gangiaht/my_interproscan/interproscan-5.45-80.0

#wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.45-80.0/interproscan-5.45-80.0-64-bit.tar.gz
#tar -pxzf interproscan-5.45-80.0-64-bit.tar.gz
#wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/data/panther-data-14.1.tar.gz
#tar -pxvzf panther-data-14.1.tar.gz
interproscan.sh -i test_proteins.fasta -f tsv
