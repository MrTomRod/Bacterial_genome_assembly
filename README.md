Bacterial genome assembly pipeline
=======================

This pipeline assembles Illumina paired end reads. It results in a scaffold and annotated assembly.

#Requirements:

-Linux 64 bit system<br />

-python (version 2.7)<br />
-SPAdes (version 3.10.1)<br />
-samtools (version 1.3)<br />
-prokka (version 1.12)<br />
-bowtie2 (version 2.3.0)<br />

#Installation:

wget https://github.com/danielwuethrich87/Bacterial_genome_assembly/archive/master.zip
unzip master.zip

#Usage:

  sh bacteria_assembly.sh <Sample_ID> <Reads_R1> <Reads_R2> <Genus_> <species_> <Number_of_cores><br />
 
  <Sample_ID>               Unique identifier for the sample<br />
  <Reads_R1>                Foreward read file<br />
  <Reads_R2>                Reversed read file<br />
  <Genus_>                  Genus name of the bacterial species<br />
  <species_>                Species name of the bacterial species<br />
  <Number_of_cores>         number of parallel threads to run (int)<br />

#example:


#!/bin/sh<br />
#$ -q all.q<br />
#$ -e $JOB_ID.cov.err<br />
#$ -o $JOB_ID.cov.out<br />
#$ -cwd<br />
#$ -pe smp 24<br />

module add UHTS/Assembler/SPAdes/3.10.1;<br />
module add UHTS/Analysis/samtools/1.3;<br />
module add UHTS/Analysis/prokka/1.12;<br />
module add UHTS/Aligner/bowtie2/2.3.0;<br />

for i in FAM22234<br />

do<br />

sh /home/dwuethrich/Application/assembly_pipeline/bacteria_assembly.sh "$i" ../../reads/"$i"_R1.fastq.gz ../../reads/"$i"_R2.fastq.gz Pediococcus acidilactici "$NSLOTS"<br />

done<br />

