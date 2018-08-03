Bacterial genome assembly pipeline
=======================

This pipeline assembles Illumina paired end reads. It results in a scaffold and annotated assembly.

Steps:
- Read trimming
- SPades de novo assembly
- Coverage selection (exclusion of scaffold with low coverage)
- Prokka annotation

# Requirements:

- Linux 64 bit system
- python (version 2.7)
- SPAdes (version 3.10.1)
- samtools (version 1.3)
- prokka (version 1.12)
- bowtie2 (version 2.3.0)
- [pilon](https://github.com/broadinstitute/pilon/releases) (version 1.2.2, already installed in /software)
- [barrnap](https://github.com/tseemann/barrnap/tree/master/bin) (version 1.2.2, already installed in /software)

# Installation:

wget https://github.com/MrTomRod/Bacterial_genome_assembly/archive/master.zip
unzip master.zip

# Usage:

    sh bacteria_assembly.sh <Sample_ID> <Reads_R1> <Reads_R2> <Genus_> <species_> <Number_of_cores>
 
    <Sample_ID>               Unique identifier for the sample
    <Reads_R1>                Foreward read file
    <Reads_R2>                Reversed read file
    <Genus_>                  Genus name of the bacterial species
    <species_>                Species name of the bacterial species
    <Number_of_cores>         number of parallel threads to run (int)

# Example:

    #!/bin/sh
    #$ -q all.q
    #$ -e $JOB_ID.cov.err
    #$ -o $JOB_ID.cov.out
    #$ -cwd
    #$ -pe smp 24

    module add UHTS/Assembler/SPAdes/3.10.1;
    module add UHTS/Analysis/samtools/1.3;
    module add UHTS/Analysis/prokka/1.12;
    module add UHTS/Aligner/bowtie2/2.3.0;

    for i in FAM22234
    do
      sh /home/dwuethrich/Application/assembly_pipeline/bacteria_assembly.sh "$i" ../../reads/"$i"_R1.fastq.gz ../../reads/"$i"_R2.fastq.gz Pediococcus acidilactici "$NSLOTS"
    done

