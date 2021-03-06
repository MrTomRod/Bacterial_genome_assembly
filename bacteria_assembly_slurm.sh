#!/bin/bash

export working_dir=$PWD
export species=$5
export genus=$4
export cores=$6
export reads_R2=$3
export reads_R1=$2
export sample_id=$1
export software_location=$(dirname $0)

echo
echo "Input:"
echo

echo number_of_cores:$cores
echo sample_id:$sample_id
echo read_file_R1:$reads_R1
echo read_file_R2:$reads_R2
echo genus:$genus
echo species:$species

echo
echo "Checking software ..."
echo

is_command_installed () {
  if which $1 &>/dev/null; then
    echo "$1 is installed in:" $(which $1)
  else
    echo
    echo "ERROR: $1 not found."
    echo
    exit
  fi
}

#is_command_installed blastn
is_command_installed python
is_command_installed spades.py
is_command_installed samtools
is_command_installed prokka
is_command_installed bwa
echo

if [ -r "$reads_R1" ] && [ -r "$reads_R2" ] && [ -n "$sample_id" ] && [ "$cores" -eq "$cores" ] && [ -n "$genus" ] && [ -n "$species" ]; then
  # START THE PROCESS

  # define memory requirements
  # this step is only required for slurm
  mymem=$(($SLURM_MEM_PER_NODE - 1000))

  #trimmomatic------------------------------------------------------------------
  echo
  echo "######### TRIMMOMATIC ########"

  mkdir -p "$working_dir"/results/"$sample_id"/0_read_trimming

  java -jar "$software_location"/software/trimmomatic-0.36.jar PE -threads "$cores" -phred33 "$reads_R1" "$reads_R2" "$working_dir"/results/"$sample_id"/0_read_trimming/r1.fastq.gz "$working_dir"/results/"$sample_id"/0_read_trimming/r1.not-paired.fastq.gz "$working_dir"/results/"$sample_id"/0_read_trimming/r2.fastq.gz "$working_dir"/results/"$sample_id"/0_read_trimming/r2.not-paired.fastq.gz SLIDINGWINDOW:4:8 MINLEN:127 2> "$working_dir"/results/"$sample_id"/0_read_trimming/"$sample_id".read_trimm_info


  #SPades-----------------------------------------------------------------------
  echo
  echo "######## SPADES ########"

  mkdir -p "$working_dir"/results/"$sample_id"/1_spades_assembly

  spades.py --careful --mismatch-correction -t "$cores" -k 21,33,55,77,99,127 -1 "$working_dir"/results/"$sample_id"/0_read_trimming/r1.fastq.gz -2 "$working_dir"/results/"$sample_id"/0_read_trimming/r2.fastq.gz -o "$working_dir"/results/"$sample_id"/1_spades_assembly

  #pilon------------------------------------------------------------------------
  echo
  echo "######## PILON ########"

  mkdir -p "$working_dir"/results/"$sample_id"/2_pilon/pilon

  bwa index "$working_dir"/results/"$sample_id"/1_spades_assembly/scaffolds.fasta
  bwa mem -t "$cores" "$working_dir"/results/"$sample_id"/1_spades_assembly/scaffolds.fasta "$working_dir"/results/"$sample_id"/0_read_trimming/r1.fastq.gz "$working_dir"/results/"$sample_id"/0_read_trimming/r2.fastq.gz > "$working_dir"/results/"$sample_id"/2_pilon/alingnment.sam

  samtools sort -@ "$cores" -m ${mymem}M -T "$i"_temp -o "$working_dir"/results/"$sample_id"/2_pilon/sorted.bam "$working_dir"/results/"$sample_id"/2_pilon/alingnment.sam
  samtools index "$working_dir"/results/"$sample_id"/2_pilon/sorted.bam

  java -Xmx${mymem}M -jar "$software_location"/software/pilon-1.22.jar --genome "$working_dir"/results/"$sample_id"/1_spades_assembly/scaffolds.fasta --frags "$working_dir"/results/"$sample_id"/2_pilon/sorted.bam --changes --variant --outdir "$working_dir"/results/"$sample_id"/2_pilon/pilon --output "$sample_id"


  #coverage_selection-----------------------------------------------------------
  echo
  echo "######## COVERAGE SELECTION ########"

  mkdir -p "$working_dir"/results/"$sample_id"/3_cov_selection

  bwa index "$working_dir"/results/"$sample_id"/2_pilon/pilon/"$sample_id".fasta
  bwa mem -t "$cores" "$working_dir"/results/"$sample_id"/2_pilon/pilon/"$sample_id".fasta "$working_dir"/results/"$sample_id"/0_read_trimming/r1.fastq.gz "$working_dir"/results/"$sample_id"/0_read_trimming/r2.fastq.gz > "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sam 2> "$working_dir"/results/"$sample_id"/3_cov_selection/mapping_Info."$sample_id"

  samtools sort -@ "$cores" -m ${mymem}M -T "$working_dir"/results/"$sample_id"/3_cov_selection/temp_sort -o "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sorted.bam "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sam
  samtools rmdup "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sorted.bam "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sorted.removed_duplicates.bam
  samtools index "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sorted.removed_duplicates.bam
  samtools faidx "$working_dir"/results/"$sample_id"/2_pilon/pilon/"$sample_id".fasta

  samtools idxstats "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sorted.removed_duplicates.bam > "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.idxstats

  python "$software_location"/software/filter_contigs_by_samtools_idxstats.py  "$working_dir"/results/"$sample_id"/2_pilon/pilon/"$sample_id".fasta "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.idxstats 0.1 "$working_dir"/results/"$sample_id"/3_cov_selection/Low_coverage_and_short_scaffolds_"$sample_id".fasta > "$working_dir"/results/"$sample_id"/3_cov_selection/"$sample_id".fasta
  #the 0.1 indicates the min coverage a scaffold must have, compared to large scaffolds

  #prokka-----------------------------------------------------------------------
  echo
  echo "######## PROKKA ########"

  #mkdir -p "$working_dir"/results/"$sample_id"/4_annotation

  prokka --addgenes --mincontiglen 200 --genus "$genus" --species "$species" --prefix "$sample_id" --rfam --locustag "$sample_id" --strain "$sample_id" --outdir "$working_dir"/results/"$sample_id"/4_annotation --cpus $cores "$working_dir"/results/"$sample_id"/3_cov_selection/"$sample_id".fasta

  #clean-up-------------------------------------------------------------------------------------------------------------------------
  echo
  echo "######## CLEAN-UP ########"

  rm "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sam "$working_dir"/results/"$sample_id"/3_cov_selection/scaffolds.sorted.bam

  cp "$working_dir"/results/"$sample_id"/3_cov_selection/Low_coverage_and_short_scaffolds_"$sample_id".fasta "$working_dir"/results/"$sample_id"/4_annotation/

  echo "$sample_id" finished `date`

