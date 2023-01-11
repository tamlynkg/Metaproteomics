#!/bin/bash

#SBATCH --job-name='Metanovo'
#SBATCH --ntasks=32
#SBATCH --mem=232GB
#SBATCH --nodes=1
#SBATCH --mail-user=gngtam001@myuct.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=metanovo-stdout.log
#SBATCH --error=metanovo-stderr.log
#SBATCH --time=12-00:00:00

echo "Submitting SLURM job"
cd /cbio/users/gangiaht/my_metanovo_project
singularity exec /cbio/images/metanovo_v1.6.img metanovo.sh /cbio/users/gangiaht/my_metanovo_project/Urinary_2019 /cbio/users/gangiaht/Raw_files/database/combined.fasta /cbio/users/gangiaht/my_metanovo_project/Urinary_2019 config.sh 
