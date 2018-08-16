Bacterial genome assembly pipeline
=======================

This is a fork of [danielwuethrich87/Bacterial_genome_assembly](https://github.com/danielwuethrich87/Bacterial_genome_assembly), optimized for SLURM by Simone Oberhansli.

This pipeline assembles **Illumina paired end reads**. It results in a scaffold and annotated assembly.

Steps:
- Read trimming
- SPades de novo assembly
- Coverage selection (exclusion of scaffold with low coverage)
- Prokka annotation

# Requirements:

- Linux 64 bit system
- Slurm (tested on version 17.11.7)
- [Vital-IT modules](https://www.vital-it.ch/)
- python (version 2.7)
- [SPAdes](http://cab.spbu.ru/software/spades/) (version 3.10.1)
- [samtools](https://github.com/samtools/samtools) (version 1.3)
- [prokka](https://github.com/tseemann/prokka) (version 1.12)
- [bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) (version 2.3.0)
- [pilon](https://github.com/broadinstitute/pilon/releases) (version 1.2.2, already installed in /software)
- [barrnap](https://github.com/tseemann/barrnap/tree/master/bin) (version 0.9, already installed in /software)
- [trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) (version 0.36, already installed in /software)

# Installation:

`git clone https://github.com/MrTomRod/Bacterial_genome_assembly.git`

# Usage:

Place the two input files in `/input`.

`run_bacteria_assembly.sh` is a SLURM batch script that runs `bacteria_assembly.sh` (as you might have guessed). In most cases, everything you have to do is edit the line that begins with $DIR/bacteria_assembly_slurm.sh according to your needs.

    $DIR/bacteria_assembly_slurm.sh <Sample_ID> <Reads_R1> <Reads_R2> <Genus_> <species_> <Number_of_cores>
 
    <Sample_ID>               Unique identifier for the sample
    <Reads_R1>                Foreward read file
    <Reads_R2>                Reversed read file
    <Genus_>                  Genus name of the bacterial species
    <species_>                Species name of the bacterial species
    <Number_of_cores>         number of parallel threads to run (int)
    
Now simply disbatch the script to SLURM with `sbatch run_bacteria_assembly.sh`.