else
  # SOMETHING WENT WRONG

  echo
  echo "ERROR: Incorrect input!"
  echo "assembly pipe line version 0.1 by Daniel Wüthrich (danielwue@hotmail.com)"
  echo " "
  echo "Usage: "
  echo "  sh bacteria_assembly.sh <Sample_ID> <Reads_R1> <Reads_R2> <Genus> <species> <Number_of_cores>"
  echo " "
  echo "  <Sample_ID>               Unique identifier for the sample"
  echo "  <Reads_R1>                Foreward read file"
  echo "  <Reads_R2>                Reversed read file"
  echo "  <Genus>                   Genus name of the bacterial species"
  echo "  <species>                 Species name of the bacterial species"
  echo "  <Number_of_cores>         number of parallel threads to run (int)"
  echo

  if ! [ -n "$sample_id" ];then
    echo Incorrect input: "$sample_id"
  fi
  if ! [ -r "$reads_R1" ];then
    echo File not found: "$reads_R1"
  fi
  if ! [ -r "$reads_R2" ];then
    echo File not found: "$reads_R2"
  fi
  if ! [ "$cores" -eq "$cores" ] ;then
    echo Incorrect input: "$cores"
  fi
  if ! [ -n "$genus" ];then
    echo Incorrect input: "$reference_name"
  fi
  if ! [ -n "$species" ];then
    echo Incorrect input: "$reference_name"
  fi
fi
