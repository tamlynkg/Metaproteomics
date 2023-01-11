#!/bin/bash

#SBATCH --job-name='Maxquantrun'
#SBATCH --ntasks=32
#SBATCH --mem=200GB
#SBATCH --nodes=1
#SBATCH --mail-user=gngtam001@myuct.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=maxq-stdout.log
#SBATCH --error=maxq-stderr.log
#SBATCH --time=5-00:00:00

echo "Submitting SLURM job"
singularity exec /cbio/images/bionic-mono6.8.0.sif mono --gc=sgen /cbio/users/gangiaht/bin/bin/MaxQuantCmd.exe /cbio/users/gangiaht/my_metanovo_project/Genital_HIV/mqpar.xml
