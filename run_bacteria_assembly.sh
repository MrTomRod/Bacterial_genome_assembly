#!/bin/bash

#SBATCH --time=03:00:00
#SBATCH --mem=20G
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --job-name=bacAs_migrTest
#SBATCH --cpus-per-task=12
#SBATCH --workdir=.

module add vital-it
module add UHTS/Assembler/SPAdes/3.10.1;
module add UHTS/Analysis/samtools/1.3;
module add UHTS/Analysis/prokka/1.12;
module add UHTS/Aligner/bowtie2/2.3.4.1;
module add UHTS/Analysis/aragorn/1.2.38;
module add Development/java/1.8.0_172;

# Get the location of the script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )";

# Add the tools to the PATH.
export PATH=$PATH:$DIR/software

# Run the actual script.
# Obviously, change the input parameters as required. The explanations are in bacteria_assembly_slurm.sh.
# One assembly takes approximately 15 minutes on the IBU cluster.
$DIR/bacteria_assembly_slurm.sh "FAM13495" $DIR/input/FAM13495_R1.fastq.gz $DIR/input/FAM13495_R2.fastq.gz Streptococcus thermophilus "$SLURM_CPUS_PER_TASK"
